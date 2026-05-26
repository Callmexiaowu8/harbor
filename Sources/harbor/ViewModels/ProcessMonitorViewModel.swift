import Foundation
import Observation
import AppKit

@MainActor @Observable
final class ProcessMonitorViewModel {
    var processes: [ServerProcess] = []
    var favoriteServices: [FavoriteService] = []
    var errorMessage: String?
    var isLoading = false
    var hasCompletedInitialLoad = false

    private var collapsedGroups: Set<String> = []
    private var collapsedChildren: Set<String> = []

    private let discoveryService = ProcessDiscoveryService()
    private let terminationService = ProcessTerminationService()
    private let persistenceService = PersistenceService()
    private let launchService = ServiceLaunchService()
    private var pollingTask: Task<Void, Never>?

    // MARK: - Display Types

    /// 展示列表中的行类型
    enum DisplayItem: Identifiable {
        /// 项目组头
        case projectHeader(ProjectGroup)
        /// 主服务行（可能含子进程）
        case serviceRow(ServiceRowItem)
        /// 子进程行（缩进展示）
        case childProcessRow(ChildProcessItem)

        var id: String {
            switch self {
            case .projectHeader(let group): "group-\(group.directory)"
            case .serviceRow(let item): "service-\(item.id)"
            case .childProcessRow(let item): "child-\(item.process.id)"
            }
        }
    }

    /// 项目组
    struct ProjectGroup: Identifiable {
        let id: String  // directory path
        let name: String  // 项目名
        let directory: String  // 工作目录
        var isCollapsed: Bool
        var serviceCount: Int
        var isAllFavorited: Bool

        init(id: String = UUID().uuidString, name: String, directory: String, isCollapsed: Bool = false, serviceCount: Int = 0, isAllFavorited: Bool = false) {
            self.id = directory
            self.name = name
            self.directory = directory
            self.isCollapsed = isCollapsed
            self.serviceCount = serviceCount
            self.isAllFavorited = isAllFavorited
        }
    }

    /// 服务行（主进程 + 可能的子进程列表）
    struct ServiceRowItem: Identifiable {
        let id: String
        let favorite: FavoriteService?
        let mainProcess: ServerProcess?
        let childProcesses: [ServerProcess]
        var isChildrenCollapsed: Bool
        let groupKey: String?

        var isFavorite: Bool { favorite != nil }
        var isRunning: Bool { mainProcess != nil }
        var displayName: String { favorite?.name ?? mainProcess?.name ?? "Unknown" }

        /// 合并显示的端口号
        var displayPort: UInt16? { mainProcess?.port ?? favorite?.port }
    }

    /// 子进程行
    struct ChildProcessItem: Identifiable {
        let id: String
        let process: ServerProcess
        let parentServiceId: String  // 所属主服务的 id
        let groupKey: String?
    }

    // MARK: - Computed Properties

    var serviceListItems: [DisplayItem] {
        // 1. 父子进程合并：按端口分组
        let portGroups = Dictionary(grouping: processes, by: \.port)

        // 对每个端口组，确定主进程和子进程
        struct MergedService {
            let mainProcess: ServerProcess?
            let childProcesses: [ServerProcess]
            let workingDirectory: String?
        }

        var mergedServices: [MergedService] = []

        for (_, groupProcs) in portGroups.sorted(by: { $0.key < $1.key }) {
            if groupProcs.count == 1 {
                mergedServices.append(MergedService(
                    mainProcess: groupProcs[0],
                    childProcesses: [],
                    workingDirectory: groupProcs[0].workingDirectory
                ))
            } else {
                // 找主进程：ppid 不等于同组其他进程的 pid 的进程
                let pidsInGroup = Set(groupProcs.map(\.pid))
                let mainCandidates = groupProcs.filter { proc in
                    // 如果该进程的 pid 等于其他进程的 ppid，则它是主进程
                    let isParentOfOthers = groupProcs.contains { other in
                        other.ppid == proc.pid && other.pid != proc.pid
                    }
                    if isParentOfOthers {
                        return true
                    }
                    // 如果该进程的 ppid 不在组内，则它可能是主进程
                    return !pidsInGroup.contains(proc.ppid)
                }

                let mainProcess: ServerProcess
                let childProcesses: [ServerProcess]

                if mainCandidates.count == 1 {
                    mainProcess = mainCandidates[0]
                    childProcesses = groupProcs.filter { $0.pid != mainProcess.pid }
                } else if mainCandidates.count > 1 {
                    // 多个候选，取 pgid 最小的
                    let sorted = mainCandidates.sorted { $0.pgid < $1.pgid }
                    mainProcess = sorted[0]
                    childProcesses = groupProcs.filter { $0.pid != mainProcess.pid }
                } else {
                    // 无法确定，取 pgid 最小的为主进程
                    let sorted = groupProcs.sorted { $0.pgid < $1.pgid }
                    mainProcess = sorted[0]
                    childProcesses = groupProcs.filter { $0.pid != mainProcess.pid }
                }

                let workingDir = mainProcess.workingDirectory
                    ?? childProcesses.first(where: { $0.workingDirectory != nil })?.workingDirectory

                mergedServices.append(MergedService(
                    mainProcess: mainProcess,
                    childProcesses: childProcesses,
                    workingDirectory: workingDir
                ))
            }
        }

        // 2. 将收藏服务与合并后的进程匹配
        var matchedMainProcessIds: Set<String> = []
        var serviceItems: [(id: String, favorite: FavoriteService?, mainProcess: ServerProcess?, childProcesses: [ServerProcess], workingDirectory: String?)] = []

        for fav in favoriteServices {
            // 尝试匹配：先按端口，再按工作目录
            let matchedIndex = mergedServices.firstIndex { merged in
                if let favPort = fav.port, favPort == merged.mainProcess?.port {
                    return true
                }
                if let procCwd = merged.mainProcess?.workingDirectory, procCwd == fav.workingDirectory {
                    return true
                }
                return false
            }

            if let idx = matchedIndex, !matchedMainProcessIds.contains(mergedServices[idx].mainProcess.map { $0.id } ?? "") {
                let merged = mergedServices[idx]
                if let mainProc = merged.mainProcess {
                    matchedMainProcessIds.insert(mainProc.id)
                }
                serviceItems.append((
                    id: "fav-\(fav.id.uuidString)",
                    favorite: fav,
                    mainProcess: merged.mainProcess,
                    childProcesses: merged.childProcesses,
                    workingDirectory: merged.workingDirectory ?? fav.workingDirectory
                ))
            } else {
                serviceItems.append((
                    id: "fav-\(fav.id.uuidString)",
                    favorite: fav,
                    mainProcess: nil,
                    childProcesses: [],
                    workingDirectory: fav.workingDirectory
                ))
            }
        }

        // 未匹配的进程
        for merged in mergedServices {
            if let mainProc = merged.mainProcess, !matchedMainProcessIds.contains(mainProc.id) {
                serviceItems.append((
                    id: "proc-\(mainProc.id)",
                    favorite: nil,
                    mainProcess: mainProc,
                    childProcesses: merged.childProcesses,
                    workingDirectory: merged.workingDirectory
                ))
            }
        }

        // 3. 公共父目录分组 + 手动覆盖

        // 3a. 先处理手动指定了 projectName 的收藏服务，key 使用 workingDirectory
        var manualGroups: [String: [(id: String, favorite: FavoriteService?, mainProcess: ServerProcess?, childProcesses: [ServerProcess], workingDirectory: String?)]] = [:]
        var autoGroupCandidates: [(id: String, favorite: FavoriteService?, mainProcess: ServerProcess?, childProcesses: [ServerProcess], workingDirectory: String?)] = []

        for item in serviceItems {
            if let pname = item.favorite?.projectName, !pname.isEmpty {
                let dir = item.workingDirectory ?? item.mainProcess?.workingDirectory ?? item.favorite?.workingDirectory ?? ""
                manualGroups[dir, default: []].append(item)
            } else {
                autoGroupCandidates.append(item)
            }
        }

        // 3b. 对剩余服务使用公共父目录算法自动分组，key 为完整目录路径
        func commonParentGrouping(_ items: [(id: String, favorite: FavoriteService?, mainProcess: ServerProcess?, childProcesses: [ServerProcess], workingDirectory: String?)]) -> [String: (items: [(id: String, favorite: FavoriteService?, mainProcess: ServerProcess?, childProcesses: [ServerProcess], workingDirectory: String?)], displayName: String)] {
            let paths = items.compactMap { $0.workingDirectory ?? $0.mainProcess?.workingDirectory ?? $0.favorite?.workingDirectory }
            guard !paths.isEmpty else { return ["Other": (items: items, displayName: "Other")] }

            let componentsList = paths.map { ($0, $0.components(separatedBy: "/").filter { !$0.isEmpty }) }

            var lcp: [String] = []
            if let first = componentsList.first?.1 {
                lcp = first
                for (_, components) in componentsList.dropFirst() {
                    var i = 0
                    while i < min(lcp.count, components.count) && lcp[i] == components[i] {
                        i += 1
                    }
                    lcp = Array(lcp.prefix(i))
                    if lcp.isEmpty { break }
                }
            }

            var groups: [String: (items: [(id: String, favorite: FavoriteService?, mainProcess: ServerProcess?, childProcesses: [ServerProcess], workingDirectory: String?)], displayName: String)] = [:]
            for item in items {
                let dir = item.workingDirectory ?? item.mainProcess?.workingDirectory ?? item.favorite?.workingDirectory ?? ""
                let components = dir.components(separatedBy: "/").filter { !$0.isEmpty }

                let groupKey: String
                let displayName: String
                if components.count > lcp.count {
                    displayName = components[lcp.count]
                    groupKey = "/" + Array(components.prefix(lcp.count + 1)).joined(separator: "/")
                } else if !components.isEmpty {
                    displayName = components.last!
                    groupKey = dir
                } else {
                    displayName = "Other"
                    groupKey = "Other"
                }
                groups[groupKey, default: ([], displayName: displayName)].items.append(item)
            }

            return groups
        }

        let autoGroups = commonParentGrouping(autoGroupCandidates)

        // 3c. 合并手动组和自动组，统一结构为 [String: (items, displayName)]
        var allGroups: [String: (items: [(id: String, favorite: FavoriteService?, mainProcess: ServerProcess?, childProcesses: [ServerProcess], workingDirectory: String?)], displayName: String)] = [:]
        for (dir, items) in manualGroups {
            let displayName = URL(fileURLWithPath: dir).lastPathComponent
            if allGroups[dir] == nil {
                allGroups[dir] = (items: [], displayName: displayName)
            }
            allGroups[dir]?.items.append(contentsOf: items)
        }
        for (dir, data) in autoGroups {
            if allGroups[dir] == nil {
                allGroups[dir] = (items: [], displayName: data.displayName)
            }
            allGroups[dir]?.items.append(contentsOf: data.items)
        }

        // 排序：Other 放最后
        let sortedGroupKeys = allGroups.keys.sorted { a, b in
            if a == "Other" { return false }
            if b == "Other" { return true }
            return a < b
        }

        // 4. 构建 DisplayItem 列表 — 仅多服务组显示组头
        var displayItems: [DisplayItem] = []

        for dir in sortedGroupKeys {
            guard let groupData = allGroups[dir] else { continue }
            let isCollapsed = collapsedGroups.contains(dir)

            if groupData.items.count >= 2 {
                let allFavorited = groupData.items.allSatisfy { item in
                    item.favorite != nil
                }
                let projectGroup = ProjectGroup(
                    name: groupData.displayName,
                    directory: dir,
                    isCollapsed: isCollapsed,
                    serviceCount: groupData.items.count,
                    isAllFavorited: allFavorited
                )
                displayItems.append(.projectHeader(projectGroup))

                if !isCollapsed {
                    for item in groupData.items {
                        appendServiceAndChildren(item: item, groupKey: dir, to: &displayItems)
                    }
                }
            } else {
                for item in groupData.items {
                    appendServiceAndChildren(item: item, groupKey: nil, to: &displayItems)
                }
            }
        }

        return displayItems
    }

    // MARK: - Collapse Toggle

    func toggleGroupCollapse(_ directory: String) {
        if collapsedGroups.contains(directory) {
            collapsedGroups.remove(directory)
        } else {
            collapsedGroups.insert(directory)
        }
    }

    func toggleChildrenCollapse(_ serviceId: String) {
        if collapsedChildren.contains(serviceId) {
            collapsedChildren.remove(serviceId)
        } else {
            collapsedChildren.insert(serviceId)
        }
    }

    func renameGroup(_ oldKey: String, to newName: String) {
        for index in favoriteServices.indices {
            if let pname = favoriteServices[index].projectName, !pname.isEmpty && pname == oldKey {
                favoriteServices[index].projectName = newName
            }
        }
        persistenceService.saveFavoriteServices(favoriteServices)
    }

    func updateGroupDirectory(_ oldKey: String, to newDirectory: String) {
        for index in favoriteServices.indices {
            if let pname = favoriteServices[index].projectName, !pname.isEmpty && pname == oldKey {
                favoriteServices[index].workingDirectory = newDirectory
            }
        }
        persistenceService.saveFavoriteServices(favoriteServices)
    }

    func favoriteGroupServices(_ groupKey: String) -> [FavoriteService] {
        var newFavorites: [FavoriteService] = []
        // Find all services in this group that are not yet favorited
        for item in serviceListItems {
            if case .serviceRow(let serviceItem) = item,
               serviceItem.groupKey == groupKey,
               !serviceItem.isFavorite,
               let proc = serviceItem.mainProcess {
                let fav = FavoriteService(
                    name: serviceItem.displayName,
                    workingDirectory: proc.workingDirectory ?? "",
                    startCommand: proc.command,
                    port: proc.port,
                    projectName: groupKey
                )
                favoriteServices.append(fav)
                newFavorites.append(fav)
            }
        }
        if !newFavorites.isEmpty {
            persistenceService.saveFavoriteServices(favoriteServices)
        }
        return newFavorites
    }

    func unfavoriteGroupServices(_ groupKey: String) {
        let favIdsToRemove = Set(favoriteServices.filter { $0.projectName == groupKey }.map(\.id))
        if !favIdsToRemove.isEmpty {
            favoriteServices = favoriteServices.filter { !favIdsToRemove.contains($0.id) }
            persistenceService.saveFavoriteServices(favoriteServices)
        }
    }

    // MARK: - Lifecycle

    init() {
        favoriteServices = persistenceService.loadFavoriteServices()
    }

    func startMonitoring() {
        pollingTask?.cancel()
        pollingTask = Task {
            while !Task.isCancelled {
                await refresh()
                try? await Task.sleep(for: .seconds(3))
            }
        }
    }

    func stopMonitoring() {
        pollingTask?.cancel()
        pollingTask = nil
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let discovered = try await discoveryService.discoverListeningProcesses()
            let existingById = Dictionary(processes.map { ($0.id, $0) }, uniquingKeysWith: { a, _ in a })

            var merged: [ServerProcess] = []

            for item in discovered {
                if let existing = existingById[item.id] {
                    merged.append(existing)
                } else {
                    merged.append(item)
                }
            }

            processes = merged
            persistenceService.saveSessions(merged)
            errorMessage = nil
            hasCompletedInitialLoad = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Process Actions

    func terminateProcess(_ process: ServerProcess) {
        do {
            try terminationService.terminate(pid: process.pid)
        } catch {
            errorMessage = error.localizedDescription
            return
        }

        processes.removeAll { $0.id == process.id }

        // 终止主进程时同时终止所有子进程
        let portGroups = Dictionary(grouping: processes, by: \.port)
        if let groupProcs = portGroups[process.port] {
            let pidsInGroup = Set(groupProcs.map(\.pid))
            let mainCandidates = groupProcs.filter { proc in
                let isParentOfOthers = groupProcs.contains { other in
                    other.ppid == proc.pid && other.pid != proc.pid
                }
                if isParentOfOthers { return true }
                return !pidsInGroup.contains(proc.ppid)
            }

            // 如果被终止的进程是主进程，终止所有子进程
            let isMainProcess: Bool
            if mainCandidates.contains(where: { $0.pid == process.pid }) {
                isMainProcess = true
            } else {
                // 检查是否有进程的 ppid 等于被终止进程的 pid
                isMainProcess = processes.contains { $0.ppid == process.pid }
            }

            if isMainProcess {
                let childProcesses = processes.filter { $0.ppid == process.pid || ($0.port == process.port && $0.pid != process.pid) }
                for child in childProcesses {
                    try? terminationService.terminate(pid: child.pid)
                }
                processes.removeAll { $0.port == process.port && $0.pid != process.pid }
            }
        }

        if process.pgid > 0 {
            let remainingSiblings = processes.contains { $0.pgid == process.pgid }
            if !remainingSiblings {
                try? terminationService.terminate(pid: process.pgid)
            }
        }
    }

    func openInBrowser(_ process: ServerProcess) {
        guard let url = process.localURL else { return }
        NSWorkspace.shared.open(url)
    }

    // MARK: - Favorites

    func addFavorite(_ favorite: FavoriteService) {
        favoriteServices.append(favorite)
        persistenceService.saveFavoriteServices(favoriteServices)
    }

    func removeFavorite(_ favorite: FavoriteService) {
        favoriteServices = favoriteServices.filter { $0.id != favorite.id }
        persistenceService.saveFavoriteServices(favoriteServices)
    }

    func updateFavorite(_ favorite: FavoriteService) {
        guard let index = favoriteServices.firstIndex(where: { $0.id == favorite.id }) else { return }
        favoriteServices[index] = favorite
        persistenceService.saveFavoriteServices(favoriteServices)
    }

    func addFavoriteFromProcess(_ process: ServerProcess) -> FavoriteService {
        let favorite = FavoriteService(
            name: process.name,
            workingDirectory: process.workingDirectory ?? "",
            startCommand: process.command,
            port: process.port
        )
        favoriteServices.append(favorite)
        persistenceService.saveFavoriteServices(favoriteServices)
        return favorite
    }

    // MARK: - Launch

    func launchService(_ favorite: FavoriteService) {
        do {
            try launchService.launch(workingDirectory: favorite.workingDirectory, startCommand: favorite.startCommand)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func launchServiceInBackground(_ favorite: FavoriteService) {
        do {
            try launchService.launchInBackground(
                workingDirectory: favorite.workingDirectory,
                startCommand: favorite.startCommand,
                serviceName: favorite.name
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Grouping Helpers

    private func appendServiceAndChildren(
        item: (id: String, favorite: FavoriteService?, mainProcess: ServerProcess?, childProcesses: [ServerProcess], workingDirectory: String?),
        groupKey: String?,
        to displayItems: inout [DisplayItem]
    ) {
        let isChildrenCollapsed = collapsedChildren.contains(item.id)
        let serviceRow = ServiceRowItem(
            id: item.id,
            favorite: item.favorite,
            mainProcess: item.mainProcess,
            childProcesses: item.childProcesses,
            isChildrenCollapsed: isChildrenCollapsed,
            groupKey: groupKey
        )
        displayItems.append(.serviceRow(serviceRow))

        if !item.childProcesses.isEmpty && !isChildrenCollapsed {
            for childProc in item.childProcesses {
                let childItem = ChildProcessItem(
                    id: "child-\(childProc.id)",
                    process: childProc,
                    parentServiceId: item.id,
                    groupKey: groupKey
                )
                displayItems.append(.childProcessRow(childItem))
            }
        }
    }

    private func detectProjectRoot(for directory: String) -> String {
        let url = URL(fileURLWithPath: directory)
        return url.lastPathComponent
    }

    private func resolveGroupName(workingDirectory: String?, favorite: FavoriteService?) -> String {
        if let pname = favorite?.projectName, !pname.isEmpty {
            return pname
        }
        let dir = workingDirectory ?? favorite?.workingDirectory ?? ""
        if dir.isEmpty { return "Other" }
        return detectProjectRoot(for: dir)
    }
}

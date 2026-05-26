import SwiftUI

struct MainView: View {
    var viewModel: ProcessMonitorViewModel
    @State private var searchText = ""
    @State private var showSearch = false
    @State private var showAddService = false
    @FocusState private var isSearchFocused: Bool
    @State private var editingFavorite: FavoriteService?
    @State private var editingGroup: ProcessMonitorViewModel.ProjectGroup?
    @Environment(ThemeSettings.self) private var themeSettings

    private var theme: HarborColors { themeSettings.colors }

    private var filteredItems: [ProcessMonitorViewModel.DisplayItem] {
        let items = viewModel.serviceListItems
        guard !searchText.isEmpty else { return items }
        let query = searchText.lowercased()

        // 找出匹配的 serviceRow 的 id
        var matchedServiceIds: Set<String> = []
        for item in items {
            if case .serviceRow(let service) = item {
                let nameMatch = service.displayName.lowercased().contains(query)
                let portMatch = service.displayPort.map { String($0).contains(query) } ?? false
                let cmdMatch = service.favorite?.startCommand.lowercased().contains(query) ?? false
                if nameMatch || portMatch || cmdMatch {
                    matchedServiceIds.insert(service.id)
                }
            }
        }

        // 保留匹配的 serviceRow 及其对应的 projectHeader 和 childProcessRow
        var result: [ProcessMonitorViewModel.DisplayItem] = []
        var currentGroupDir: String? = nil
        var groupHasMatch = false

        for item in items {
            switch item {
            case .projectHeader(let group):
                currentGroupDir = group.directory
                groupHasMatch = false
                // 先不添加，等看组内是否有匹配
            case .serviceRow(let service):
                if matchedServiceIds.contains(service.id) {
                    if !groupHasMatch, let dir = currentGroupDir {
                        // 添加组头
                        if let headerItem = items.first(where: { if case .projectHeader(let g) = $0, g.directory == dir { return true }; return false }) {
                            result.append(headerItem)
                        }
                        groupHasMatch = true
                    }
                    result.append(item)
                }
            case .childProcessRow(let child):
                if matchedServiceIds.contains(child.parentServiceId) {
                    result.append(item)
                }
            }
        }

        return result
    }

    private var themeIcon: String {
        switch themeSettings.mode {
        case .system: "circle.lefthalf.filled"
        case .light: "sun.max"
        case .dark: "moon"
        }
    }

    private var themeTooltip: String {
        switch themeSettings.mode {
        case .system: "Theme: System (click to switch)"
        case .light: "Theme: Light (click to switch)"
        case .dark: "Theme: Dark (click to switch)"
        }
    }

    private var activeCount: Int {
        viewModel.processes.filter { $0.status == .active }.count
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().overlay(theme.border)

            if !viewModel.hasCompletedInitialLoad {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.processes.isEmpty && viewModel.favoriteServices.isEmpty {
                EmptyStateView()
            } else {
                processListContent
            }

            if let error = viewModel.errorMessage {
                errorBanner(error)
            }
        }
        .background(.ultraThinMaterial)
        .environment(\.theme, themeSettings.colors)
        .task {
            viewModel.startMonitoring()
        }
        .sheet(isPresented: $showAddService) {
            AddServiceView { favorite in
                viewModel.addFavorite(favorite)
            }
            .environment(themeSettings)
        }
        .sheet(item: $editingFavorite) { favorite in
            AddServiceView(
                onAdd: { _ in },
                onEdit: { updated in
                    viewModel.updateFavorite(updated)
                },
                editingFavorite: favorite
            )
            .environment(themeSettings)
        }
        .sheet(item: $editingGroup) { group in
            GroupEditSheet(group: group, viewModel: viewModel, themeSettings: themeSettings)
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Harbor")
                    .font(.system(size: 15, weight: .bold, design: .default))
                    .foregroundStyle(theme.textPrimary)

                HStack(spacing: 6) {
                    Circle()
                        .fill(activeCount > 0 ? theme.accent : theme.textTertiary)
                        .frame(width: 6, height: 6)

                    Text(
                        activeCount > 0
                            ? "\(activeCount) active server\(activeCount == 1 ? "" : "s")"
                            : "No active server"
                    )
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(theme.textSecondary)
                }
            }

            Spacer()

            HStack(spacing: 4) {
                // Filter button / search
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        if showSearch && !searchText.isEmpty {
                            searchText = ""
                        }
                        showSearch.toggle()
                    }
                }) {
                    Image(systemName: showSearch ? "xmark" : "magnifyingglass")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(theme.textSecondary)
                        .frame(width: 28, height: 28)
                        .background(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(theme.accent.opacity(0.08))
                        )
                }
                .buttonStyle(.plain)
                .help(showSearch ? "Close search" : "Filter services")

                if showSearch {
                    HStack(spacing: 4) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(theme.textTertiary)

                        TextField("Filter", text: $searchText)
                            .textFieldStyle(.plain)
                            .font(.system(size: 11.5, weight: .regular))
                            .foregroundStyle(theme.textPrimary)
                            .focused($isSearchFocused)
                            .frame(width: 80)
                            .onKeyPress(.escape) {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    searchText = ""
                                    showSearch = false
                                }
                                return .handled
                            }
                            .onChange(of: isSearchFocused) { oldValue, newValue in
                                if !newValue && showSearch {
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        searchText = ""
                                        showSearch = false
                                    }
                                }
                            }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(theme.accent.opacity(0.08))
                    )
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.8, anchor: .leading)),
                        removal: .opacity.combined(with: .scale(scale: 0.8, anchor: .leading))
                    ))
                }

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        switch themeSettings.mode {
                        case .system: themeSettings.mode = .light
                        case .light: themeSettings.mode = .dark
                        case .dark: themeSettings.mode = .system
                        }
                    }
                }) {
                    Image(systemName: themeIcon)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(theme.textSecondary)
                        .frame(width: 28, height: 28)
                        .background(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(theme.accent.opacity(0.08))
                        )
                }
                .buttonStyle(.plain)
                .help(themeTooltip)

                Button(action: { showAddService = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(theme.textSecondary)
                        .frame(width: 28, height: 28)
                        .background(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(theme.accent.opacity(0.08))
                        )
                }
                .buttonStyle(.plain)
                .help("Add Service")

                Button(action: { Task { await viewModel.refresh() } }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(theme.textSecondary)
                        .frame(width: 28, height: 28)
                        .background(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(theme.accent.opacity(0.08))
                        )
                }
                .buttonStyle(.plain)
                .help("Refresh")

                Button(action: { NSApplication.shared.terminate(nil) }) {
                    Image(systemName: "power")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(theme.textSecondary)
                        .frame(width: 28, height: 28)
                        .background(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(theme.accent.opacity(0.08))
                        )
                }
                .buttonStyle(.plain)
                .help("Quit Harbor")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var processListContent: some View {
        ScrollView {
            LazyVStack(spacing: 6) {
                ForEach(filteredItems) { displayItem in
                    ServiceListRowView(
                        displayItem: displayItem,
                        onToggleGroup: { directory in
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                viewModel.toggleGroupCollapse(directory)
                            }
                        },
                        onToggleChildren: { serviceId in
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                viewModel.toggleChildrenCollapse(serviceId)
                            }
                        },
                        onTerminate: { process in
                            withAnimation(.easeOut(duration: 0.25)) {
                                viewModel.terminateProcess(process)
                            }
                        },
                        onOpenURL: { process in
                            viewModel.openInBrowser(process)
                        },
                        onLaunch: { favorite in
                            viewModel.launchService(favorite)
                        },
                        onLaunchBackground: { favorite in
                            viewModel.launchServiceInBackground(favorite)
                        },
                        onRemoveFavorite: { favorite in
                            withAnimation(.easeOut(duration: 0.25)) {
                                viewModel.removeFavorite(favorite)
                            }
                        },
                        onFavorite: { process in
                            withAnimation(.easeOut(duration: 0.25)) {
                                let fav = viewModel.addFavoriteFromProcess(process)
                                editingFavorite = fav
                            }
                        },
                        onEdit: { favorite in
                            editingFavorite = favorite
                        },
                        onEditGroup: { group in
                            editingGroup = group
                        },
                        onFavoriteGroup: { group in
                            if group.isAllFavorited {
                                viewModel.unfavoriteGroupServices(group.directory)
                            } else {
                                let newFavs = viewModel.favoriteGroupServices(group.directory)
                                if let firstFav = newFavs.first {
                                    editingFavorite = firstFav
                                }
                            }
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity.combined(with: .scale(scale: 0.95))
                    ))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
        }
        .animation(.easeInOut(duration: 0.3), value: filteredItems.map(\.id))
    }

    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(theme.warning)

            Text(message)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(theme.textSecondary)
                .lineLimit(1)

            Spacer()

            Button(action: { viewModel.errorMessage = nil }) {
                Image(systemName: "xmark")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(theme.textTertiary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(theme.warning.opacity(0.08))
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

struct GroupEditSheet: View {
    let group: ProcessMonitorViewModel.ProjectGroup
    let viewModel: ProcessMonitorViewModel
    let themeSettings: ThemeSettings

    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var directory: String = ""

    private var theme: HarborColors { themeSettings.colors }

    var body: some View {
        VStack(spacing: 16) {
            Text("Edit Group")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(theme.textPrimary)

            VStack(alignment: .leading, spacing: 8) {
                Text("Project Name")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(theme.textSecondary)

                TextField("Project Name", text: $name)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(theme.textPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(theme.surfaceRaised)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .strokeBorder(theme.border.opacity(0.5), lineWidth: 0.5)
                    )
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Directory")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(theme.textSecondary)

                TextField("Directory", text: $directory)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(theme.textPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(theme.surfaceRaised)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .strokeBorder(theme.border.opacity(0.5), lineWidth: 0.5)
                    )
            }

            HStack {
                Spacer()

                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.plain)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(theme.textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 7)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(theme.surfaceHover)
                )

                Button("Save") {
                    if name != group.name {
                        viewModel.renameGroup(group.directory, to: name)
                    }
                    if directory != group.directory {
                        viewModel.updateGroupDirectory(group.directory, to: directory)
                    }
                    dismiss()
                }
                .buttonStyle(.plain)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 7)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(theme.accent)
                )
            }
        }
        .padding(20)
        .frame(width: 300)
        .background(theme.surface)
        .onAppear {
            name = group.name
            directory = group.directory
        }
    }
}

import SwiftUI

// MARK: - ServiceListRowView (Dispatcher)

struct ServiceListRowView: View {
    let displayItem: ProcessMonitorViewModel.DisplayItem
    let onToggleGroup: (String) -> Void
    let onToggleChildren: (String) -> Void
    let onTerminate: (ServerProcess) -> Void
    let onOpenURL: (ServerProcess) -> Void
    let onLaunch: (FavoriteService) -> Void
    let onLaunchBackground: (FavoriteService) -> Void
    let onRemoveFavorite: (FavoriteService) -> Void
    let onFavorite: (ServerProcess) -> Void
    let onEdit: (FavoriteService) -> Void

    var body: some View {
        switch displayItem {
        case .projectHeader(let group):
            ProjectGroupHeaderView(group: group, onToggle: onToggleGroup)
        case .serviceRow(let item):
            ServiceRowContent(
                item: item,
                onToggleChildren: onToggleChildren,
                onTerminate: onTerminate,
                onOpenURL: onOpenURL,
                onLaunch: onLaunch,
                onLaunchBackground: onLaunchBackground,
                onRemoveFavorite: onRemoveFavorite,
                onFavorite: onFavorite,
                onEdit: onEdit
            )
        case .childProcessRow(let item):
            ChildProcessRowView(item: item, onTerminate: onTerminate)
        }
    }
}

// MARK: - ProjectGroupHeaderView

struct ProjectGroupHeaderView: View {
    let group: ProcessMonitorViewModel.ProjectGroup
    let onToggle: (String) -> Void

    @Environment(\.theme) private var theme

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "folder.fill")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(theme.accent.opacity(0.7))

            Text(group.name)
                .font(.system(size: 12, weight: .bold, design: .default))
                .foregroundStyle(theme.textPrimary)

            Spacer()

            Text("\(group.serviceCount) service\(group.serviceCount == 1 ? "" : "s")")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(theme.textTertiary)

            Image(systemName: group.isCollapsed ? "chevron.right" : "chevron.down")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(theme.textTertiary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(theme.surfaceRaised)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(theme.border.opacity(0.4), lineWidth: 0.5)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.25)) {
                onToggle(group.directory)
            }
        }
    }
}

// MARK: - ServiceRowContent

struct ServiceRowContent: View {
    let item: ProcessMonitorViewModel.ServiceRowItem
    let onToggleChildren: (String) -> Void
    let onTerminate: (ServerProcess) -> Void
    let onOpenURL: (ServerProcess) -> Void
    let onLaunch: (FavoriteService) -> Void
    let onLaunchBackground: (FavoriteService) -> Void
    let onRemoveFavorite: (FavoriteService) -> Void
    let onFavorite: (ServerProcess) -> Void
    let onEdit: (FavoriteService) -> Void

    @Environment(\.theme) private var theme
    @State private var isHovered = false
    @State private var isTerminateHovered = false
    @State private var isOpenHovered = false
    @State private var isLaunchHovered = false
    @State private var isLaunchBgHovered = false
    @State private var isStarHovered = false
    @State private var isEditHovered = false
    @State private var isChevronHovered = false

    enum ConfirmKind {
        case terminate
        case unfavorite
    }
    @State private var confirmKind: ConfirmKind? = nil

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                statusIcon

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(item.displayName)
                            .font(.system(size: 13, weight: .semibold, design: .default))
                            .foregroundStyle(
                                item.isRunning ? theme.textPrimary : theme.textSecondary
                            )

                        if !item.childProcesses.isEmpty {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    onToggleChildren(item.id)
                                }
                            }) {
                                HStack(spacing: 3) {
                                    Image(systemName: item.isChildrenCollapsed ? "chevron.right" : "chevron.down")
                                        .font(.system(size: 9, weight: .semibold))
                                        .foregroundStyle(isChevronHovered ? theme.textSecondary : theme.textTertiary)

                                    Text("\(item.childProcesses.count) process\(item.childProcesses.count == 1 ? "" : "es")")
                                        .font(.system(size: 9.5, weight: .medium))
                                        .foregroundStyle(theme.textTertiary)
                                }
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                                        .fill(isChevronHovered ? theme.surfaceHover : theme.surface)
                                )
                            }
                            .buttonStyle(.plain)
                            .onHover { h in withAnimation(.easeOut(duration: 0.12)) { isChevronHovered = h } }
                        }
                    }

                    detailLine
                }

                Spacer()

                actionArea
            }

            if confirmKind != nil {
                confirmBar
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(
                    confirmKind != nil
                        ? (confirmKind == .terminate ? theme.danger.opacity(0.06) : theme.accent.opacity(0.06))
                        : isHovered ? theme.surfaceHover : theme.surfaceRaised
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(
                    confirmKind != nil
                        ? (confirmKind == .terminate ? theme.danger.opacity(0.3) : theme.accent.opacity(0.3))
                        : isHovered ? theme.border.opacity(0.8) : theme.border.opacity(0.4),
                    lineWidth: 0.5
                )
        )
        .contentShape(Rectangle())
        .help(tooltipText)
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .overlay(alignment: .leading) {
            if item.isRunning {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(theme.accent)
                    .frame(width: 2.5)
                    .padding(.vertical, 4)
            }
        }
        .opacity(item.isFavorite && !item.isRunning ? 0.6 : 1.0)
    }

    private var statusIcon: some View {
        Group {
            if item.isFavorite {
                Button(action: {
                    withAnimation(.easeOut(duration: 0.2)) { confirmKind = .unfavorite }
                }) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(isStarHovered ? theme.accent.opacity(0.6) : theme.accent)
                        .frame(width: 20, height: 20)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .onHover { h in withAnimation(.easeOut(duration: 0.12)) { isStarHovered = h } }
                .help("Remove from favorites")
            } else if item.mainProcess != nil {
                Button(action: {
                    if let proc = item.mainProcess {
                        onFavorite(proc)
                    }
                }) {
                    Image(systemName: "star")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(isStarHovered ? theme.accent : theme.textTertiary)
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(.plain)
                .onHover { h in withAnimation(.easeOut(duration: 0.12)) { isStarHovered = h } }
                .help("Add to favorites")
            } else {
                Circle()
                    .strokeBorder(theme.textTertiary, lineWidth: 1.5)
                    .frame(width: 8, height: 8)
            }
        }
    }

    private var detailLine: some View {
        HStack(spacing: 6) {
            if item.isFavorite && !item.isRunning {
                Text(item.favorite!.startCommand)
                    .font(.system(size: 10.5, weight: .medium, design: .monospaced))
                    .foregroundStyle(theme.textTertiary)
            }

            if let proc = item.mainProcess {
                portBadge(for: proc)

                Text(verbatim: "PID \(proc.pid)")
                    .font(.system(size: 10.5, weight: .medium, design: .monospaced))
                    .foregroundStyle(theme.textTertiary)
            }
        }
    }

    private var actionArea: some View {
        Group {
            if item.isRunning {
                runningActionButtons
            } else if item.isFavorite {
                idleFavoriteButtons
            } else {
                EmptyView()
            }
        }
    }

    private var runningActionButtons: some View {
        HStack(spacing: 4) {
            if let proc = item.mainProcess {
                Button(action: { onOpenURL(proc) }) {
                    Image(systemName: "arrow.up.right.square")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(isOpenHovered ? theme.accent : theme.textSecondary)
                        .frame(width: 30, height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 7, style: .continuous)
                                .fill(isOpenHovered ? theme.accent.opacity(0.12) : .clear)
                        )
                }
                .buttonStyle(.plain)
                .onHover { h in withAnimation(.easeOut(duration: 0.12)) { isOpenHovered = h } }
                .help("Open localhost:\(proc.port)")

                if item.isFavorite {
                    Button(action: {
                        if let fav = item.favorite { onEdit(fav) }
                    }) {
                        Image(systemName: "pencil.circle")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(isEditHovered ? theme.accent : theme.textSecondary)
                            .frame(width: 30, height: 30)
                            .background(
                                RoundedRectangle(cornerRadius: 7, style: .continuous)
                                    .fill(isEditHovered ? theme.accent.opacity(0.12) : .clear)
                            )
                    }
                    .buttonStyle(.plain)
                    .onHover { h in withAnimation(.easeOut(duration: 0.12)) { isEditHovered = h } }
                    .help("Edit service")
                }

                Button(action: {
                    withAnimation(.easeOut(duration: 0.2)) { confirmKind = .terminate }
                }) {
                    Image(systemName: "stop.circle")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(
                            isTerminateHovered ? theme.danger : theme.textSecondary
                        )
                        .frame(width: 30, height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 7, style: .continuous)
                                .fill(isTerminateHovered ? theme.danger.opacity(0.12) : .clear)
                        )
                }
                .buttonStyle(.plain)
                .onHover { h in withAnimation(.easeOut(duration: 0.12)) { isTerminateHovered = h } }
                .help("Terminate process")
            }
        }
        .opacity(isHovered ? 1 : 0.5)
    }

    private var idleFavoriteButtons: some View {
        HStack(spacing: 4) {
            Button(action: {
                if let fav = item.favorite { onLaunch(fav) }
            }) {
                Image(systemName: "apple.terminal")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(isLaunchHovered ? theme.accent : theme.textSecondary)
                    .frame(width: 30, height: 30)
                    .background(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(isLaunchHovered ? theme.accent.opacity(0.12) : .clear)
                    )
            }
            .buttonStyle(.plain)
            .onHover { h in withAnimation(.easeOut(duration: 0.12)) { isLaunchHovered = h } }
            .help("Launch in Terminal")

            Button(action: {
                if let fav = item.favorite { onLaunchBackground(fav) }
            }) {
                Image(systemName: "play.fill")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(theme.accent)
                    .frame(width: 30, height: 30)
                    .background(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(isLaunchBgHovered ? theme.accent.opacity(0.12) : theme.accent.opacity(0.12))
                    )
            }
            .buttonStyle(.plain)
            .onHover { h in withAnimation(.easeOut(duration: 0.12)) { isLaunchBgHovered = h } }
            .help("Launch in Background")

            Button(action: {
                if let fav = item.favorite { onEdit(fav) }
            }) {
                Image(systemName: "pencil.circle")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(isEditHovered ? theme.accent : theme.textSecondary)
                    .frame(width: 30, height: 30)
                    .background(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(isEditHovered ? theme.accent.opacity(0.12) : .clear)
                    )
            }
            .buttonStyle(.plain)
            .onHover { h in withAnimation(.easeOut(duration: 0.12)) { isEditHovered = h } }
            .help("Edit service")
        }
        .opacity(isHovered ? 1 : 0.5)
    }

    private var confirmBar: some View {
        HStack(spacing: 8) {
            Text(confirmMessage)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(theme.textSecondary)
                .lineLimit(1)

            Spacer()

            Button(action: {
                withAnimation(.easeOut(duration: 0.2)) { confirmKind = nil }
            }) {
                Text("Cancel")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(theme.textSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(theme.surfaceHover)
                    )
            }
            .buttonStyle(.plain)

            Button(action: {
                let kind = confirmKind
                withAnimation(.easeOut(duration: 0.2)) { confirmKind = nil }
                switch kind {
                case .terminate:
                    if let proc = item.mainProcess { onTerminate(proc) }
                case .unfavorite:
                    if let fav = item.favorite { onRemoveFavorite(fav) }
                case nil:
                    break
                }
            }) {
                Text(confirmActionLabel)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(confirmKind == .terminate ? theme.danger : theme.accent)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 10)
    }

    private var confirmMessage: String {
        switch confirmKind {
        case .terminate:
            if let proc = item.mainProcess {
                return "Stop \(item.displayName) on port \(proc.port)?"
            }
            return "Stop \(item.displayName)?"
        case .unfavorite:
            return "Remove \(item.displayName) from favorites?"
        case nil:
            return ""
        }
    }

    private var confirmActionLabel: String {
        switch confirmKind {
        case .terminate: return "Terminate"
        case .unfavorite: return "Remove"
        case nil: return ""
        }
    }

    private func portBadge(for proc: ServerProcess) -> some View {
        Text(verbatim: "Port \(proc.port)")
            .font(.system(size: 10.5, weight: .semibold, design: .monospaced))
            .foregroundStyle(
                proc.status == .active ? theme.accent : theme.textTertiary
            )
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(
                        proc.status == .active
                            ? theme.accent.opacity(0.12)
                            : theme.textTertiary.opacity(0.08)
                    )
            )
    }

    private func abbreviatedPath(_ path: String) -> String {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        if path.hasPrefix(home) {
            return "~" + path.dropFirst(home.count)
        }
        return path
    }

    private var tooltipText: String {
        var parts: [String] = []

        if item.isFavorite, let fav = item.favorite {
            parts.append("Command: \(fav.startCommand)")
            if !fav.workingDirectory.isEmpty {
                parts.append("Dir: \(abbreviatedPath(fav.workingDirectory))")
            }
        }

        if let proc = item.mainProcess {
            parts.append("Process: \(proc.command)")
            parts.append("PID: \(proc.pid)")
            parts.append("Port: \(proc.port)")
        }

        return parts.isEmpty ? item.displayName : parts.joined(separator: "\n")
    }
}

// MARK: - ChildProcessRowView

struct ChildProcessRowView: View {
    let item: ProcessMonitorViewModel.ChildProcessItem
    let onTerminate: (ServerProcess) -> Void

    @Environment(\.theme) private var theme
    @State private var isHovered = false
    @State private var isTerminateHovered = false

    var body: some View {
        HStack(spacing: 0) {
            // Indent connection line
            Rectangle()
                .fill(theme.border.opacity(0.4))
                .frame(width: 1.5)
                .padding(.leading, 24)
                .padding(.trailing, 8)

            HStack(spacing: 10) {
                // Small dot indicator
                Circle()
                    .fill(theme.textTertiary.opacity(0.5))
                    .frame(width: 5, height: 5)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.process.name)
                        .font(.system(size: 12, weight: .medium, design: .default))
                        .foregroundStyle(theme.textSecondary)

                    Text(verbatim: "PID \(item.process.pid)")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundStyle(theme.textTertiary)
                }

                Spacer()

                // Terminate button (visible on hover)
                Button(action: {
                    onTerminate(item.process)
                }) {
                    Image(systemName: "xmark.circle")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(isTerminateHovered ? theme.danger : theme.textTertiary)
                        .frame(width: 24, height: 24)
                        .background(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(isTerminateHovered ? theme.danger.opacity(0.12) : .clear)
                        )
                }
                .buttonStyle(.plain)
                .onHover { h in withAnimation(.easeOut(duration: 0.12)) { isTerminateHovered = h } }
                .help("Terminate child process")
                .opacity(isHovered ? 1 : 0)
            }
            .padding(.trailing, 14)
        }
        .padding(.leading, 28)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(isHovered ? theme.surfaceHover.opacity(0.6) : theme.surface.opacity(0.4))
        )
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

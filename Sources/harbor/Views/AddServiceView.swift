import SwiftUI

struct AddServiceView: View {
    let onAdd: (FavoriteService) -> Void
    var onEdit: (FavoriteService) -> Void = { _ in }
    var editingFavorite: FavoriteService? = nil

    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeSettings.self) private var themeSettings

    private var theme: HarborColors { themeSettings.colors }
    private var isEditing: Bool { editingFavorite != nil }

    @State private var name = ""
    @State private var workingDirectory = ""
    @State private var startCommand = ""
    @State private var detectedCommands: [ProjectManifestService.DetectedCommand] = []
    @State private var isDetecting = false
    @State private var isStarHovered = false
    @State private var projectName = ""

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
            && !workingDirectory.isEmpty
            && !startCommand.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().overlay(theme.border)
            formContent
            Divider().overlay(theme.border)
            footer
        }
        .frame(width: 380)
        .background(theme.surface)
        .environment(\.theme, theme)
        .onAppear {
            if let fav = editingFavorite {
                name = fav.name
                workingDirectory = fav.workingDirectory
                startCommand = fav.startCommand
                projectName = fav.projectName ?? ""
            }
        }
    }

    private var header: some View {
        HStack {
            Text(isEditing ? "Edit Service" : "Add Service")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(theme.textPrimary)

            Spacer()

            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(theme.textTertiary)
                    .frame(width: 22, height: 22)
                    .background(
                        Circle()
                            .fill(theme.surfaceRaised)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var formContent: some View {
        VStack(spacing: 14) {
            fieldGroup(label: "Working Directory") {
                HStack(spacing: 8) {
                    Text(workingDirectory.isEmpty ? "Select directory..." : abbreviatedPath(workingDirectory))
                        .font(.system(size: 11.5, weight: .regular, design: .monospaced))
                        .foregroundStyle(workingDirectory.isEmpty ? theme.textTertiary : theme.textPrimary)
                        .lineLimit(1)
                        .truncationMode(.middle)

                    Spacer()

                    Button(action: selectDirectory) {
                        Image(systemName: "folder")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(theme.accent)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(theme.surfaceRaised)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .strokeBorder(theme.border.opacity(0.5), lineWidth: 0.5)
                )
            }

            if !detectedCommands.isEmpty {
                fieldGroup(label: "Detected Commands") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(detectedCommands) { cmd in
                                Button(action: {
                                    startCommand = cmd.command
                                    if name.isEmpty {
                                        name = (workingDirectory as NSString).lastPathComponent
                                    }
                                }) {
                                    HStack(spacing: 4) {
                                        Text(cmd.source)
                                            .font(.system(size: 9, weight: .medium))
                                            .foregroundStyle(theme.textTertiary)

                                        Text(cmd.command)
                                            .font(.system(size: 10.5, weight: .medium, design: .monospaced))
                                            .foregroundStyle(theme.accent)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 5)
                                    .background(
                                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                                            .fill(theme.accent.opacity(0.08))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                                            .strokeBorder(theme.accent.opacity(0.2), lineWidth: 0.5)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }

            fieldGroup(label: "Start Command") {
                TextField("e.g. npm run dev", text: $startCommand)
                    .textFieldStyle(.plain)
                    .font(.system(size: 11.5, weight: .regular, design: .monospaced))
                    .foregroundStyle(theme.textPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(theme.surfaceRaised)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .strokeBorder(theme.border.opacity(0.5), lineWidth: 0.5)
                    )
            }

            fieldGroup(label: "Name") {
                TextField("Service name", text: $name)
                    .textFieldStyle(.plain)
                    .font(.system(size: 11.5, weight: .regular))
                    .foregroundStyle(theme.textPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(theme.surfaceRaised)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .strokeBorder(theme.border.opacity(0.5), lineWidth: 0.5)
                    )
            }

            fieldGroup(label: "Project Name") {
                TextField("Optional — leave empty to auto-detect", text: $projectName)
                    .textFieldStyle(.plain)
                    .font(.system(size: 11.5, weight: .regular))
                    .foregroundStyle(theme.textPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(theme.surfaceRaised)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .strokeBorder(theme.border.opacity(0.5), lineWidth: 0.5)
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var footer: some View {
        HStack {
            if isDetecting {
                ProgressView()
                    .controlSize(.small)
                Text("Detecting...")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(theme.textTertiary)
            }

            Spacer()

            Button(action: { dismiss() }) {
                Text("Cancel")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(theme.textSecondary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(theme.surfaceRaised)
                    )
            }
            .buttonStyle(.plain)

            Button(action: saveService) {
                Text(isEditing ? "Save" : "Add")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(isValid ? theme.accent : theme.accentDim)
                    )
            }
            .buttonStyle(.plain)
            .disabled(!isValid)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func fieldGroup<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.system(size: 10.5, weight: .semibold))
                .foregroundStyle(theme.textSecondary)
                .textCase(.uppercase)

            content()
        }
    }

    private func selectDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.title = "Select Project Directory"

        guard panel.runModal() == .OK, let url = panel.urls.first else { return }

        workingDirectory = url.path
        if name.isEmpty {
            name = url.lastPathComponent
        }

        detectCommands(in: url.path)
    }

    private func detectCommands(in directory: String) {
        isDetecting = true
        detectedCommands = []

        Task {
            let service = ProjectManifestService()
            let commands = await Task.detached {
                service.detectCommands(inDirectory: directory)
            }.value

            isDetecting = false
            detectedCommands = commands
        }
    }

    private func saveService() {
        if isEditing, let fav = editingFavorite {
            let updated = FavoriteService(
                id: fav.id,
                name: name.trimmingCharacters(in: .whitespaces),
                workingDirectory: workingDirectory,
                startCommand: startCommand.trimmingCharacters(in: .whitespaces),
                port: fav.port,
                projectName: projectName.trimmingCharacters(in: .whitespaces).isEmpty ? nil : projectName.trimmingCharacters(in: .whitespaces),
                createdAt: fav.createdAt
            )
            onEdit(updated)
        } else {
            let favorite = FavoriteService(
                name: name.trimmingCharacters(in: .whitespaces),
                workingDirectory: workingDirectory,
                startCommand: startCommand.trimmingCharacters(in: .whitespaces),
                port: nil,
                projectName: projectName.trimmingCharacters(in: .whitespaces).isEmpty ? nil : projectName.trimmingCharacters(in: .whitespaces)
            )
            onAdd(favorite)
        }
        dismiss()
    }

    private func abbreviatedPath(_ path: String) -> String {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        if path.hasPrefix(home) {
            return "~" + path.dropFirst(home.count)
        }
        return path
    }
}

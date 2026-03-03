// PermissionsView.swift
// In-app permission request UI shown when Accessibility / Input Monitoring is missing.

import SwiftUI

struct PermissionsView: View {

    @ObservedObject var viewModel: KeyboardViewModel

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "keyboard.badge.exclamationmark")
                .font(.system(size: 40))
                .foregroundColor(.yellow)

            Text("Global Key Capture Requires Permissions")
                .font(.headline)

            VStack(alignment: .leading, spacing: 10) {
                if viewModel.accessibilityStatus != .granted {
                    PermissionRow(
                        icon: "accessibility",
                        title: "Accessibility Access",
                        description: "Required to read global key events from any application.",
                        status: viewModel.accessibilityStatus,
                        action: {
                            PermissionsService.requestAccessibility()
                            PermissionsService.openAccessibilitySettings()
                        }
                    )
                }

                if viewModel.inputMonitoringStatus == .denied {
                    PermissionRow(
                        icon: "hand.raised.fill",
                        title: "Input Monitoring",
                        description: "Required on macOS 10.15+ to monitor keyboard events.",
                        status: viewModel.inputMonitoringStatus,
                        action: {
                            PermissionsService.requestInputMonitoring()
                            PermissionsService.openInputMonitoringSettings()
                        }
                    )
                }
            }
            .padding(.horizontal)

            HStack(spacing: 12) {
                Button("Retry Detection") {
                    withAnimation {
                        viewModel.checkPermissions()
                        if viewModel.hasRequiredPermissions {
                            viewModel.startCapture()
                        }
                    }
                }
                .buttonStyle(.borderedProminent)

                Button("Open System Settings") {
                    if viewModel.accessibilityStatus != .granted {
                        PermissionsService.openAccessibilitySettings()
                    } else {
                        PermissionsService.openInputMonitoringSettings()
                    }
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(24)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 20)
    }
}

// MARK: - Permission row

private struct PermissionRow: View {
    let icon: String
    let title: String
    let description: String
    let status: PermissionStatus
    let action: () -> Void

    var statusColor: Color {
        switch status {
        case .granted: return .green
        case .denied:  return .red
        case .unknown: return .yellow
        }
    }

    var statusText: String {
        switch status {
        case .granted: return "Granted"
        case .denied:  return "Denied"
        case .unknown: return "Not Determined"
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(statusColor)
                .frame(width: 10, height: 10)
                .padding(.top, 4)

            VStack(alignment: .leading, spacing: 2) {
                Text(title).fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button("Grant") { action() }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .disabled(status == .granted)
        }
        .padding(10)
        .background(Color.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    PermissionsView(viewModel: KeyboardViewModel())
        .frame(width: 500)
        .padding()
}

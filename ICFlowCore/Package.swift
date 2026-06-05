// swift-tools-version:5.9
import PackageDescription

// ICFlowCore contains all clinical content and decision logic for the IC Flow app.
// It is intentionally free of any UI framework (no SwiftUI/UIKit) so that the
// clinical engine can be unit tested in isolation and reused on any platform.
let package = Package(
    name: "ICFlowCore",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(name: "ICFlowCore", targets: ["ICFlowCore"])
    ],
    targets: [
        .target(
            name: "ICFlowCore",
            resources: [
                // Clinical content lives in JSON, bundled as a processed resource.
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "ICFlowCoreTests",
            dependencies: ["ICFlowCore"]
        )
    ]
)

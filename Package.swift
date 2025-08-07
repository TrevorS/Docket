// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Docket",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .executable(
            name: "Docket",
            targets: ["DocketApp"]
        ),
        .library(
            name: "DocketKit",
            targets: ["DocketKit"]
        )
    ],
    dependencies: [
        // Add external dependencies here as needed
    ],
    targets: [
        // Main executable target
        .executableTarget(
            name: "DocketApp",
            dependencies: ["DocketKit"],
            exclude: [
                "Resources/Info.plist",
                "Resources/Docket.entitlements"
            ],
            resources: [
                .process("Resources/Assets.xcassets")
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        
        // Core business logic as library
        .target(
            name: "DocketKit",
            dependencies: [],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        
        // Unit tests for core logic
        .testTarget(
            name: "DocketKitTests",
            dependencies: ["DocketKit"],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        
        // Integration tests for the app
        .testTarget(
            name: "DocketAppTests", 
            dependencies: ["DocketApp", "DocketKit"],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        )
    ]
)
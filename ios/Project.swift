import ProjectDescription

let project = Project(
    name: "TruckeeTrash",
    targets: [
        // Main iOS App
        .target(
            name: "TruckeeTrash",
            destinations: .iOS,
            product: .app,
            bundleId: "com.truckeetrash.app",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchStoryboardName": "LaunchScreen",
                    "UISupportedInterfaceOrientations": [
                        "UIInterfaceOrientationPortrait"
                    ],
                    "CFBundleDisplayName": "Truckee Trash",
                    "CFBundleShortVersionString": "1.0",
                    "CFBundleVersion": "1"
                ]
            ),
            sources: ["Sources/App/**"],
            resources: ["Resources/**"],
            dependencies: [
                .target(name: "TruckeeTrashKit"),
                .target(name: "SettingsFeature"),
                .target(name: "NotificationsService"),
                .target(name: "TruckeeTrashWidget")
            ],
            settings: .settings(
                configurations: [
                    .debug(name: "Debug", settings: [
                        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) SIMULATOR_ONLY"
                    ]),
                    .release(name: "Release")
                ]
            )
        ),
        
        // Core Kit Framework
        .target(
            name: "TruckeeTrashKit",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.truckeetrash.kit",
            deploymentTargets: .iOS("17.0"),
            sources: ["Sources/TruckeeTrashKit/**"],
            dependencies: []
        ),
        
        // Settings Feature
        .target(
            name: "SettingsFeature",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.truckeetrash.settings",
            deploymentTargets: .iOS("17.0"),
            sources: ["Sources/SettingsFeature/**"],
            dependencies: [
                .target(name: "TruckeeTrashKit")
            ]
        ),
        
        // Notifications Service
        .target(
            name: "NotificationsService",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.truckeetrash.notifications",
            deploymentTargets: .iOS("17.0"),
            sources: ["Sources/NotificationsService/**"],
            dependencies: [
                .target(name: "TruckeeTrashKit")
            ]
        ),
        
        // Widget Extension
        .target(
            name: "TruckeeTrashWidget",
            destinations: .iOS,
            product: .appExtension,
            bundleId: "com.truckeetrash.app.widget",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(
                with: [
                    "CFBundleDisplayName": "Truckee Trash Widget",
                    "NSExtension": [
                        "NSExtensionPointIdentifier": "com.apple.widgetkit-extension"
                    ]
                ]
            ),
            sources: ["Sources/Widget/**"],
            dependencies: [
                .target(name: "TruckeeTrashKit")
            ]
        ),
        
        // Tests
        .target(
            name: "TruckeeTrashKitTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.truckeetrash.kit.tests",
            deploymentTargets: .iOS("17.0"),
            sources: ["Tests/TruckeeTrashKitTests/**"],
            dependencies: [
                .target(name: "TruckeeTrashKit")
            ]
        )
    ]
)
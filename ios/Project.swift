import ProjectDescription

let project = Project(
    name: "TruckeeTrash",
    targets: [
        // Main iOS App
        .target(
            name: "TruckeeTrash",
            destinations: .iOS,
            product: .app,
            bundleId: "com.guaranteed.truckeetrash",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchStoryboardName": "LaunchScreen",
                    "UISupportedInterfaceOrientations": [
                        "UIInterfaceOrientationPortrait"
                    ],
                    "CFBundleDisplayName": "Truckee Trash",
                    "CFBundleShortVersionString": "1.0",
                    "CFBundleVersion": "2"
                ]
            ),
            sources: ["Sources/App/**"],
            resources: ["Resources/**"],
            entitlements: .file(path: "Sources/App/TruckeeTrash.entitlements"),
            dependencies: [
                .target(name: "TruckeeTrashKit"),
                .target(name: "SettingsFeature"),
                .target(name: "NotificationsService"),
                .target(name: "TruckeeTrashWidget")
            ],
            settings: .settings(
                base: [
                    "DEVELOPMENT_TEAM": "43LEM8BQ2H",
                    "CODE_SIGN_STYLE": "Automatic"
                ],
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
            dependencies: [],
            settings: .settings(
                base: ["DEFINES_MODULE": "YES"]
            )
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
                .target(name: "TruckeeTrashKit"),
                .target(name: "NotificationsService")
            ],
            settings: .settings(
                base: ["DEFINES_MODULE": "YES"]
            )
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
            ],
            settings: .settings(
                base: ["DEFINES_MODULE": "YES"]
            )
        ),
        
        // Widget Extension
        .target(
            name: "TruckeeTrashWidget",
            destinations: .iOS,
            product: .appExtension,
            bundleId: "com.guaranteed.truckeetrash.widget",
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
            resources: ["Resources/**"],
            entitlements: .file(path: "Sources/Widget/TruckeeTrashWidget.entitlements"),
            dependencies: [
                .target(name: "TruckeeTrashKit")
            ],
            settings: .settings(
                base: [
                    "DEVELOPMENT_TEAM": "43LEM8BQ2H",
                    "CODE_SIGN_STYLE": "Automatic"
                ]
            )
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
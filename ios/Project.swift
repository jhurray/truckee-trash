import ProjectDescription

// MARK: - Project Configuration Constants

private let organizationName = "TruckeeTrash"
private let appBundleIdPrefix = "com.guaranteed.truckeetrash"
private let frameworkBundleIdPrefix = "com.truckeetrash"
private let deploymentTarget: DeploymentTargets = .iOS("17.0")
private let developmentTeam = "43LEM8BQ2H"
private let appVersion: Plist.Value = "1.0"
private let buildNumber: Plist.Value = "3"

// MARK: - Common Settings

private let codeSigningSettings: SettingsDictionary = [
    "DEVELOPMENT_TEAM": .string(developmentTeam),
    "CODE_SIGN_STYLE": "Automatic"
]

private let frameworkSettings = Settings.settings(
    base: ["DEFINES_MODULE": "YES"]
)

private let appSettings = Settings.settings(
    base: codeSigningSettings,
    configurations: [
        .debug(name: "Debug", settings: [
            "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) SIMULATOR_ONLY"
        ]),
        .release(name: "Release")
    ]
)

// MARK: - Helper Functions

private func makeFrameworkTarget(
    name: String,
    bundleIdSuffix: String,
    sources: SourceFilesList,
    dependencies: [TargetDependency] = []
) -> Target {
    return .target(
        name: name,
        destinations: .iOS,
        product: .framework,
        bundleId: "\(frameworkBundleIdPrefix).\(bundleIdSuffix)",
        deploymentTargets: deploymentTarget,
        sources: sources,
        dependencies: dependencies,
        settings: frameworkSettings
    )
}

private func makeTestTarget(
    name: String,
    bundleIdSuffix: String,
    sources: SourceFilesList,
    dependencies: [TargetDependency]
) -> Target {
    return .target(
        name: name,
        destinations: .iOS,
        product: .unitTests,
        bundleId: "\(frameworkBundleIdPrefix).\(bundleIdSuffix)",
        deploymentTargets: deploymentTarget,
        sources: sources,
        dependencies: dependencies
    )
}

// MARK: - Project Definition

let project = Project(
    name: organizationName,
    targets: [
        // Main iOS App
        .target(
            name: "TruckeeTrash",
            destinations: .iOS,
            product: .app,
            bundleId: appBundleIdPrefix,
            deploymentTargets: deploymentTarget,
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchStoryboardName": "LaunchScreen",
                    "UISupportedInterfaceOrientations": [
                        "UIInterfaceOrientationPortrait"
                    ],
                    "CFBundleDisplayName": "Truckee Trash",
                    "CFBundleShortVersionString": appVersion,
                    "CFBundleVersion": buildNumber
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
            settings: appSettings
        ),
        
        // Core Kit Framework
        makeFrameworkTarget(
            name: "TruckeeTrashKit",
            bundleIdSuffix: "kit",
            sources: ["Sources/TruckeeTrashKit/**"]
        ),
        
        // Settings Feature
        makeFrameworkTarget(
            name: "SettingsFeature",
            bundleIdSuffix: "settings",
            sources: ["Sources/SettingsFeature/**"],
            dependencies: [
                .target(name: "TruckeeTrashKit"),
                .target(name: "NotificationsService")
            ]
        ),
        
        // Notifications Service
        makeFrameworkTarget(
            name: "NotificationsService",
            bundleIdSuffix: "notifications",
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
            bundleId: "\(appBundleIdPrefix).widget",
            deploymentTargets: deploymentTarget,
            infoPlist: .extendingDefault(
                with: [
                    "CFBundleDisplayName": "Truckee Trash Widget",
                    "NSExtension": [
                        "NSExtensionPointIdentifier": "com.apple.widgetkit-extension"
                    ],
                    "CFBundleVersion": buildNumber
                ]
            ),
            sources: ["Sources/Widget/**"],
            resources: ["Resources/**"],
            entitlements: .file(path: "Sources/Widget/TruckeeTrashWidget.entitlements"),
            dependencies: [
                .target(name: "TruckeeTrashKit")
            ],
            settings: .settings(base: codeSigningSettings)
        ),
        
        // Tests
        makeTestTarget(
            name: "TruckeeTrashKitTests",
            bundleIdSuffix: "kit.tests",
            sources: ["Tests/TruckeeTrashKitTests/**"],
            dependencies: [
                .target(name: "TruckeeTrashKit")
            ]
        )
    ]
)
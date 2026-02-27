import ProjectDescription

let appSettings: Settings = .settings(
    base: [
        "SWIFT_VERSION": "5.0",
        "CURRENT_PROJECT_VERSION": "1",
        "MARKETING_VERSION": "1.0",
        "CODE_SIGN_STYLE": "Automatic",
    ]
)

let project = Project(
    name: "Stooge",
    targets: [

        // MARK: - Main App

        .target(
            name: "Stooge",
            destinations: .iOS,
            product: .app,
            bundleId: "com.designerGenes.Stooge",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(with: [
                "NSAppTransportSecurity": .dictionary([
                    "NSAllowsArbitraryLoads": .boolean(false),
                ]),
                "UIApplicationSceneManifest": .dictionary([
                    "UIApplicationSupportsMultipleScenes": .boolean(false),
                ]),
                "UIApplicationSupportsIndirectInputEvents": .boolean(true),
                "UILaunchScreen": .dictionary([:]),
                "UISupportedInterfaceOrientations": .array([
                    .string("UIInterfaceOrientationPortrait"),
                ]),
                "UISupportedInterfaceOrientations~ipad": .array([
                    .string("UIInterfaceOrientationLandscapeLeft"),
                    .string("UIInterfaceOrientationLandscapeRight"),
                    .string("UIInterfaceOrientationPortrait"),
                    .string("UIInterfaceOrientationPortraitUpsideDown"),
                ]),
            ]),
            // Stooge/**/*.swift already includes Stooge/Shared/StoogeAccessibility.swift
            sources: ["Stooge/**/*.swift"],
            resources: ["Stooge/Assets.xcassets"],
            settings: appSettings
        ),

        // MARK: - Embedded UI Tests (standard host-app runner)

        .target(
            name: "StoogeUITests",
            destinations: .iOS,
            product: .uiTests,
            bundleId: "com.designerGenes.StoogeUITests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["StoogeUITests/**/*.swift", "Stooge/Shared/**/*.swift"],
            dependencies: [
                .target(name: "Stooge"),
            ]
        ),

        // MARK: - Shadow Tests (external bundle-ID-based driver)
        //
        // This target demonstrates how a completely separate test suite can
        // drive Stooge without being embedded inside it. The test code uses:
        //
        //   XCUIApplication(bundleIdentifier: "com.designerGenes.Stooge")
        //
        // …instead of XCUIApplication(), which is all that separates "internal"
        // from "external" test orchestration. The shared a11y file is compiled
        // directly into this target so identifier constants stay in sync at
        // compile time — no copying, no string duplication, no silent drift.

        .target(
            name: "ShadowTests",
            destinations: .iOS,
            product: .uiTests,
            bundleId: "com.designerGenes.ShadowTests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["ShadowTests/**/*.swift", "Stooge/Shared/**/*.swift"],
            dependencies: [
                .target(name: "Stooge"),
            ]
        ),
    ]
)

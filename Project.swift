import ProjectDescription

let project = Project(
    name: "Stooge",
    targets: [
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
            sources: ["Stooge/**/*.swift"],
            resources: ["Stooge/Assets.xcassets"],
            settings: .settings(
                base: [
                    "SWIFT_VERSION": "5.0",
                    "CURRENT_PROJECT_VERSION": "1",
                    "MARKETING_VERSION": "1.0",
                    "CODE_SIGN_STYLE": "Automatic",
                ]
            )
        ),
        .target(
            name: "StoogeUITests",
            destinations: .iOS,
            product: .uiTests,
            bundleId: "com.designerGenes.StoogeUITests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["StoogeUITests/**/*.swift"],
            dependencies: [
                .target(name: "Stooge"),
            ]
        ),
    ]
)

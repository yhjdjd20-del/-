import PackageDescription

let package = Package(
    name: "CreatureGame",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .iOSApplication(
            name: "CreatureGame",
            targets: ["CreatureGame"],
            bundleIdentifier: "com.yourname.creaturegame",
            displayVersion: "1.0",
            bundleVersion: "1",
            iconAssetName: "AppIcon",
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "CreatureGame",
            path: "."
        )
    ]
)

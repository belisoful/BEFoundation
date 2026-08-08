// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BEFoundation",
    platforms: [
        .macOS(.v11),
        .iOS(.v14),
    ],
    products: [
        .library(name: "BEFoundation", targets: ["BEFoundation"]),
    ],
    targets: [
        .target(
            name: "BEFoundation",
            path: "Sources/BEFoundation",
            // The DocC catalog is built by `xcodebuild docbuild`, not by SwiftPM.
            exclude: ["BEFoundation.docc"],
            // Public API is include/BEFoundation/, so `#import <BEFoundation/Foo.h>` resolves
            // the same way it does against the built framework.
            publicHeadersPath: "include",
            cSettings: [
                // Xcode resolves the sources' quoted imports through header maps, which
                // SwiftPM does not build; these two paths give the same resolution.
                .headerSearchPath("include/BEFoundation"),
                .headerSearchPath("."),
            ],
            linkerSettings: [
                .linkedFramework("Accelerate"),
                .linkedFramework("CoreImage"),
                .linkedFramework("Metal"),
                .linkedFramework("AppKit", .when(platforms: [.macOS])),
                .linkedFramework("UIKit", .when(platforms: [.iOS])),
            ]
        ),
    ],
    cLanguageStandard: .gnu17,
    cxxLanguageStandard: .gnucxx20
)

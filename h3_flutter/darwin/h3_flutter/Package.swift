// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "h3_flutter",
    platforms: [
        .iOS("12.0"),
        .macOS("10.13"),
    ],
    products: [
        // Dynamic, so that every H3 symbol stays exported and can be found
        // by DynamicLibrary.process() at runtime.
        .library(name: "h3-flutter", type: .dynamic, targets: ["h3_flutter"])
    ],
    targets: [
        .target(
            name: "h3_flutter",
            exclude: [
                "h3lib/include/h3api.h.in"
            ],
            sources: [
                "h3lib/lib"
            ],
            cSettings: [
                .headerSearchPath("h3lib/include")
            ]
        )
    ]
)

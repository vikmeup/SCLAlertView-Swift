// swift-tools-version:5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package =   Package(
  name: "SCLAlertView",
  platforms: [.iOS(.v13)],
  products: [
    .library(name: "SCLAlertView", targets: ["SCLAlertView"]),
  ],
  targets: [
    .target(name: "SCLAlertView", path: "SCLAlertView"),
    .testTarget(
      name: "SCLAlertViewTests",
      dependencies: ["SCLAlertView"],
      path: "SCLAlertViewTests"
    )
  ],
  swiftLanguageVersions: [.v5]
)

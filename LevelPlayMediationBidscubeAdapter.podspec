Pod::Spec.new do |spec|
  spec.name         = "LevelPlayMediationBidscubeAdapter"
  spec.version      = "1.0.2"
  spec.summary      = "Bidscube LevelPlay custom adapter for iOS"
  spec.description  = <<-DESC
                      Source-based LevelPlay custom adapter for Bidscube on iOS (Swift).
                      Apple TV is not supported here: IronSourceSDK publishes an iOS slice only. BidscubeSDK itself supports tvOS.
                      Layout: manifest + placement helper + callbacks + ISBidscubeCustom{Adapter,Banner,Interstitial,RewardedVideo}.
                      Adapter version 1.0.2 is defined in LevelPlayMediationBidscubeAdapterManifest.swift (network SDK version from BidscubeSDK.Constants.sdkVersion).
                      DESC

  spec.homepage     = "https://github.com/BidsCube/LevelPlay-SDK-iOS"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Bidscube" => "dev@bidscube.com" }

  spec.platform     = :ios, "13.0"
  spec.ios.deployment_target = "13.0"
  spec.swift_versions = ["5.9"]

  spec.source       = { :git => "https://github.com/BidsCube/LevelPlay-SDK-iOS.git", :tag => "v#{spec.version}" }

  spec.source_files = "Sources/LevelPlayMediationBidscubeAdapter/**/*.swift"

  spec.dependency "BidscubeSDK", spec.version.to_s
  spec.dependency "IronSourceSDK", "9.3.0.0"
end

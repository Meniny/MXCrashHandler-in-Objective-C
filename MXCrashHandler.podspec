Pod::Spec.new do |s|

  s.name         = "MXCrashHandler"
  s.version      = "1.0.2"
  s.summary      = "An easy-to-use class to handle crash on iOS."

  s.description  = "The first version of MXCrashHandler, an easy-to-use class to handle crash on iOS. "

  s.homepage     = "https://github.com/Meniny/MXCrashHandler-in-Objective-C"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }

  # s.author             = { "Elias Abel" => "email@address.com" }
  s.author    = "Elias Abel"
  # s.authors            = { "Elias Abel" => "email@address.com" }
  # s.social_media_url   = "http://twitter.com/Elias Abel"

  # s.platform     = :ios
  s.platform     = :ios, "8.0"

  #  When using multiple platforms
  # s.ios.deployment_target = "5.0"
  # s.osx.deployment_target = "10.7"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/Meniny/MXCrashHandler-in-Objective-C.git", :tag => "#{s.version}" }

  s.source_files  = "MXCrashHandler/*"

  # s.public_header_files = "Classes/**/*.h"

  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"

  # s.framework  = "SomeFramework"
  s.frameworks = "Foundation", "UIKit"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"

  # s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"

end

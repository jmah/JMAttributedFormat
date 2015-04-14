#
#  Be sure to run `pod spec lint JMAttributedFormat.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "JMAttributedFormat"
  s.version      = "1.0.0"
  s.summary      = "Use format strings to localize NSAttributedString"

  s.description  = <<-DESC
                   This library adds functionality to create NSAttributedString
                   instances using a format string with format specifiers. Like
                   NSString, the format specifiers can change the order of
                   arguments, so your styled strings can be flexibly localized.
                   DESC

  s.homepage     = "https://github.com/jmah/JMAttributedFormat"


  s.license      = { :type => "MIT", :file => "LICENSE.txt" }


  s.author             = { "Jonathon Mah" => "me@JonathonMah.com" }
  s.social_media_url   = "http://twitter.com/dev_etc"

  s.source       = { :git => "https://github.com/jmah/JMAttributedFormat.git", :tag => "1.0.0" }

  s.source_files  = "JMAttributedFormat.{h,m}"

  s.requires_arc = true
end

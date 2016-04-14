
# $1 sepc name
# $2 version id (tag id)
# $3 git source 
# $4 spec dir


SPEC="Pod::Spec.new do |s| \n
  s.name             = \"$1\" \n
  s.version          = \"$2\" \n
  s.summary          = \"Netease IM SDK\" \n
  s.description      = <<-DESC Netease IM iOS SDK DESC
  s.homepage         = \"http://netease.im\" \n
  s.license          = { :\"type\" => \"Copyright\", :\"text\" => \" Copyright 2016 Netease \n\"} \n
  s.authors          = \"Netease IM Team\" \n
  s.source           = { :git => \"$3\", :tag => \"#{s.version}\"} \n

  s.platform     = :ios, '6.0' \n

  s.source_files = \"**/ExportHeaders/**/*.h\" \n
  s.vendored_libraries = \"**/lib#{s.name}.a\" \n
  s.frameworks = 'SystemConfiguration', 'AVFoundation', 'CoreTelephony', 'AudioToolbox', 'CoreMedia' \n
  s.libraries = 'sqlite3.0', 'z', 'stdc++.6.0.9' \n

end \n"

echo -e $SPEC >> $4/NIMSDK.podspec
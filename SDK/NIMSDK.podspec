Pod::Spec.new do |s| 
 s.name = "NIMSDK_NO_OPENSSL" 
 s.version = "1.0.0" 
 s.summary = "Netease IM SDK" 
 s.description = <<-DESC Netease IM iOS SDK DESC s.homepage = "http://netease.im" 
 s.license = { :"type" => "Copyright", :"text" => " Copyright 2016 Netease 
"} 
 s.authors = "Netease IM Team" 
 s.source = { :git => "git@github.com:netease-im/NIM_iOS_SDK_NO_OPENSSL.git", :tag => "#{s.version}"} 
 s.platform = :ios, '6.0' 
 s.source_files = "**/ExportHeaders/**/*.h" 
 s.vendored_libraries = "**/lib#{s.name}.a" 
 s.frameworks = 'SystemConfiguration', 'AVFoundation', 'CoreTelephony', 'AudioToolbox', 'CoreMedia' 
 s.libraries = 'sqlite3.0', 'z', 'stdc++.6.0.9' 
 end 

Pod::Spec.new do |s| 
 s.name = "NIMSDK_NO_OPENSSL" 
 s.version = "1.0.0" 
 s.summary = "Netease IM SDK" 
 s.description = <<-DESC Netease IM iOS SDK DESC s.homepage = "http://netease.im" 
 s.license = { :"type" => "Copyright", :"text" => " Copyright 2016 Netease 
"} 
 s.authors = "Netease IM Team" 
 s.source = { :git => "git@github.com:netease-im/NIM_iOS_SDK_NO_OPENSSL.git", :tag => "#{s.version}"} 
 s.platform = :ios, '6.0' 
 s.source_files = "**/ExportHeaders/**/*.h" 
 s.vendored_libraries = "**/lib#{s.name}.a" 
 s.frameworks = 'SystemConfiguration', 'AVFoundation', 'CoreTelephony', 'AudioToolbox', 'CoreMedia' 
 s.libraries = 'sqlite3.0', 'z', 'stdc++.6.0.9' 
 end 


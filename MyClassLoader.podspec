Pod::Spec.new do |s| 
  s.name         = "MyClassLoader"
  s.version      = "1.0.0"
  s.summary      = "Alternative to +load method"
  s.homepage     = "https://github.com/JJMM/MyClassLoader"
  s.license      = "Apache License, Version 2.0"
  s.authors      = { "JJMM" => "iosdes@163.com" }
  s.source       = { :git => "https://github.com/JJMM/MyClassLoader.git", :tag => "#{s.version}" }
  s.frameworks   = 'Foundation'
  s.platform     = :ios
  s.source_files = 'MyClassLoader/*'
  s.requires_arc = true
end


Pod::Spec.new do |s|

  s.name         = "YUTableView-Swift"
  s.version      = "1.0"
  s.summary      = "Adds expandable sub-menu support to UITableView."
  s.homepage     = "https://github.com/ujell/YUTableView-Swift"
  s.license      = { :type => "MIT"}
  s.author       = { "yücel" => "yuceluzun@windowslive.com" }
  s.platform     = :ios, "8.4"
  s.source       = { :git => "https://github.com/ujell/YUTableView-Swift.git", :tag => "1.0" }
  s.source_files = "YUTableView-Swift/YUTableView/*.swift"
  s.requires_arc = true

end

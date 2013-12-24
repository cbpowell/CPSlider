Pod::Spec.new do |s|
  s.name         = "CPSlider"
  s.version      = "1.0.1"
  s.summary      = "A drop-in, subclass replacement for UISlider with variable scrubbing speeds."
  s.homepage     = "https://github.com/cbpowell/CPSlider"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Charles Powell" => "cbpowell@gmail.com" }
  s.source       = { :git => "https://github.com/cbpowell/CPSlider.git", :tag => s.version.to_s }
  s.platform     = :ios, '4.3'
  s.source_files = 'CPSlider/*'
  s.requires_arc = true
end

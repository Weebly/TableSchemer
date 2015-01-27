Pod::Spec.new do |s|
  s.name         = "TableSchemer"
  s.version      = "1.1.1"
  s.summary      = "Interactive static table views with ease"

  s.description  = <<-DESC
TableSchemer is a framework for building static interactive table views. Interface Builder provides a great way to build out static table views, but not everyone uses interface builder, and adding interactivity to these table views is difficult. Writing interactive static table views traditionally is a tiresome task due to working with index paths, and having multiple delegate methods to handle configuration, sizing, and selection handling. They're also a huge pain to maintain when the need to reorder them comes as you need to update the index paths in all those locations.
                   DESC

  s.homepage     = "https://github.com/Weebly/TableSchemer"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "James Richard" => "james@weebly.com" }
  s.social_media_url   = "http://twitter.com/ketzusaka"
  s.platform = :ios, "8.0"
  s.source       = { :git => "https://github.com/Weebly/TableSchemer.git", :tag => "v1.1.1" }
  s.source_files  = "Sources"
  s.requires_arc = true
end

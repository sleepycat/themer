SPEC = Gem::Specification.new do |spec|
  # Descriptive and source information for this gem.
  spec.name = "themer"
  spec.version = "0.0.5"
  spec.description = "A script to prep FreeCSSTemplates for Eftplus"
  spec.summary = "Eftplus theme prep script."
  spec.author = "Mike Williamson"
  spec.email = "blessedbyvirtuosity@gmail.com"
  spec.homepage = "http://www.eftplus.co.nz"
  require 'rake'
  spec.files = Dir.glob("{lib}/themer/*") + %w(README lib/themer.rb themer.gemspec themer)
  spec.files.each{|f| puts f}
  spec.has_rdoc = false
  spec.add_dependency("nokogiri", ">= 1.4.2")
  spec.add_dependency("rubyzip", ">= 0.9.4")
  spec.extra_rdoc_files = ["README"]
  spec.require_path = ["lib"]
  spec.test_files = ["test_files"]
end


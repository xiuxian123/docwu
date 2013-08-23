$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "docfive/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "docfive"
  s.version     = Docfive::VERSION
  s.authors     = ["happy"]
  s.email       = ["andywang7259@gmail.com"]
  s.homepage    = "http://github.com/xiuxian123/docfive"
  s.summary     = "Summary of Docfive."
  s.description = "Description of Docfive."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  # s.add_dependency "rails", "~> 4.0.0"

  # s.add_development_dependency "sqlite3"
end

# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "beautiful_scaffold"
  s.version     = "0.2.6"
  s.platform    = Gem::Platform::RUBY  
  s.summary     = "Beautiful Scaffold generate fully customizable scaffold"
  s.email       = "claudel.sylvain@gmail.com"
  s.homepage    = "http://beautiful-scaffold.com"
  s.description = "Beautiful Scaffold generate a complete scaffold (sort, export, paginate and filter data) http://www.beautiful-scaffold.com"
  s.authors     = ['Sylvain Claudel']
  s.files       = `git ls-files`.split("\n")

  s.rubyforge_project = "beautiful_scaffold"

  s.require_paths = ["lib","lib/generators"]
end

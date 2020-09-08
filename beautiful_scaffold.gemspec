# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require "beautiful_scaffold/version"

Gem::Specification.new do |s|
  s.name        = "beautiful_scaffold"
  s.version     = BeautifulScaffold::VERSION
  s.platform    = Gem::Platform::RUBY  
  s.summary     = "Beautiful Scaffold generate fully customizable scaffold"
  s.email       = "claudel.sylvain@gmail.com"
  s.homepage    = "https://blog.rivsc.ovh"
  s.description = "Beautiful Scaffold generate a complete scaffold (sort, export, paginate and filter data) http://beautiful-scaffold.rivsc.ovh"
  s.authors     = ['Sylvain Claudel']
  s.files       = `git ls-files`.split("\n").reject{ |filepath| filepath.start_with? 'test/' }
  s.licenses    = ['MIT']

  s.rubyforge_project = "beautiful_scaffold"

  s.require_paths = ["lib","lib/generators","test/*"]
end

# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ar_enums/version"

Gem::Specification.new do |s|
  s.name        = "ar-enums"
  s.version     = ArEnums::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Emmanuel Nicolau"]
  s.email       = ["emmanicolau@gmail.com"]
  s.summary     = %q{Provides a simple way for defining enumerations in ActiveRecord models}

  s.rubyforge_project = "ar-enums"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_development_dependency "rspec"
  s.add_development_dependency "ruby-debug19"
  s.add_development_dependency "sqlite3-ruby"
  s.add_dependency "activerecord"
  s.add_dependency "rake"
end

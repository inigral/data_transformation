# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "data_transformation/version"

Gem::Specification.new do |s|
  s.name        = "data_transformation"
  s.version     = DataTransformations::VERSION
	s.platform   	= Gem::Platform::RUBY
  s.authors     = ["Chris Barton"]
  s.email       = ["cbarton@inigral.com"]
  s.homepage    = "https://github.com/inigral/data_transformation"
  s.summary     = "Rails 3 Data Transformations"
  s.description = "To keep the necessity of changing data out of migrations, transformations keep track of that"

  s.rubyforge_project = "data_transformation"
	s.required_rubygems_version = ">= 1.3.6"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_path = "lib"

	s.add_dependency "activerecord"
	s.add_development_dependency "bundler"
	s.add_development_dependency "rspec"
	s.add_development_dependency "generator_spec"
	s.add_development_dependency "sqlite3"
end

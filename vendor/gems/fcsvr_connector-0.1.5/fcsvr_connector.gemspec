# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "fcsvr_connector/version"

Gem::Specification.new do |s|
  s.name        = "fcsvr_connector"
  s.version     = FcsvrConnector::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Steve Houser"]
  s.email       = ["steve@tilting.at"]
  s.homepage    = ""
  s.summary     = %q{This gem interacts with Final Cut Server through the command line tools.}
  s.description = %q{Offers a front end to the functionalities of the fcsvr_client and other command line tools.}
  s.extra_rdoc_files = ["README.rdoc"]

  s.rubyforge_project = "fcsvr_connector"

  s.files         = Dir.glob("lib/**/*") + %w(Rakefile README.rdoc fcsvr_connector.gemspec)
  s.require_paths = ["lib"]
  
  s.add_dependency(%q<nokogiri>, ["~> 1.4.4"])
  s.add_dependency(%q<json>, ["~> 1.5.1"])
end

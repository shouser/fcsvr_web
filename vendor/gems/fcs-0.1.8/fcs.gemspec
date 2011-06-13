# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{fcs}
  s.version = "0.1.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tilting @, LLC"]
  s.date = %q{2011-06-13}
  s.description = %q{}
  s.email = %q{steve@tilting.at}
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "fcs.gemspec",
    "lib/ext/string.rb",
    "lib/fcs.rb",
    "lib/fcs/asset.rb",
    "lib/fcs/client.rb",
    "lib/fcs/device.rb",
    "lib/fcs/element.rb",
    "lib/fcs/factory.rb",
    "lib/fcs/fcs_entity.rb",
    "lib/fcs/file.rb",
    "lib/fcs/lazy_reader.rb",
    "lib/fcs/multi_tree.rb",
    "lib/fcs/project.rb",
    "lib/test.rb",
    "test/helper.rb",
    "test/test_fcs.rb"
  ]
  s.homepage = %q{http://github.com/TiltingAt/fcs}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{Final Cut Server offers a command line interface to much of it's functionality.   This gem offers a more ruby'ish interface to that functionality.}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.6.2"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
    else
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.6.2"])
      s.add_dependency(%q<rcov>, [">= 0"])
    end
  else
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.6.2"])
    s.add_dependency(%q<rcov>, [">= 0"])
  end
end


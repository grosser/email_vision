# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{email_vision}
  s.version = "0.2.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Michael Grosser"]
  s.date = %q{2011-02-17}
  s.email = %q{michael@grosser.it}
  s.files = [
    "Gemfile",
    "Gemfile.lock",
    "Rakefile",
    "Readme.md",
    "VERSION",
    "email_vision.gemspec",
    "lib/email_vision.rb",
    "spec/account.yml.example",
    "spec/email_vision_spec.rb"
  ]
  s.homepage = %q{http://github.com/grosser/email_vision}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.4.2}
  s.summary = %q{Ruby SOAP Api Client for EmailVision / CampaignCommander}
  s.test_files = [
    "spec/email_vision_spec.rb"
  ]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<savon>, [">= 0.8.2"])
      s.add_runtime_dependency(%q<savon>, [">= 0"])
    else
      s.add_dependency(%q<savon>, [">= 0.8.2"])
      s.add_dependency(%q<savon>, [">= 0"])
    end
  else
    s.add_dependency(%q<savon>, [">= 0.8.2"])
    s.add_dependency(%q<savon>, [">= 0"])
  end
end


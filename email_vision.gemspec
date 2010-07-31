# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{email_vision}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Michael Grosser"]
  s.date = %q{2010-07-31}
  s.email = %q{grosser.michael@gmail.com}
  s.files = [
    ".gitignore",
     "Rakefile",
     "Readme.md",
     "lib/email_vision.rb",
     "spec/account.yml.example",
     "spec/email_vision_spec.rb"
  ]
  s.homepage = %q{http://github.com/grosser/email_vision}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Ruby SOAP Api Client for EmailVision / CampaignCommander}
  s.test_files = [
    "spec/email_vision_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<savon>, [">= 0"])
    else
      s.add_dependency(%q<savon>, [">= 0"])
    end
  else
    s.add_dependency(%q<savon>, [">= 0"])
  end
end


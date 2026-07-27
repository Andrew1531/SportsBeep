# -*- encoding: utf-8 -*-
# stub: bech32 1.5.0 ruby lib

Gem::Specification.new do |s|
  s.name = "bech32".freeze
  s.version = "1.5.0".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Shigeyuki Azuchi".freeze]
  s.bindir = "exe".freeze
  s.date = "2025-03-25"
  s.description = "The implementation of Bech32 encoder and decoder.".freeze
  s.email = ["techmedia.think@gmail.com".freeze]
  s.executables = ["bech32".freeze]
  s.files = ["exe/bech32".freeze]
  s.homepage = "https://github.com/azuchi/bech32rb".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.6.3".freeze
  s.summary = "The implementation of Bech32 encoder and decoder.".freeze

  s.installed_by_version = "3.7.2".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<thor>.freeze, [">= 1.1.0".freeze])
  s.add_development_dependency(%q<rake>.freeze, [">= 12.3.3".freeze])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0".freeze])
end

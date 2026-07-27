# -*- encoding: utf-8 -*-
# stub: blake2b 0.10.0 ruby lib
# stub: ext/blake2b_ext/extconf.rb

Gem::Specification.new do |s|
  s.name = "blake2b".freeze
  s.version = "0.10.0".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Franck Verrot".freeze, "Mauricio Gomes".freeze]
  s.date = "2018-05-30"
  s.description = "A cryptographic hash function faster than MD5, SHA-1, SHA-2, and SHA-3 for 64-bit systems.".freeze
  s.email = ["mauricio@edge14.com".freeze]
  s.extensions = ["ext/blake2b_ext/extconf.rb".freeze]
  s.files = ["ext/blake2b_ext/extconf.rb".freeze]
  s.homepage = "https://github.com/mgomes/blake2b".freeze
  s.licenses = ["GPL-3.0".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.1.0".freeze)
  s.rubygems_version = "2.7.6".freeze
  s.summary = "A cryptographic hash function faster than MD5, SHA-1, SHA-2, and SHA-3 for 64-bit systems.".freeze

  s.installed_by_version = "3.7.2".freeze

  s.specification_version = 4

  s.add_development_dependency(%q<rake-compiler>.freeze, ["~> 0.9".freeze])
  s.add_development_dependency(%q<bundler>.freeze, ["~> 1.5".freeze])
  s.add_development_dependency(%q<rake>.freeze, ["~> 11.1".freeze])
  s.add_development_dependency(%q<minitest>.freeze, ["~> 5.11".freeze])
end

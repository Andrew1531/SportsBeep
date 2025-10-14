# -*- encoding: utf-8 -*-
# stub: angular-rails-templates 1.3.1 ruby lib

Gem::Specification.new do |s|
  s.name = "angular-rails-templates".freeze
  s.version = "1.3.1".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Damien Mathieu".freeze, "pitr".freeze, "whitehat101".freeze]
  s.date = "2025-02-27"
  s.email = ["pitr.vern@gmail.com".freeze]
  s.homepage = "https://github.com/pitr/angular-rails-templates".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.6.2".freeze
  s.summary = "Use your angular templates with rails' asset pipeline".freeze

  s.installed_by_version = "3.6.9".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<railties>.freeze, [">= 5.0".freeze, "< 8.1".freeze])
  s.add_runtime_dependency(%q<sprockets>.freeze, [">= 3.0".freeze, "< 5".freeze])
  s.add_runtime_dependency(%q<sprockets-rails>.freeze, [">= 0".freeze])
  s.add_runtime_dependency(%q<tilt>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<minitest>.freeze, ["< 6".freeze])
  s.add_development_dependency(%q<capybara>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<uglifier>.freeze, [">= 0".freeze])
end

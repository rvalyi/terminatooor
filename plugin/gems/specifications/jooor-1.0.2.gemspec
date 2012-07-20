# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "jooor"
  s.version = "1.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Raphael Valyi - www.akretion.com"]
  s.date = "2012-06-29"
  s.description = "Java XML RPC layer to boost OOOR speed dramatically when used from JRuby"
  s.email = "rvalyi@akretion.com"
  s.homepage = "http://github.com/rvalyi/jooor"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "Java XML RPC layer to boost OOOR speed dramatically when used from JRuby"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<ooor>, [">= 1.6"])
    else
      s.add_dependency(%q<ooor>, [">= 1.6"])
    end
  else
    s.add_dependency(%q<ooor>, [">= 1.6"])
  end
end

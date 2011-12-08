# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "ooor"
  s.version = "1.6.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Raphael Valyi - www.akretion.com"]
  s.date = "2011-10-06"
  s.description = "OOOR exposes business object proxies to your Ruby (Rails or not) application, that maps seamlessly to your remote OpenObject/OpenERP server using webservices. It extends the standard ActiveResource API. Running on JRuby, OOOR also offers a convenient bridge between OpenERP and the Java eco-system"
  s.email = "rvalyi@akretion.com"
  s.executables = ["ooor"]
  s.files = ["bin/ooor"]
  s.homepage = "http://github.com/rvalyi/ooor"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.10"
  s.summary = "OOOR - OpenObject On Ruby"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activeresource>, [">= 2.3.5"])
    else
      s.add_dependency(%q<activeresource>, [">= 2.3.5"])
    end
  else
    s.add_dependency(%q<activeresource>, [">= 2.3.5"])
  end
end

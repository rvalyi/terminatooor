# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ooor}
  s.version = "1.4.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Raphael Valyi - www.akretion.com"]
  s.date = %q{2010-07-06}
  s.description = %q{OOOR exposes business object proxies to your Ruby (Rails or not) application, that map seamlessly to your remote OpenObject/OpenERP server using webservices. It extends the standard ActiveResource API.}
  s.email = %q{rvalyi@akretion.com}
  s.files = ["README.md", "agpl-3.0-licence.txt", "lib/ooor.rb", "ooor.yml", "lib/app/models/open_object_resource.rb", "lib/app/models/uml.rb", "lib/app/models/base64.rb", "lib/app/models/db_service.rb", "lib/app/models/common_service.rb", "lib/app/ui/action_window.rb", "lib/app/ui/client_base.rb", "lib/app/ui/form_model.rb", "lib/app/ui/menu.rb", "spec/ooor_spec.rb"]
  s.homepage = %q{http://github.com/rvalyi/ooor}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{OOOR - OpenObject On Rails}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activeresource>, [">= 2.3.1"])
    else
      s.add_dependency(%q<activeresource>, [">= 2.3.1"])
    end
  else
    s.add_dependency(%q<activeresource>, [">= 2.3.1"])
  end
end

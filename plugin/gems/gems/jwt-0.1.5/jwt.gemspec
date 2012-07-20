# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "jwt"
  s.version = "0.1.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jeff Lindsay"]
  s.date = "2012-07-20"
  s.description = "JSON Web Token implementation in Ruby"
  s.email = "progrium@gmail.com"
  s.extra_rdoc_files = ["lib/jwt.rb"]
  s.files = ["Rakefile", "lib/jwt.rb", "spec/helper.rb", "spec/jwt_spec.rb", "Manifest", "jwt.gemspec"]
  s.homepage = "http://github.com/progrium/ruby-jwt"
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Jwt", "--main", "README.md"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "jwt"
  s.rubygems_version = "1.8.24"
  s.summary = "JSON Web Token implementation in Ruby"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<multi_json>, [">= 1.0"])
      s.add_development_dependency(%q<echoe>, [">= 4.6.3"])
    else
      s.add_dependency(%q<multi_json>, [">= 1.0"])
      s.add_dependency(%q<echoe>, [">= 4.6.3"])
    end
  else
    s.add_dependency(%q<multi_json>, [">= 1.0"])
    s.add_dependency(%q<echoe>, [">= 4.6.3"])
  end
end

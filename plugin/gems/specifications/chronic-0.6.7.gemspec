# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "chronic"
  s.version = "0.6.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tom Preston-Werner", "Lee Jarvis"]
  s.date = "2012-02-01"
  s.description = "Chronic is a natural language date/time parser written in pure Ruby."
  s.email = ["tom@mojombo.com", "lee@jarvis.co"]
  s.extra_rdoc_files = ["README.md", "HISTORY.md", "LICENSE"]
  s.files = ["README.md", "HISTORY.md", "LICENSE"]
  s.homepage = "http://github.com/mojombo/chronic"
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "chronic"
  s.rubygems_version = "1.8.24"
  s.summary = "Natural language date/time parsing."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

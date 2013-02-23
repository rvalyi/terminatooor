# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "shared-mime-info"
  s.version = "0.1"

  s.required_rubygems_version = nil if s.respond_to? :required_rubygems_version=
  s.authors = ["Hank Lords"]
  s.autorequire = "rake"
  s.cert_chain = nil
  s.date = "2006-09-23"
  s.email = "hanklords@gmail.com"
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new("> 0.0.0")
  s.rubygems_version = "1.8.24"
  s.summary = "Library to guess the MIME type of a file with both filename lookup and magic file detection"

  if s.respond_to? :specification_version then
    s.specification_version = 1

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

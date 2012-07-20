# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "google_drive"
  s.version = "0.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Hiroshi Ichikawa"]
  s.date = "2012-07-01"
  s.description = "A library to read/write files/spreadsheets in Google Drive/Docs."
  s.email = ["gimite+github@gmail.com"]
  s.extra_rdoc_files = ["README.rdoc", "doc_src/google_drive/acl.rb", "doc_src/google_drive/acl_entry.rb"]
  s.files = ["README.rdoc", "doc_src/google_drive/acl.rb", "doc_src/google_drive/acl_entry.rb"]
  s.homepage = "https://github.com/gimite/google-drive-ruby"
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "A library to read/write files/spreadsheets in Google Drive/Docs."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nokogiri>, ["!= 1.5.1", "!= 1.5.2", ">= 1.4.4"])
      s.add_runtime_dependency(%q<oauth>, [">= 0.3.6"])
      s.add_runtime_dependency(%q<oauth2>, [">= 0.5.0"])
      s.add_development_dependency(%q<rake>, [">= 0.8.0"])
    else
      s.add_dependency(%q<nokogiri>, ["!= 1.5.1", "!= 1.5.2", ">= 1.4.4"])
      s.add_dependency(%q<oauth>, [">= 0.3.6"])
      s.add_dependency(%q<oauth2>, [">= 0.5.0"])
      s.add_dependency(%q<rake>, [">= 0.8.0"])
    end
  else
    s.add_dependency(%q<nokogiri>, ["!= 1.5.1", "!= 1.5.2", ">= 1.4.4"])
    s.add_dependency(%q<oauth>, [">= 0.3.6"])
    s.add_dependency(%q<oauth2>, [">= 0.5.0"])
    s.add_dependency(%q<rake>, [">= 0.8.0"])
  end
end

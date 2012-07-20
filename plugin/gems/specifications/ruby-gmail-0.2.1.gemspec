# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "ruby-gmail"
  s.version = "0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["BehindLogic"]
  s.date = "2010-05-14"
  s.description = "A Rubyesque interface to Gmail, with all the tools you'll need. Search, read and send multipart emails; archive, mark as read/unread, delete emails; and manage labels."
  s.email = "gems@behindlogic.com"
  s.extra_rdoc_files = ["README.markdown"]
  s.files = ["README.markdown"]
  s.homepage = "http://dcparker.github.com/ruby-gmail"
  s.post_install_message = "\n\e[34mIf ruby-gmail saves you TWO hours of work, want to compensate me for, like, a half-hour?\nSupport me in making new and better gems:\e[0m \e[31;4mhttp://pledgie.com/campaigns/7087\e[0m\n\n"
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "A Rubyesque interface to Gmail, with all the tools you'll need."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<shared-mime-info>, [">= 0"])
      s.add_runtime_dependency(%q<mail>, [">= 2.2.1"])
    else
      s.add_dependency(%q<shared-mime-info>, [">= 0"])
      s.add_dependency(%q<mail>, [">= 2.2.1"])
    end
  else
    s.add_dependency(%q<shared-mime-info>, [">= 0"])
    s.add_dependency(%q<mail>, [">= 2.2.1"])
  end
end

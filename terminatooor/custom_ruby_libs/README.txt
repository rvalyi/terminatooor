You can now call custom Ruby libraries or Gems inside TerminatOOOR transformations
1) libraries:
- just paste them inside the custom_ruby_libs/lib folder
- then require the appropriate file inside your Ruby code in your transformations (ex; if you have a file called test.rb definying a class Toto, then just do >require "test")

2) Gems:
- copy the gems and their "specifications" in the gems and specifications directories, as they would be in your regular Gem path (for instance /usr/lib/ruby/gems/1.8 on Ubuntu).
- then just require the gem you want in your transformation Ruby code. Important note: you don't need to do >require "rubygems" as it is already done for you in TerminatOOOR.

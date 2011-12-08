# Copyright (c) 2006 Hank Lords <hanklords@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'enumerator'
require 'rexml/document'

# shared-mime-info is a pure Ruby library for accessing the MIME info
# database provided by Freedesktop[http://freedesktop.org/] on
# {Standards/shared-mime-info-spec}[http://wiki.freedesktop.org/wiki/Standards_2fshared_2dmime_2dinfo_2dspec].
#
# This provides a way to guess the mime type of a file by doing both
# filename lookups and _magic_ file checks. This implementation tries to
# follow the version 0.13 of the
# specification[http://standards.freedesktop.org/shared-mime-info-spec/shared-mime-info-spec-0.13.html].
module MIME
  VERSION = '0.1'

  module Magic # :nodoc: all
    class BadMagic < StandardError; end

    class RootEntry
      def initialize
        @sub_entries = []
        @indent = -1
      end

      def add_subentry(entry)
        return unless entry.indent > @indent
        if entry.indent == @indent + 1
          @sub_entries << entry
        elsif entry.indent > @indent + 1
          if @sub_entries.last.respond_to? :add_subentry
            @sub_entries.last.add_subentry entry
          else
            raise BadMagic
          end
        else 
          raise BadMagic
        end
      end

      def check_file(f)
        @sub_entries.empty? || @sub_entries.any? {|e| e.check_file f}
      end
    end

    class Entry < RootEntry
      attr_reader :indent
      def initialize(indent, start_offset, value_length, value, mask, word_size, range_length)
        super()
        @indent = indent
        @start_offset = start_offset
        @value_length = value_length
        @value = value.freeze
        @mask = mask.freeze
        @word_size = word_size
        @range_length = range_length
      end

      def check_file(f)
        check_entry(f) && super(f)
      end

      private
      def check_entry(f)
        f.pos = @start_offset
        f.read(@value_length) == @value
      end
    end

    def self.parse(magic)
      parsed = RootEntry.new
      entry = magic

      until entry.empty?
        entry = entry.sub /^(\d?)>(\d+)=/, ''
        indent = $1.to_i
        start_offset = $2.to_i
        value_length = entry.unpack('n').first
        value, entry = entry.unpack("x2a#{value_length}a*")

        if entry[/./m] == '&'
          mask, entry = entry.unpack("xa#{value_length}a*")
        end

        if entry[/./m] == '~'
          entry =~ /^~(\d+)(.*)/m
          word_size = $1
          entry = $2
        end

        if entry[/./m] == '+'
          entry =~ /^\+(\d+)(.*)/m
          range_length = $1
          entry = $2
        end
        entry = entry.sub /^[^\n]*\n/m, ''

        parsed.add_subentry Entry.new(indent, start_offset, value_length, value, mask, word_size, range_length)
      end

      parsed
    end
  end

  # Type represents a single mime type such as <b>text/html</b>.
  class Type
    attr_reader :magic_priority # :nodoc:

    # Returns the type of a mime type as a String, such as <b>text/html</b>.
    attr_reader :type

    # Returns the media part of the type of a mime type as a string,
    # such as <b>text</b> for a type of <b>text/html</b>.
    def media; @type.split('/', 2).first; end

    # Returns the subtype part of the type of a mime type as a string,
    # such as <b>html</b> for a type of <b>text/html</b>.
    def subtype; @type.split('/', 2).last; end

    # Synonym of type.
    def to_s; @type; end

    # Returns a Hash of the comments associated with a mime type in
    # different languages.
    #
    #  MIME.types['text/html'].default
    #   => "HTML page"
    #
    #  MIME.types['text/html'].comment['fr']
    #   => "page HTML"
    def comment
      file = ''
      MIME.mime_dirs.each { |dir|
        file = "#{dir}/#{@type}.xml"
        break if File.file? file
      }

      open(file) { |f|
        doc = REXML::Document.new f
        comments = {}
        REXML::XPath.match(doc, '*/comment').each { |c|
          if att = c.attributes['xml:lang']
            comments[att] = c.text
          else
            comments.default = c.text
          end
        }
      }
      comments
    end

    # Returns all the types this type is a subclass of.
    def parents
      file = ''
      MIME.mime_dirs.each { |dir|
        file = "#{dir}/#{@type}.xml"
        break if File.file? file
      }

      open(file) { |f|
        doc = REXML::Document.new f
        REXML::XPath.match(doc, '*/sub-class-of').collect { |c|
          MIME[c.attributes['type']]
        }
      }
    end

    # Equality test.
    #
    #  MIME['text/html'] == 'text/html'
    #   => true
    def ==(type)
      if type.is_a? Type
        @type == type.type
      elsif type.respond_to? :to_str
        @type == type
      else
        false
      end
    end

    # Check if _filename_ is of this particular type by comparing it to
    # some common extensions.
    #
    #  MIME.types['text/html'].match_filename? 'index.html'
    #   => true
    def match_filename?(filename)
      @glob_patterns.any? {|pattern| File.fnmatch pattern, filename}
    end

    # Check if _file_ is of this particular type by looking for precise
    # patterns (_magic_ numbers) in different locations of the file.
    #
    # _file_ must be an IO object opened with read permissions.
    def match_file?(file)
      if @magic.nil?
        false
      else
        @magic.check_file file
      end
    end

    def initialize(type) # :nodoc:
      @type = type.freeze
      @glob_patterns = []
    end

    def load_magic(magic, priority) # :nodoc:
      @magic_priority = priority
      @magic = Magic.parse magic
    end

    def add_glob(glob) # :nodoc:
      @glob_patterns << glob.freeze
    end
  end

  class << self
    attr_reader :mime_dirs # :nodoc:

    # Returns the MIME::Type object corresponding to _type_.
    def [](type)
      @types.fetch type, nil
    end

    # Look for the type of a file by doing successive checks on
    # the filename patterns.
    #
    # Returns a MIME::Type object or _nil_ if nothing matches.
    def check_globs(filename)
      enum = Enumerable::Enumerator.new(@globs, :each_key)
      found = enum.select { |pattern| File.fnmatch pattern, filename }

      if found.empty?
        downcase_filename = filename.downcase
        found = enum.select { |pattern|
          File.fnmatch pattern, downcase_filename
        }
      end

      @globs[found.max]
    end

    # Look for the type of a file by doing successive checks on
    # _magic_ numbers.
    #
    # Returns a MIME::Type object or _nil_ if nothing matches.
    def check_magics(file)
      if file.respond_to? :read
        check_magics_with_priority(file, 0)
      else
        open(file) {|f| check_magics_with_priority(f, 0) }
      end
    end

    # Look for the type of a file by doing successive checks with
    # the filename patterns or magic numbers. If none of the matches
    # are successful, returns a type of <b>application/octet-stream</b> if
    # the file contains control characters at its beginning, or <b>text/plain</b> otherwise.
    #
    # Returns a MIME::Type object.
    def check(filename)
      check_special(filename) ||
      open(filename) { |f|
        check_magics_with_priority(f, 80) ||
        check_globs(filename) ||
        check_magics_with_priority(f, 0) ||
        check_default(f)
      }
    end

    private
    def check_magics_with_priority(f, priority_threshold)
      @magics.find { |t|
        break if t.magic_priority < priority_threshold
        t.match_file? f
      }
    end

    def check_special(filename)
      case File.ftype(filename)
      when 'directory' then @types['inode/directory']
      when 'characterSpecial' then @types['inode/chardevice']
      when 'blockSpecial' then @types['inode/blockdevice']
      when 'fifo' then @types['inode/fifo']
      when 'socket' then @types['inode/socket']
      else
        nil
      end
    end

    def check_default(f)
      f.pos = 0
      firsts = f.read(32) || ''
      bytes = firsts.unpack('C*')
      if bytes.any? {|byte| byte < 32 && ![9, 10, 13].include?(byte) }
        @types['application/octet-stream']
      else
        @types['text/plain']
      end
    end

    def load_globs(file)
      open(file) { |f|
        f.each { |line|
          next if line =~ /^#/
          cline = line.chomp
          type, pattern = cline.split ':', 2
          @types[type].add_glob pattern
          @globs[pattern] = @types[type] unless @globs.has_key? pattern
        }
      }
    end

    def load_magic(file)
       open(file) { |f|
        raise 'Bad magic file' if f.readline != "MIME-Magic\0\n"

        f.gets =~ /^\[(\d\d):(.+)\]/
        priority = $1.to_i
        type = $2
        buf =''

        f.each { |line|
          if line =~ /^\[(\d\d):(.+)\]/
            @types[type].load_magic buf, priority
            @magics << @types[type]

            priority = $1.to_i
            type = $2
            buf = ''
          else
            buf << line
          end
        }
      }
    end
  end

  xdg_data_home = ENV['XDG_DATA_HOME'] || "#{ENV['HOME']}/.local/share"
  xdg_data_dirs = ENV['XDG_DATA_DIRS'] || "/usr/local/share/:/usr/share"

  @mime_dirs = (xdg_data_home + ':' + xdg_data_dirs).split(':').collect { |dir|
    "#{dir}/mime"
  }

  @types = Hash.new {|h,k| h[k] = Type.new(k)}
  @magics = []
  @globs = {}

  @mime_dirs.each {|dir|
    glob_file =  "#{dir}/globs"
    load_globs glob_file if File.file? glob_file

    magic_file =  "#{dir}/magic"
    load_magic magic_file if File.file? magic_file
  }
end

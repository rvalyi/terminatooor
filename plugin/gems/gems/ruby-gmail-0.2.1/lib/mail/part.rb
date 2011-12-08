module Mail
  class Message
    def attachment?
      !!find_attachment
    end
  end
  class Part < Message
    def save_to_file(path=nil)
      return false unless attachment?
      fname = path if path && !File.exists?(path) # If path doesn't exist, assume it's a filename
      fname ||= path + '/' + filename if path && File.directory?(path) # If path does exist, and we're saving an attachment, use the attachment filename
      fname ||= (path || filename) # Use the path, or the attachment filename
      if File.directory?(fname)
        i = 0
        begin
          i += 1
          fname = fname + "/attachment-#{i}"
        end until !File.exists(fname)
      end
      # After all that trouble to get a filename to save to...
      File.open(fname, 'w') { |f| f << read }
    end
  end
end

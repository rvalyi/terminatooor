%w(tmpdir digest/md5 base64 httpauth/exceptions httpauth/constants).each { |l| require l }

module HTTPAuth
  # = Digest
  #
  # The Digest class provides a number of methods to handle HTTP Digest Authentication. Generally the server
  # sends a challenge to the client a resource that needs authorization and the client tries to respond with
  # the correct credentials. Digest authentication rapidly becomes more complicated after that, if you want to
  # build an implementation I suggest you at least skim RFC 2617 (http://www.ietf.org/rfc/rfc2617.txt).
  #
  # == Examples
  #
  # Digest authentication examples are too large to include in source documentation. Please consult the examples
  # directory for client and server implementations.
  #
  # The classes and code of the library are set up to be as transparent as possible so integrating the library
  # with any implementation talking HTTP, either trough CGI or directly should be possible.
  #
  # == The 'Digest'
  #
  # In Digest authentication the client's credentials are never sent in plain text over HTTP. You don't even have
  # to store the passwords in plain text on the server to authenticate clients. The library doesn't force you to
  # use the digest mechanism, it also works by specifying the username, password and realm. If you do decided to
  # use digests you can generate them in the following way:
  #
  #   H(username + ':' + realm + ':' + password)
  #
  # Where H returns the MD5 hexdigest of the string. The Utils class defines a method to calculate the digest.
  #
  #   HTTPAuth::Digest::Utils.htdigest(username, realm, password)
  #
  # The format of this digest is the same in most implementations. Apache's <tt>htdigest</tt> tool for instance
  # stores the digests in a textfile like this:
  #
  #   username:realm:digest
  #
  # == Security
  #
  # Digest authentication is quite a bit more secure than Basic authentication, but it isn't as secure as SSL.
  # The biggest difference between Basic and Digest authentication is that Digest authentication doesn't send
  # clear text passwords, but only an MD5 digest. Recent developments in password cracking and mathematics have
  # found several ways to create collisions with MD5 hashes and it's not infinitely secure. However, it currently
  # still takes a lot of computing power to crack MD5 digests. Checking for brute force attacks in your applications
  # and routinely changing the user credentials and maybe even the realm makes it a lot harder for a cracker to
  # abuse your application.
  module Digest
    # Utils contains all sort of conveniance methods for the header container classes. Implementations shouldn't have
    # to call any methods on Utils.
    class Utils
      class << self
        # Encodes a hash with digest directives to send in a header.
        #
        # * <tt>h</tt>: The directives specified in a hash
        # * <tt>variant</tt>: Specifies whether the directives are for an Authorize header (:credentials),
        #   for a WWW-Authenticate header (:challenge) or for a Authentication-Info header (:auth_info).
        def encode_directives(h, variant)
          encode = {:domain => :join, :algorithm => false, :stale => :str_to_bool, :nc => :int_to_hex,
                    :nextnonce => :int_to_hex}
          if [:credentials, :auth].include? variant
            encode.merge! :qop => false
          elsif variant == :challenge
            encode.merge! :qop => :list_to_quoted_string
          else
            raise ArgumentError.new("#{variant} is not a valid value for `variant' use :auth, :credentials or :challenge")
          end
          (variant == :auth ? '' : 'Digest ') + h.collect do |directive, value|
            '' << directive.to_s << '=' << if encode[directive]
                begin
                  Conversions.send encode[directive], value
                rescue NoMethodError, ArgumentError
                  raise ArgumentError.new("Can't encode #{directive}(#{value.inspect}) with #{encode[directive]}")
                end
              elsif encode[directive].nil?
                begin
                  Conversions.quote_string value
                rescue NoMethodError, ArgumentError
                  raise ArgumentError.new("Can't encode #{directive}(#{value.inspect}) with quote_string")
                end
              else
                value
              end
          end.join(", ")
        end

        # Decodes digest directives from a header. Returns a hash with directives.
        #
        # * <tt>directives</tt>: The directives
        # * <tt>variant</tt>: Specifies whether the directives are for an Authorize header (:credentials),
        #   for a WWW-Authenticate header (:challenge) or for a Authentication-Info header (:auth_info).        
        def decode_directives(directives, variant)
          raise HTTPAuth::UnwellformedHeader.new("Can't decode directives which are nil") if directives.nil?
          decode = {:domain => :split, :algorithm => false, :stale => :bool_to_str, :nc => :hex_to_int,
                    :nextnonce => :hex_to_int}
          if [:credentials, :auth].include? variant
            decode.merge! :qop => false
          elsif variant == :challenge
            decode.merge! :qop => :quoted_string_to_list
          else
            raise ArgumentError.new("#{variant} is not a valid value for `variant' use :auth, :credentials or :challenge")
          end
        
          start = 0 
          unless variant == :auth 
            # The first six characters are 'Digest '
            start = 6
            scheme = directives[0..6].strip
            raise HTTPAuth::UnwellformedHeader.new("Scheme should be Digest, server responded with `#{directives}'") unless scheme == 'Digest'
          end
          
          # The rest are the directives
          # TODO: split is ugly, I want a real parser (:
          directives[start..-1].split(',').inject({}) do |h,part|
            parts = part.split('=')
            name = parts[0].strip.intern
            value = parts[1..-1].join('=').strip
            
            # --- HACK
            # IE and Safari qoute qop values
            # IE also quotes algorithm values
            if variant != :challenge and [:qop, :algorithm].include?(name) and value =~ /^\"[^\"]+\"$/
              value = Conversions.unquote_string(value)
            end
            # --- END HACK
            
            if decode[name]
              h[name] = Conversions.send decode[name], value
            elsif decode[name].nil?
              h[name] = Conversions.unquote_string value
            else
              h[name] = value
            end
            h
          end
        end
        
        # Concat arguments the way it's done frequently in the Digest spec.
        #
        #   digest_concat('a', 'b') #=> "a:b"
        #   digest_concat('a', 'b', c') #=> "a:b:c"
        def digest_concat(*args); args.join ':'; end
        
        # Calculate the MD5 hexdigest for the string data
        def digest_h(data); ::Digest::MD5.hexdigest data; end
        
        # Calculate the KD value of a secret and data as explained in the RFC.
        def digest_kd(secret, data); digest_h digest_concat(secret, data); end
        
        # Calculate the Digest for the credentials
        def htdigest(username, realm, password)
          digest_h digest_concat(username, realm, password)
        end

        # Calculate the H(A1) as explain in the RFC. If h[:digest] is set, it's used instead
        # of calculating H(username ":" realm ":" password).
        def digest_a1(h, s)
          # TODO: check for known algorithm values (look out for the IE algorithm quote bug)
          if h[:algorithm] == 'MD5-sess'
            digest_h digest_concat(
              h[:digest] || htdigest(h[:username], h[:realm], h[:password]),
              h[:nonce],
              h[:cnonce]
            )
          else
            h[:digest] || htdigest(h[:username], h[:realm], h[:password])
          end
        end
        
        # Calculate the H(A2) for the Authorize header as explained in the RFC.
        def request_digest_a2(h)
          # TODO: check for known qop values (look out for the safari qop quote bug)
          if h[:qop] == 'auth-int'
            digest_h digest_concat(h[:method], h[:uri], digest_h(h[:request_body]))
          else
            digest_h digest_concat(h[:method], h[:uri])
          end
        end

        # Calculate the H(A2) for the Authentication-Info header as explained in the RFC.
        def response_digest_a2(h)
          if h[:qop] == 'auth-int'
            digest_h ':' + digest_concat(h[:uri], digest_h(h[:response_body]))
          else
            digest_h ':' + h[:uri]
          end
        end

        # Calculate the digest value for the directives as explained in the RFC.
        #
        # * <tt>variant</tt>: Either <tt>:request</tt> or <tt>:response</tt>, as seen from the server.
        def calculate_digest(h, s, variant)
          raise ArgumentError.new("Variant should be either :request or :response, not #{variant}") unless [:request, :response].include?(variant)
          # Compatability with RFC 2069
          if h[:qop].nil?
            digest_kd digest_a1(h, s), digest_concat(
              h[:nonce],
              send("#{variant}_digest_a2".intern, h)
            )
          else
            digest_kd digest_a1(h, s), digest_concat(
              h[:nonce],
              Conversions.int_to_hex(h[:nc]),
              h[:cnonce],
              h[:qop],
              send("#{variant}_digest_a2".intern, h)
            )
          end
        end
        
        # Return a hash with the keys in <tt>keys</tt> found in <tt>h</tt>.
        #
        # Example
        #
        #   filter_h_on({1=>1,2=>2}, [1]) #=> {1=>1}
        #   filter_h_on({1=>1,2=>2}, [1, 2]) #=> {1=>1,2=>2}
        def filter_h_on(h, keys)
          h.inject({}) { |r,l| keys.include?(l[0]) ? r.merge({l[0]=>l[1]}) : r }
        end
        
        # Create a nonce value of the time and a salt. The nonce is created in such a
        # way that the issuer can check the age of the nonce.
        #
        # * <tt>salt</tt>: A reasonably long passphrase known only to the issuer.
        def create_nonce(salt)
          now = Time.now
          time = now.strftime("%Y-%m-%d %H:%M:%S").to_s + ':' + now.usec.to_s
          Base64.encode64(
          digest_concat(
              time,
              digest_h(digest_concat(time, salt))
            )
          ).gsub("\n", '')[0..-3]
        end
    
        # Create a 32 character long opaque string with a 'random' value
        def create_opaque
          s = []; 16.times { s << rand(127).chr }
          digest_h s.join
        end
      end
    end
    
    # Superclass for all the header container classes
    class AbstractHeader
      # holds directives and values for digest calculation
      attr_reader :h
      
      # Redirects attribute messages to the internal directives
      #
      # Example:
      #
      #   class Credentials < AbstractHeader
      #     def initialize
      #       @h = { :username => 'Ben' }
      #     end
      #   end
      #
      #   c = Credentials.new
      #   c.username #=> 'Ben'
      #   c.username = 'Mary'
      #   c.username #=> 'Mary'
      def method_missing(m, *a)
        if ((m.to_s =~ /^(.*)=$/) == 0) and @h.keys.include?($1.intern)
          @h[$1.intern] = a[0]
        elsif @h.keys.include? m
          @h[m]
        else
          raise NameError.new("undefined method `#{m}' for #{self}")
        end
      end
    end
    
    
    # The Credentials class handlers the Authorize header. The Authorize header is sent by a client who wants to
    # let the server know he has the credentials needed to access a resource.
    #
    # See the Digest module for examples
    class Credentials < AbstractHeader
      
      # Parses the information from a Authorize header and create a new Credentials instance with the information.
      # The options hash allows you to specify additional information.
      #
      # * <tt>authorization</tt>: The contents of the Authorize header
      # See <tt>initialize</tt> for valid options.
      def self.from_header(authorization, options={})
        new Utils.decode_directives(authorization, :credentials), options
      end
      
      # Creates a new Credential instance based on a Challenge instance.
      #
      # * <tt>challenge</tt>: A Challenge instance
      # See <tt>initialize</tt> for valid options.
      def self.from_challenge(challenge, options={})
        credentials = new challenge.h
        credentials.update_from_challenge! options
        credentials
      end
      
      # Create a new instance.
      #
      # * <tt>h</tt>:  A Hash with directives, normally this is filled with the directives coming from a Challenge instance.
      # * <tt>options</tt>: Used to set or override data from the Authorize header and add additional parameters.
      #   * <tt>:username</tt>: Mostly set by a client to send the username
      #   * <tt>:password</tt>: Mostly set by a client to send the password, set either this or the digest
      #   * <tt>:digest</tt>: Mostly set by a client to send a digest, set either this or the digest. For more
      #     information about digests see Digest.
      #   * <tt>:uri</tt>: Mostly set by the client to send the uri
      #   * <tt>:method</tt>: The HTTP Method used by the client to send the request, this should be an uppercase string
      #     with the name of the verb.
      def initialize(h, options={})
        @h = h
        @h.merge! options
        session = Session.new h[:opaque], :tmpdir => options[:tmpdir]
        @s = session.load
        @reason = 'There has been no validation yet'
      end
      
      # Convenience method, basically an alias for <code>validate(options.merge(:password => password))</code>
      def validate_password(password, options={})
        options[:password] = password
        validate(options)
      end
      
      # Convenience method, basically an alias for <code>validate(options.merge(:digest => digest))</code>
      def validate_digest(digest, options={})
        options[:digest] = digest
        validate(options)
      end
      
      # Validates the credential information stored in the Credentials instance. Returns <tt>true</tt> or
      # <tt>false</tt>. You can read the ue
      #
      # * <tt>options</tt>: The extra options needed to validate the credentials. A server implementation should
      #   provide the <tt>:method</tt> and a <tt>:password</tt> or <tt>:digest</tt>.
      #   * <tt>:method</tt>: The HTTP Verb in uppercase, ie. GET or POST.
      #   * <tt>:password</tt>: The password for the sent username and realm, either a password or digest should be
      #     provided.
      #   * <tt>:digest</tt>: The digest for the specified username and realm, either a digest or password should ne
      #     provided.
      def validate(options)
        ho = @h.merge(options)
        raise ArgumentError.new("You have to set the :request_body value if you want to use :qop => 'auth-int'") if @h[:qop] == 'auth-int' and ho[:request_body].nil?
        raise ArgumentError.new("Please specify the request method :method (ie. GET)") if ho[:method].nil?
        
        calculated_response = Utils.calculate_digest(ho, @s, :request)
        if ho[:response] == calculated_response
          @reason = ''
          return true
        else
          @reason = "Response isn't the same as computed response #{ho[:response]} != #{calculated_response} for #{ho.inspect}"
        end
        false
      end
      
      # Returns a string with the reason <tt>validate</tt> returned false.
      def reason
        @reason
      end
      
      # Encodeds directives and returns a string that can be used in the Authorize header
      def to_header        
        Utils.encode_directives Utils.filter_h_on(@h,
          [:username, :realm, :nonce, :uri, :response, :algorithm, :cnonce, :opaque, :qop, :nc]), :credentials
      end
      
      # Updates @h from options, generally called after an instance was created with <tt>from_challenge</tt>.
      def update_from_challenge!(options)
        # TODO: integrity checks
        @h[:username] = options[:username]
        @h[:password] = options[:password]
        @h[:digest] = options[:digest]
        @h[:uri] = options[:uri]
        @h[:method] = options[:method]
        @h[:request_body] = options[:request_body]
        unless @h[:qop].nil?
          # Determine the QOP 
          if !options[:qop].nil? and @h[:qop].include?(options[:qop])
            @h[:qop] = options[:qop]
          elsif @h[:qop].include?(HTTPAuth::PREFERRED_QOP)
            @h[:qop] = HTTPAuth::PREFERRED_QOP
          else
            qop = @h[:qop].detect { |qop| HTTPAuth::SUPPORTED_QOPS.include? qop }
            unless qop.nil?
              @h[:qop] = qop
            else
              raise UnsupportedError.new("HTTPAuth doesn't support any of the proposed qop values: #{@h[:qop].inspect}")
            end
          end
          @h[:cnonce] ||= Utils.create_nonce options[:salt]
          @h[:nc] ||= 1 unless @h[:qop].nil?
        end
        @h[:response] = Utils.calculate_digest(@h, @s, :request)
      end
    end
    
    # The Challenge class handlers the WWW-Authenticate header. The WWW-Authenticate header is sent by a server when
    # accessing a resource without credentials is prohibided. The header should always be sent together with a 401
    # status.
    #
    # See the Digest module for examples
    class Challenge < AbstractHeader
      
      # Parses the information from a WWW-Authenticate header and creates a new WWW-Authenticate instance with this
      # data.
      #
      # * <tt>challenge</tt>: The contents of a WWW-Authenticate header
      # See <tt>initialize</tt> for valid options.
      def self.from_header(challenge, options={})
        new Utils.decode_directives(challenge, :challenge), options
      end
      
      # Create a new instance.
      #
      # * <tt>h</tt>: A Hash with directives, normally this is filled with directives coming from a Challenge instance.
      # * <tt>options</tt>: Use to set of override data from the WWW-Authenticate header
      #   * <tt>:realm</tt>: The name of the realm the client should authenticate for. The RFC suggests to use a string
      #     like 'admin@yourhost.domain.com'. Be sure to use a reasonably long string to avoid brute force attacks.
      #   * <tt>:qop</tt>: A list with supported qop values. For example: <code>['auth-int']</code>. This will default
      #     to <code>['auth']</code>. Although this implementation supports both auth and auth-int, most 
      #     implementations don't. Some implementations get confused when they receive anything but 'auth'. For
      #     maximum compatibility you should leave this setting alone.
      #   * <tt>:algorithm</tt>: The preferred algorithm for calculating the digest. For
      #     example: <code>'MD5-sess'</code>. This will default to <code>'MD5'</code>. For
      #     maximum compatibility you should leave this setting alone.
      #
      def initialize(h, options={})
        @h = h
        @h.merge! options
      end
      
      # Encodes directives and returns a string that can be used as the WWW-Authenticate header
      def to_header
        @h[:nonce] ||= Utils.create_nonce @h[:salt]
        @h[:opaque] ||= Utils.create_opaque
        @h[:algorithm] ||= HTTPAuth::PREFERRED_ALGORITHM
        @h[:qop] ||= [HTTPAuth::PREFERRED_QOP]
        Utils.encode_directives Utils.filter_h_on(@h,
          [:realm, :domain, :nonce, :opaque, :stale, :algorithm, :qop]), :challenge
      end
    end
    
    # The AuthenticationInfo class handles the Authentication-Info header. Sending Authentication-Info headers will
    # allow the client to check the integrity of the response, but it isn't compulsory and will get in the way of 
    # pipelined retrieval of resources.
    #
    # See the Digest module for examples
    class AuthenticationInfo < AbstractHeader
      
      # Parses the information from a Authentication-Info header and creates a new AuthenticationInfo instance with
      # this data.
      #
      # * <tt>auth_info</tt>: The contents of the Authentication-Info header
      # See <tt>initialize</tt> for valid options.
      def self.from_header(auth_info, options={})
        new Utils.decode_directives(auth_info, :auth), options
      end
      
      # Creates a new AuthenticationInfo instance based on the information from Credentials instance.
      #
      # * <tt>credentials</tt>: A Credentials instance
      # See <tt>initialize</tt> for valid options.
      def self.from_credentials(credentials, options={})
        auth_info = new credentials.h
        auth_info.update_from_credentials! options
        auth_info
      end
      
      # Create a new instance.
      #
      # * <tt>h</tt>: A Hash with directives, normally this is filled with the directives coming from a
      #   Credentials instance.
      # * <tt>options</tt>: Used to set or override data from the Authentication-Info header
      #   * <tt>:response_body</tt> The body of the response that's going to be sent to the client. This is a
      #     compulsory option if the qop directive is 'auth-int'.
      def initialize(h, options={})
        @h = h
        @h.merge! options
      end
      
      # Encodes directives and returns a string that can be used as the AuthorizationInfo header
      def to_header
        Utils.encode_directives Utils.filter_h_on(@h,
          [:nextnonce, :qop, :rspauth, :cnonce, :nc]), :auth
      end
      
      # Updates @h from options, generally called after an instance was created with <tt>from_credentials</tt>.
      def update_from_credentials!(options)
        # TODO: update @h after nonce invalidation
        @h[:response_body] = options[:response_body]
        @h[:nextnonce] = @h[:nc] + 1
      end
    end
    
    # Conversion for a number of internal data structures to and from directives in the headers. Implementations
    # shouldn't have to call any methods on Conversions.
    class Conversions
      class << self
      
        # Adds quotes around the string
        def quote_string(str)
          "\"#{str.gsub('"', '')}\""
        end

        # Removes quotes from around a string
        def unquote_string(str)
          str =~ /^\"([^\"]*)\"$/ ? $1 : str
        end

        # Creates an int value from hex values
        def hex_to_int(str)
          "0x#{str}".hex
        end

        # Creates a hex value in a string from an integer
        def int_to_hex(i)
          i.to_s(16).rjust 8, '0'
        end

        # Creates a boolean value from a string => true or false
        def str_to_bool(str)
          str == 'true'
        end
      
        # Creates a string value from a boolean => 'true' or 'false'
        def bool_to_str(bool)
          bool ? 'true' : 'false'
        end

        # Creates a quoted string with space separated items from a list
        def list_to_quoted_string(list)
          quote_string list.join(' ')
        end

        # Creates a list from a quoted space separated string of items
        def quoted_string_to_list(string)
          unquote_string(string).split ' '
        end
      end
    end

    # Session is a file-based session implementation for storing details about the Digest authentication session
    # between requests.
    class Session
      attr_accessor :opaque
      attr_accessor :options
    
      # Initializes the new Session object.
      #
      # * <tt>opaque</tt> - A string to identify the session. This would normally be the <tt>opaque</tt> sent by the
      #   client, but it could also be an identifier sent through a different mechanism.
      # * <tt>options</tt> - Additional options
      #   * <tt>:tmpdir</tt> A tempory directory for storing the session data. Dir::tmpdir is the default.
      def initialize(opaque, options={})
        self.opaque = opaque
        self.options = options
      end
    
      # Associates the new data to the session and removes the old
      def save(data)
        File.open(filename, 'w') do |f|
          f.write Marshal.dump(data)
        end
      end
    
      # Returns the data from this session
      def load
        begin
          File.open(filename, 'r') do |f|
            Marshal.load f.read
          end
        rescue Errno::ENOENT
          {}
        end
      end
    
      protected
    
      # The filename from which the session will be saved and read from
      def filename
        "#{options[:tmpdir] || Dir::tmpdir}/ruby_digest_cache.#{self.opaque}"
      end
    end
  end
end

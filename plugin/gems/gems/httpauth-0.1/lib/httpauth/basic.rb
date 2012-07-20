%w(base64 httpauth/exceptions httpauth/constants).each { |l| require l }

module HTTPAuth
  # = Basic
  #
  # The Basic class provides a number of methods to handle HTTP Basic Authentication. In Basic Authentication
  # the server sends a challenge and the client has to respond to that with the correct credentials. These
  # credentials will have to be sent with every request from that point on.
  #
  # == On the server 
  #
  # On the server you will have to check the headers for the 'Authorization' header. When you find one unpack
  # it and check it against your database of credentials. If the credentials are wrong you have to return a
  # 401 status message and a challenge, otherwise proceed as normal. The code is meant as an example, not as
  # runnable code.
  #
  #   def check_authentication(request, response)
  #     credentials = HTTPAuth::Basic.unpack_authorization(request['Authorization'])
  #     if ['admin', 'secret'] == credentials
  #       response.status = 200
  #       return true
  #     else
  #       response.status = 401
  #       response['WWW-Authenticate'] = HTTPAuth::Basic.pack_challenge('Admin Pages')
  #       return false
  #     end
  #   end
  #
  # == On the client
  #
  # On the client you have to detect the WWW-Authenticate header sent from the server. Once you find one you _should_
  # send credentials for that resource any resource 'deeper in the URL space'. You _may_ send the credentials for
  # every request without a WWW-Authenticate challenge. Note that credentials are valid for a realm, a server can
  # use multiple realms for different resources. The code is meant as an example, not as runnable code.
  #
  #   def get_credentials_from_user_for(realm)
  #     if realm == 'Admin Pages'
  #      return ['admin', 'secret']
  #     else
  #      return [nil, nil]
  #     end
  #   end
  #
  #   def handle_authentication(response, request)
  #     unless response['WWW-Authenticate'].nil?
  #       realm = HTTPAuth::Basic.unpack_challenge(response['WWW-Authenticate])
  #       @credentials[realm] ||= get_credentials_from_user_for(realm)
  #       @last_realm = realm
  #     end
  #     unless @last_realm.nil?
  #       request['Authorization'] = HTTPAuth::Basic.pack_authorization(*@credentials[@last_realm])
  #     end
  #   end
  class Basic
    class << self
      
      # Unpacks the HTTP Basic 'Authorization' credential header
      #
      # * <tt>authorization</tt>: The contents of the Authorization header
      # * Returns a list with two items: the username and password
      def unpack_authorization(authorization) 
        d = authorization.split ' '
        raise ArgumentError.new("HTTPAuth::Basic can only unpack Basic Authentication headers") unless d[0] == 'Basic'
        Base64.decode64(d[1]).split(':')[0..1]
      end
      
      # Packs HTTP Basic credentials to an 'Authorization' header
      #
      # * <tt>username</tt>: A string with the username
      # * <tt>password</tt>: A string with the password
      def pack_authorization(username, password)
        "Basic %s" % Base64.encode64("#{username}:#{password}").gsub("\n", '')
      end
      
      # Returns contents for the WWW-authenticate header
      #
      # * <tt>realm</tt>: A string with a recognizable title for the restricted resource
      def pack_challenge(realm)
        "Basic realm=\"%s\"" % realm.gsub('"', '')
      end
      
      # Returns the name of the realm in a WWW-Authenticate header
      #
      # * <tt>authenticate</tt>: The contents of the WWW-Authenticate header
      def unpack_challenge(authenticate)
        if authenticate =~ /Basic\srealm=\"([^\"]*)\"/
          return $1
        else
          if authenticate =~ /^Basic/
            raise UnwellformedHeader.new("Can't parse the WWW-Authenticate header, it's probably not well formed")
          else
            raise ArgumentError.new("HTTPAuth::Basic can only unpack Basic Authentication headers")
          end
        end
      end
      
      # Finds and unpacks the authorization credentials in a hash with the CGI enviroment. Returns [nil,nil] if no
      # credentials were found. See HTTPAuth::CREDENTIAL_HEADERS for supported variable names.
      #
      # _Note for Apache_: normally the Authorization header can be found in the HTTP_AUTHORIZATION env variable,
      # but Apache's mod_auth removes the variable from the enviroment. You can work around this by renaming
      # the variable in your apache configuration (or .htaccess if allowed). For example: rewrite the variable
      # for every request on /admin/*.
      #
      #   RewriteEngine on
      #   RewriteRule ^admin/ - [E=X-HTTP-AUTHORIZATION:%{HTTP:Authorization}]
      def get_credentials(env)
        d = HTTPAuth::CREDENTIAL_HEADERS.inject(false) { |d,h| env[h] || d }
        return unpack_authorization(d) if d
        [nil, nil]
      end
    end
  end
end
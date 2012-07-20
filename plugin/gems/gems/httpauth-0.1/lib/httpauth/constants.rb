# HTTPAuth holds a number of classes and constants to implement HTTP Authentication with. See Basic or Digest for
# details on how to implement authentication using this library.
#
# For more information see RFC 2617 (http://www.ietf.org/rfc/rfc2617.txt)
module HTTPAuth
  VERSION = '0.1'
  
  CREDENTIAL_HEADERS = %w{REDIRECT_X_HTTP_AUTHORIZATION X-HTTP-AUTHORIZATION X-HTTP_AUTHORIZATION HTTP_AUTHORIZATION}
  SUPPORTED_SCHEMES = { :basic => 'Basic', :digest => 'Digest' }
  SUPPORTED_QOPS = ['auth', 'auth-int']
  SUPPORTED_ALGORITHMS = ['MD5', 'MD5-sess']
  PREFERRED_QOP = 'auth'
  PREFERRED_ALGORITHM = 'MD5'
end
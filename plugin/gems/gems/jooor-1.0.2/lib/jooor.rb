#    JOOOR: OpenObject On JRuby
#    Copyright (C) 2009-2012 Akretion LTDA (<http://www.akretion.com>).
#    Author: Raphaël Valyi
#    Licensed under the MIT license, see MIT-LICENSE file

%w[commons-logging-1.1.jar  ws-commons-util-1.0.2.jar  xmlrpc-client-3.1.3.jar  xmlrpc-common-3.1.3.jar].each {|i| require i}

module Ooor
  class Ooor
    def get_java_rpc_client(url)
      require 'app/models/ooor_java_client'
      XMLJavaClient.new2(self, url, nil, @config[:rpc_timeout] || 900)
    end
  end
end

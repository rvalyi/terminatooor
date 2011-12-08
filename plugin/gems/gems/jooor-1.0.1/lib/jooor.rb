#    OOOR: Open Object On Rails
#    Copyright (C) 20011 Akretion LTDA (<http://www.akretion.com>).
#    Author: Raphaël Valyi
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

%w[commons-logging-1.1.jar  ws-commons-util-1.0.2.jar  xmlrpc-client-3.1.3.jar  xmlrpc-common-3.1.3.jar].each {|i| require i}

module Ooor
  class Ooor
    def get_java_rpc_client(url)
      require 'app/models/ooor_java_client'
      XMLJavaClient.new2(self, url, nil, @config[:rpc_timeout] || 900)
    end
  end
end

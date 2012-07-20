#    OOOR: Open Object On Rails
#    Copyright (C) 2011 Akretion LTDA (<http://www.akretion.com>).
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


require "java"

module Ooor
  class XMLJavaClient
	  
    def initialize(ooor, url, p, timeout)
      @ooor = ooor
      @config = org.apache.xmlrpc.client.XmlRpcClientConfigImpl.new
      @config.setServerURL(java.net.URL.new(url))
      @config.setEnabledForExtensions(true);
      @client = org.apache.xmlrpc.client.XmlRpcClient.new
      @client.setTransportFactory(org.apache.xmlrpc.client.XmlRpcLiteHttpTransportFactory.new(@client));
      @client.setConfig(@config)
    end
	  
    def self.new2(ooor, url, p, timeout)
      XMLJavaClient.new(ooor, url, p, timeout)
    end

    def javaize_item(e)
      if e.is_a? Array
        return javaize_array(e)
      elsif e.is_a? Integer
        return e.to_java(java.lang.Integer)
      elsif e.is_a? Hash
        map = {}
        e.each {|k, v| map[k] = javaize_item(v)}
        return map
      else
        return e
      end
    end

    def javaize_array(array)
      array.map{|e| javaize_item(e)} #TODO: test if we need a t=[] array
    end

    def rubyize(e)
      if e.is_a? Java::JavaUtil::HashMap
        map = {}
        e.keys.each do |k|
          v = e[k]
          if (! v.is_a? String) && v.respond_to?('each') && (! v.is_a?(Java::JavaUtil::HashMap))
            map[k] = v.map {|i| rubyize(i)} #array
          else
            map[k] = rubyize(v)#v
          end
        end

        return map

      elsif (! e.is_a? String) && e.respond_to?('each') && (! e.is_a?(Java::JavaUtil::HashMap))
        return e.map {|i| rubyize(i)}
      else
        return e
      end
    end

    def call(method, *args)
      begin
        res = @client.execute(method, javaize_array(args))
        return rubyize(res)
      rescue
        @error_ruby__wrapper ||= @ooor.get_ruby_rpc_client(@client.getConfig().getServerURL().to_s)
        @error_ruby__wrapper.call2(method, *args)
      end
    end

  end
end

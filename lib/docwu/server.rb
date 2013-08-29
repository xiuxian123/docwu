# -*- encoding : utf-8 -*-
# http://tobyho.com/2009/09/16/http-server-in-5-lines-with/
# https://github.com/rack/rack/blob/master/lib/rack/handler/thin.rb
# https://github.com/macournoyer/thin/blob/master/lib/thin/server.rb
module Docwu
  class Server

#     staticMe = Rack::Builder.new do
#       run Rack::Directory.new( Dir.pwd )
#     end
# 
#     Rack::Handler::Thin.run(staticMe, :port => 8080

    require 'rack'

    def self.process(options={})
      options['destination'] ||= ::Docwu.config.deploy_path
      destination = options['destination']
      FileUtils.mkdir_p(destination)

      options['port'] ||= 5656
      options['host'] ||= '0.0.0.0' 

      staticMe = Rack::Builder.new do
        run Rack::Directory.new(destination)
      end

      Rack::Handler::Thin.run(staticMe, :Port => options['port'], :Host => options['host'])
      # Rack::Handler::WEBrick.run(staticMe, :Port => options['port'], :Host => options['host'])
      # Rack::Handler::Mongrel.run(staticMe, :Port => options['port'], :Host => options['host'])
    end

    # require 'webrick'
    # include WEBrick

    # def self.process(options={})
    #   options['destination'] ||= ::Docwu.config.output_path
    #   destination = options['destination']
    #   FileUtils.mkdir_p(destination)

    #   options['port'] ||= 5656
    #   options['host'] ||= '127.0.0.1' 
    #   options['baseurl'] ||= '/'

    #   server = WEBrick::HTTPServer.new :Port => options['port']
    #   server.mount options['baseurl'], WEBrick::HTTPServlet::FileHandler, destination
    #   trap('INT') { server.stop }
    #   server.start
    # end
  end
end

# -*- encoding : utf-8 -*-
module Docwu
  class << self
    attr_writer :config

    def config
      @config ||= Config.new
    end

    def configure
      yield self.config ||= Config.new
    end
  end

  class Config
    # attr_reader :src_paths, :asset_paths, :layout_paths, :output_path, :data

    attr_reader :routes, :server, :worker, :workspace

    def routes= a
      @routes ||= a
    end

    def server= a
      @server ||= a
    end

    def worker= a
      @worker ||= a
    end

    def workspace= a
      @workspace ||= a
    end

    def topics_path
      @topics_path ||= ("#{self.workspace}/topics")
    end

    def layouts_path
      @layouts_path ||= ("#{self.workspace}/layouts")
    end

    def deploy_path
      @deploy_path ||= ("#{self.workspace}/_deploy")
    end

  end
end


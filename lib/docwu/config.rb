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

    attr_reader :routes, :params, :worker, :workspace, :docwu_env, :logger

    def logger= a
      @logger ||= (a || ::Logger.new(STDOUT))
    end

    def routes= a
      @routes ||= a
    end

    def params= a={}
      @params ||= a
    end

    def worker= a
      @worker ||= a
    end

    def workspace= a
      @workspace ||= a
    end

    def docwu_env= a
      @docwu_env ||= 'development'
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

    def tmp_path
      @tmp_path ||= ("#{self.workspace}/_tmp")
    end

  end
end


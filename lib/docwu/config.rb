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
    def output_type= type
      @output_type ||= type
    end

    def output_type
      @output_type
    end

    def default_marktype= type
      @default_marktype ||= type
    end

    def default_marktype
      @default_marktype
    end

    def output_path= path
      @output_path ||= path
    end

    def output_path
      @output_path
    end

    def doc_paths= paths
      @doc_paths ||= paths
    end

    def doc_paths
      @doc_paths
    end
  end
end


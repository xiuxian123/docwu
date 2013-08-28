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

  #
  #  src_paths
  #  asset_paths
  #  layout_paths
  #  output_path
  #
  class Config
    attr_reader :src_paths, :asset_paths, :layout_paths, :output_path, :data

    def data= a
      @data ||= a
    end

    def src_paths= a
      @src_paths ||= a
    end

    def asset_paths= a
      @asset_paths ||= a
    end

    def layout_paths= a
      @layout_paths ||= a
    end

    def output_path= a
      @output_path ||= a
    end
  end
end


# -*- encoding : utf-8 -*-
require "#{File.dirname(__FILE__)}/docwu/config"
require "#{File.dirname(__FILE__)}/docwu/route"   # 定制页面路由器
require "#{File.dirname(__FILE__)}/docwu/utils"
require "#{File.dirname(__FILE__)}/docwu/worker"
require "#{File.dirname(__FILE__)}/docwu/render"
require "#{File.dirname(__FILE__)}/docwu/folder"
require "#{File.dirname(__FILE__)}/docwu/post"
require "#{File.dirname(__FILE__)}/docwu/server"

require 'pp'
require 'yaml'
require 'fileutils'
require 'mustache_render'

module Docwu

  # 程序开始
  def self.start(workspace)
    args = ARGV

    _config_file = "#{workspace}/config.yml"

    _config = {}

    if File.exists?(_config_file) && File.file?(_config_file)
      _yml = YAML.load(File.read(_config_file))

      if _yml.is_a?(Hash)
        _config.merge!(_yml['docwu'] || {})
      end
    end

    # docwu 的配置
    ::Docwu.configure do |config|
      config.server      = (_config['server'] || {}).freeze
      config.routes      = (_config['routes'] || {}).freeze
      config.worker      = (_config['worker'] || {}).freeze
      config.workspace   = "#{workspace}".freeze
    end

    ::MustacheRender.configure do |config|
      config.file_template_root_path = ::Docwu.config.layouts_path
    end

    Docwu::Worker.new.generate
    Docwu::Server.process
  end

end

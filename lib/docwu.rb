# -*- encoding : utf-8 -*-
require "#{File.dirname(__FILE__)}/docwu/config"
require "#{File.dirname(__FILE__)}/docwu/route"   # 定制页面路由器
require "#{File.dirname(__FILE__)}/docwu/topic"
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
require 'logger'

module Docwu

  # 程序开始
  def self.start(workspace)
    _start_time = Time.now

    args = ARGV

    _command = args.shift

    _useful_cmds = ['g', 'generate', 's', 'server', '-h', '--help', 'new', '-v', '--version']

    unless _useful_cmds.include?(_command)
      puts "command #{_command} is not available, not in (#{_useful_cmds.join('|')})"
      exit
    end

    if ['-v', '--version'].include?(_command)
      puts "docwu: #{::Docwu::VERSION}"

      exit
    end

    if ['new'].include?(_command)
      _project_name = args.shift

      if _project_name.nil?
        puts 'error: You need input a project name! '
        exit
      end

      _new_dest = "#{workspace}/#{_project_name}"

      _template_src = "#{File.dirname(__FILE__)}/template_files"

      if File.exists?(_new_dest) && File.directory?(_new_dest)
        puts "error: #{_new_dest} already exists! Please check !"
      else
        FileUtils.cp_r("#{_template_src}", "#{_new_dest}")

        system "cd #{_new_dest} && bundle install && bundle exec docwu generate"
        puts "cd #{_new_dest} && bundle install && bundle exec docwu generate"

        puts "[#{_new_dest}] already success created!"
      end

      exit
    end

    _default_params = {
      '-p'        => [5656],
      '-a'        => ['0.0.0.0'],
      '-c'        => ["#{workspace}/config.yml"]
    }

    if ['--help', '-h'].include?(_command)
      puts "docwu:"

      puts "   * docwu new [project_name]  ; eg.: docwu new project"
      puts ""
      puts "   * docwu g, docwu generate, docwu s, docwu server"
      _default_params.each do |_cmd, _cfg|
        puts "    #{_cmd}, #{_cfg[1]} (default: #{_cfg[0]})"
      end

      exit
    end

    # 获取参数
    params = Hash[args.each_slice(2).to_a]

    _default_params.each do |_k, _v|
      params[_k] = params[_k] || _v.first
    end

    params['-p'] = params['-p'].to_i

    # 需要生成
    _need_generate = ['g', 'generate', 's', 'server'].include?(_command)

    # 需要开启server
    _need_server = ['s', 'server'].include?(_command)

    _config_file = params['-c']

    _config = {}

    if File.exists?(_config_file) && File.file?(_config_file)
      _yml = YAML.load(File.read(_config_file))

      if _yml.is_a?(Hash)
        _config.merge!(_yml['docwu'] || {})
      end
    else
      raise "#{_config_file} not exists!"
    end

    _logger = ::Logger.new(STDOUT)
    _logger.level = ::Logger::INFO

    # docwu 的配置
    ::Docwu.configure do |config|
      config.logger      = _logger
      config.params      = params.freeze
      config.routes      = (_config['routes'] || {}).freeze
      config.worker      = (_config['worker'] || {}).freeze
      config.workspace   = "#{workspace}".freeze
    end

    ::MustacheRender.configure do |config|
      config.file_template_root_path = ::Docwu.config.layouts_path
      config.logger                  = ::Docwu.config.logger
    end

    if _need_generate
      ::Docwu::Worker.new.generate 

      _logger.info("generate: success, #{Time.now - _start_time}")
    end

    if _need_server
      ::Docwu::Server.process(
        :Port => ::Docwu.config.params['-p'],
        :Host => ::Docwu.config.params['-a']
      )
    end
  end

end

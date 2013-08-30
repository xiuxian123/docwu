# -*- encoding : utf-8 -*-
require 'date'
module Docwu
  class Worker

    # - folder1
    #   - assets:
    #     + javascripts
    #     + images
    #     + files
    #   - doc:
    #     + 市场相关
    #     = 个人相关
    #       + happy
    #       + john
    #       - xiaozhang
    #         + learning
    #     + 基本文档
    # - folder2
    #   - layouts:
    #     - application.mustache
    #   - doc:
    #     + 基础资料
    # - assets:
    #   + javascripts
    #   + images
    # - layouts:
    #   - application.mustache
    #

    attr_reader :layouts, :data, :deploy_path, :folders, :topics

    def initialize
      @deploy_path = ::Docwu.config.deploy_path   # 部署路径

      @data = {
        'worker' => {
          'copyright' => {
            'year'    => ::Date.today.year,
            'content' => 'document world util',
            'name'    => 'Doc WU'
          }
        }
      }

      ::Docwu::Utils.hash_deep_merge!(@data['worker'], ::Docwu.config.worker)

      self.data['page'] ||= {}

      self.data['reader'] ||= {}

      # 关于目录
      @folders             = []
      @layouts             = {}
      @topics              = []

      # 布局模板
      ::Docwu.config.routes['layouts'].each do |name, path|
        _path = "#{::Docwu.config.layouts_path}/#{path}"

        if File.exists?(_path) && File.file?(_path)
          @layouts[name] = File.read(_path)
        end
      end

      #                                      原文件， 目标路径
      ::Docwu.config.routes['topics'].each do |src, path|
        _src_path = "#{::Docwu.config.topics_path}/#{src}"

        if File.exists?(_src_path) && File.file?(_src_path)
          @topics << ::Docwu::Topic.new(:src => _src_path, :path => path, :worker => self)
        end
      end

      # 计算出当前所有的 folders                源,   目标
      ::Docwu.config.routes['folders'].each do |_src, _path|
        _folder_src = "#{plain_path("/#{_src}")}"

        if File.exists?(_folder_src) && File.directory?(_folder_src)
          @folders << ::Docwu::Folder.new(:src => _folder_src, :worker => self, :path => _path)
        end
      end

      # TODO: add 更多的全局数据

      self.data['reader'].merge!(
        'global'  => {
          'folders' => self.folders_data
        }
      )

    end

    # 输出: 
    #   TODO: 先生成临时目录， 然后 -> deploy
    def generate
      # 删除要输出的路径
      FileUtils.rm_rf(self.deploy_path)

      # 复制 assets 文件进去
      FileUtils.cp_r("#{plain_path('/assets')}", "#{self.deploy_path}/")

      self.folders.each do |folder|
        folder.generate
      end

      self.topics.each do |topic|
        topic.generate
      end
    end

    def plain_path(path)
      "#{::Docwu.config.workspace}#{path}"
    end

    def folders_data
      self.folders.map(&:to_data)
    end

  end
end

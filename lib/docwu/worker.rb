# -*- encoding : utf-8 -*-
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
    #  data:
    #  src_paths
    #  asset_paths
    #  layout_paths
    #  output_path
    #
    attr_reader :src_paths, # 源文件地址们
      :output_path,         # 要输出的路径
      :folders,             # 项目文件夹们
      :asset_paths,         # assets路径
      :layouts,             # layouts路径
      :data                 # 数据

    def initialize attrs={}
      @data                = attrs[:data]      || Docwu.config.data               || {}
      @src_paths           = attrs[:src_paths] || Docwu.config.src_paths

      # 关于目录
      @folders             = {}
      @layouts             = {}

      # 静态文件目录 --------------------------------------------------------
      @asset_paths = []

      (attrs[:asset_paths] || Docwu.config.asset_paths || []).each do |_path|
        if File.exists?(_path) && File.directory?(_path)
          @asset_paths < _path
        end
      end

      layout_paths = attrs[:layout_paths] || Docwu.config.layout_paths || []

      # 计算出当前所有的asset_paths
      @src_paths.each do |_space, _path|
        _asset_path = "#{_path}/assets"

        if File.exists?(_asset_path) && File.directory?(_asset_path)
          @asset_paths << _asset_path
        end

        _layout_path = "#{_path}/layouts"

        if File.exists?(_layout_path) && File.directory?(_layout_path)
          layout_paths << _layout_path
        end

        _folder_path = "#{_path}/doc"

        puts " _folder_path---> #{_folder_path}"

        if File.exists?(_folder_path) && File.directory?(_folder_path)
          @folders[_space] = ::Docwu::Folder.new(:path => _folder_path, :worker => self, :dir => (_folder_path.sub(_path, '')), :space => _space)
        end
      end

      layout_paths.each do |_path|
        Dir.glob("#{_path}/**/*").each do |_dir|
          if File.exists?(_dir) && File.file?(_dir)
            @layouts[_dir.sub("#{_path}/", '')] = _dir
          end
        end
      end

      @output_path         = attrs[:output_path]        || Docwu.config.output_path

      # puts self.output_path
      # puts self.folders
      # puts self.layouts
      # puts self.asset_paths
    end

    # 输出: 
    #   TODO: 先生成临时目录， 然后 -> deploy
    def generate
      # 删除要输出的路径
      FileUtils.rm_rf(self.output_path)

      # 复制 assets 文件进去
      self.asset_paths.each do |_path|
        FileUtils.cp_r("#{_path}", "#{self.output_path}/")
      end

      self.folders.each do |space, folder|
        folder.generate
      end

    end

    private

  end
end

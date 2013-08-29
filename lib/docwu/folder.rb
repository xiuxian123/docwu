# -*- encoding : utf-8 -*-
module Docwu
  class Folder
    # 一个文件夹下面可能会有很多文件或文件夹的
    attr_reader :posts, :folders, :parent, :worker,
      :dest, :path, :src, :url

    def initialize attrs={}
      @worker = attrs[:worker]
      @parent  = attrs[:parent]

      @src  = attrs[:src]
      @path = attrs[:path]
      @url  = "/#{@path}"

      @dest = "#{self.worker.deploy_path}/#{self.path}"
      # -------------------------------------

      @posts   = []
      @folders = []

      ::Dir.glob("#{self.src}/*").each do |_src|
        _name = "#{_src.sub("#{self.src}/", '')}"

        if File.exists?(_src)
          if File.file?(_src) # 如果一个文件
            @posts << ::Docwu::Post.new(:src => _src, :parent => self, :worker => self.worker, :path => "#{self.path}/#{_name}")
          elsif File.directory?(_src) # 如果是一个文件夹
            @folders << self.class.new(:src => _src, :parent => self, :worker => self.worker, :path => "#{self.path}/#{_name}")
          end
        end
      end
    end

    def generate
      # TODO: index : 需要生成首页！
      self.folders.each do |folder|
        folder.generate
      end

      self.posts.each do |post|
        post.generate
      end
    end

    def folder?
      true
    end

    def post?
      false
    end

    private

  end
end

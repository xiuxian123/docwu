# -*- encoding : utf-8 -*-
module Docwu
  class Folder
    # 一个文件夹下面可能会有很多文件或文件夹的
    attr_reader :posts, :folders, :parent, :path, :worker, :dir,
      :space, :url, :dest

    def initialize attrs={}
      @path = attrs[:path]
      @worker = attrs[:worker]
      @parent  = attrs[:parent]

      # URL ---------------------------------
      @space = attrs[:space]
      @dir = attrs[:dir]

      @url = ''

      if self.space
        @url << "/#{self.space}"
      end

      @url << self.dir

      @dest = "#{self.worker.output_path}#{self.url}"
      # -------------------------------------

      @posts   = []
      @folders = []

      ::Dir.glob("#{self.path}/*").each do |_path|
        _dir = "#{self.dir}#{_path.sub(self.path, '')}"

        if File.exists?(_path)
          if File.file?(_path) # 如果一个文件
            @posts   << ::Docwu::Post.new(:path => _path, :parent => self, :worker => self.worker, :dir => _dir, :space => self.space)
          elsif File.directory?(_path) # 如果是一个文件夹
            @folders << self.class.new(:path => _path, :parent => self, :worker => self.worker, :dir => _dir, :space => self.space)
          end
        end
      end
    end

    def generate
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

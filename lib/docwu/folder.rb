# -*- encoding : utf-8 -*-
module Docwu
  class Folder
    # 一个文件夹下面可能会有很多文件或文件夹的
    attr_reader :posts, :folders, :parent, :worker, :name,
      :dest, :path, :src, :url, :index_dest,
      :parents, :content_data

    def initialize attrs={}
      @worker = attrs[:worker]
      @parent  = attrs[:parent]

      @parents = if @parent.nil?
                   []
                 else
                   @parent.parents.dup << @parent
                 end

      @src  = attrs[:src]
      @path = attrs[:path]
      @url  = "/#{@path}/index.html"

      @name = ::Docwu::Utils.filename(@path)

      @dest = "#{self.worker.deploy_path}/#{self.path}"
      @index_dest = "#{self.dest}/index.html"
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

      #  TODO: 是否从index文件中读取data呢?
    end

    def parent_datas
      self.parents.map(&:to_data)
    end

    # 转为数据
    def to_data
      {
        'name' => self.name,
        'url'  => self.url,
        'title' => self.name,
        'folders' => self.folders.map(&:to_data),
        'posts'   => self.posts.map(&:to_data)
      }
    end

    def generate
      _prepare_data

      # TODO: index : 需要生成首页！
      unless self.has_index? # 表示没有现成的首页文件，则会输出特定文件夹的首页来
        _template = self.worker.layouts['folder']

        ::Docwu::Render.generate(
          :content_data => self.content_data,
          :dest         => self.index_dest,
          :template     => _template
        )
      end

      self.folders.each do |folder|
        folder.generate
      end

      self.posts.each do |post|
        post.generate
      end
    end

    # 有首页文件了
    def has_index?
      self.posts.each do |post|
        return true if post.index?
      end

      false
    end

    def folder?
      true
    end

    def post?
      false
    end

    private

    def _prepare_data
      @content_data = ::Docwu::Utils.hash_deep_merge(self.worker.data, {
        'reader'   => {
          'folder' => self.to_data,
          'folders' => self.parent_datas,
          'global'  => {
            'folders' => self.worker.folders_data
          }
        }
      })

      # puts ""
      # puts ""
      # puts ""
      # puts ""
      # pp @content_data
    end

  end
end

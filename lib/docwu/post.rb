# -*- encoding : utf-8 -*-
module Docwu
  class Post
    # 一个文件夹下面可能会有很多文件或文件夹的
    attr_reader :parent,
      :worker,         # worker对象
      :content_data,
      :dest,           # 目标地址
      :path,           # 访问地址
      :src,            # 原文件地址
      :url,            # URL 地址
      :content_type,
      :name,
      :file_name,      # 文件名
      :datetime,
      :ranking

    def parents
      if self.parent.nil?
        []
      else
        self.parent.parents.dup << self.parent
      end
    end

    def parent_datas
      self.parents.map(&:to_data)
    end

    def initialize attrs={}
      @parent = attrs[:parent]

      @worker = attrs[:worker]

      @src = attrs[:src]

      _parse_content = self.parse_content

      # 将合并来自worker的数据
      @content_data = ::Docwu::Utils.hash_deep_merge(self.worker.data, 'page' => _parse_content[:data])  # 来自页面的数据

      @content_type = @content_data['content_type'] || 'html'

      _extend_name = case self.content_type
                     when 'html'
                       'html'
                     else
                       'html'
                     end

      # URL ---------------------------------
      _filename_extless = ::Docwu::Utils.filename_extless(attrs[:path])

      @path = "#{_filename_extless}.#{_extend_name}"
      @url  = "/#{@path}"
      @dest = "#{self.worker.deploy_path}/#{self.path}"

      @file_name = ::Docwu::Utils.filename(_filename_extless)

      @name = self.file_name
      @datetime = self.page_data['datetime']  # 创建时间
      @ranking  = self.page_data['ranking'].to_i  # 创建时间

      # puts "post to: -----------------> desc: #{self.dest}"
      # puts "                            src:  #{self.src}"
      # puts "                            path: #{self.path}"
      # puts "                            url:  #{self.url}"
      # -------------------------------------
    end

    def template
      self.worker.layouts[self.layout] || self.worker.layouts['post'] || self.worker.layouts['application']
    end

    # 是否是首页？
    def index?
      self.file_name == 'index'
    end

    def layout
      self.page_data['layout']
    end

    def outline
      @outline ||= self.page_data['outline'].to_s
    end

    def to_data
      introduction_size = 32

      introduction = "#{self.outline[0, introduction_size]}#{' ...' if self.outline.size > introduction_size}"

      {
        'name'  => self.name,
        'url'   => self.url,
        'title' => self.title,
        'outline' => self.outline,
        'introduction' => introduction
      }
    end

    # 页面数据
    def page_data
      self.content_data['page'] ||= {}
    end

    def title
      self.page_data['title'] || self.url
    end

    # 渲染
    def generate
      _prepare_data

      _parse_content = self.parse_content

      _content_text = _parse_content[:text]

      _path = self.path
      _dest = self.dest

      ::Docwu::Render.generate(
        :content_text => _content_text,
        :content_data => self.content_data,
        :dest         => _dest,
        :template     => self.template
      )
    end

    def folder?
      false
    end

    def post?
      true
    end

    # 解析正文
    def parse_content
      _content = ::File.read(self.src)

      ::Docwu::Utils.parse_marked_content(_content)
    end

    def has_folder?
      self.parent.is_a?(::Docwu::Folder)
    end

    private

    def _prepare_data
      self.content_data['reader'] ||= {}

      _data = {
        'folders' => self.parent_datas,
        'post' => self.to_data
      }

      if self.has_folder?
        (_data['folder'] ||= {}).merge!(self.parent.to_data)
      end

      # 合并, datas
      self.content_data['reader'].merge!(_data)
    end
  end
end


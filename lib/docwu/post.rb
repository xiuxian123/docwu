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
      :file_name       # 文件名

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

    def to_data
      {
        'name'  => self.name,
        'url'   => self.url,
        'title' => self.title
      }
    end

    # 页面数据
    def page_data
      self.content_data['page'] || {}
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

      # puts " -> generate post: form #{_path}  to #{_dest}"
      # puts "             layout: #{self.layout}"
      # puts "             url:    #{self.url}"
      # puts "             content_data:    #{self.content_data}"

      ::Docwu::Render.generate(
        :content_text => _content_text,
        :content_data => self.content_data,
        :content_type => self.content_type,
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

      _content_text = ''
      _content_data = {}

      # 读取页面的配置
      content_lines = _content.split(/\n/)  # 根据换行分割

      _data_lines = []
      _text_lines = []

      _data_num_a = -1
      _data_num_b = -1

      content_lines.each_with_index do |line, index|
        if line =~ /--+/
          if _data_num_a == -1
            _data_num_a = index
          elsif _data_num_b == -1
            _data_num_b = index
          else
            break
          end
        end
      end

      if _data_num_a > -1 && _data_num_b > -1
        # 说明有配置信息
        _yaml = ::YAML.load(content_lines[_data_num_a + 1, _data_num_b -1].join("\n"))

        if _yaml.is_a?(Hash)
          _content_data.merge!(_yaml)
        end

        _content_text = content_lines[_data_num_b + 1, content_lines.size].join("\n")
      else # 无页面配置信息
        _content_text = _content
      end

      {:data => _content_data, :text => _content_text}
    end

    private

    def _prepare_data
      self.content_data['reader'] ||= {}

      # 合并, datas
      self.content_data['reader'].merge!(
        'folders' => self.parent_datas,
        'global'  => {
          'folders' => self.worker.folders_data
        }
      )
    end
  end
end


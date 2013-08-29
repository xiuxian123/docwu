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
      :content_type

    def initialize attrs={}
      @parent = attrs[:parent]
      @worker = attrs[:worker]

      @src = attrs[:src]

      _parse_content = self.parse_content

      @content_data = self.worker.data.merge('page' => _parse_content[:data])

      @content_type = @content_data['content_type'] || 'html'

      _extend_name = case self.content_type
                          when 'html'
                            'html'
                          else
                            'html'
                          end

      # URL ---------------------------------
      @path = "#{::Docwu::Utils.filename_extless(attrs[:path])}.#{_extend_name}"
      @url  = "/#{@path}"

      @dest = "#{self.worker.deploy_path}/#{self.path}"

      # puts "post to: -----------------> desc: #{self.dest}"
      # puts "                            src:  #{self.src}"
      # puts "                            path: #{self.path}"
      # puts "                            url:  #{self.url}"
      # -------------------------------------
    end

    def template
      self.worker.layouts[self.layout] || self.worker.layouts['default'] || self.worker.layouts['application']
    end

    def layout
      self.page_data['layout']
    end

    def page_data
      self.content_data['page'] || {}
    end

    # 渲染
    def generate
      _parse_content = self.parse_content

      _content_text = _parse_content[:text]

      _path = self.path
      _dest = self.dest

      puts " -> generate post: form #{_path}  to #{_dest}"
      puts "             layout: #{self.layout}"
      puts "             url:    #{self.url}"
      puts "             content_data:    #{self.content_data}"

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

      {:data => ::Docwu::Utils.formated_hashed(_content_data), :text => _content_text}
    end
  end
end


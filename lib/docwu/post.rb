# -*- encoding : utf-8 -*-
module Docwu
  class Post
    # 一个文件夹下面可能会有很多文件或文件夹的
    attr_reader :parent,
      :path,           # 原地址
      :worker,         # worker对象
      :dir,            # 
      :content_data,
      :space,
      :url,
      :dest,
      :content_type

    def initialize attrs={}
      @path   = attrs[:path]
      @parent = attrs[:parent]
      @worker = attrs[:worker]

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
      puts "before: dir:#{self.dir} url: #{self.url} dest: #{self.dest} path: #{self.path}"

      @space = attrs[:space]

      @dir = "#{::Docwu::Utils.filename_extless(attrs[:dir])}.#{_extend_name}"

      @url = ''

      if self.space
        @url << "/#{self.space}"
      end

      @url << self.dir

      @dest = "#{self.worker.output_path}#{self.url}"
      puts "after: dir:#{self.dir} url: #{self.url} dest: #{self.dest} path: #{self.path}"
      # -------------------------------------

    end

    def layout
      self.worker.layouts[self.content_data['layout']] || self.worker.layouts['default.mustache']
    end

    # 渲染
    def generate
      _parse_content = self.parse_content

      _content_text = _parse_content[:text]

      _template = ::Docwu::Utils.read_file(self.layout)

      _path = self.path
      _dest = self.dest

      puts " -> generate post: form #{_path}  to #{_dest}"
      puts "             layout: #{self.layout}"
      puts "             url:    #{self.url}"
      puts "             dir:    #{self.dir}"

      ::Docwu::Render.generate(
        :content_text => _content_text,
        :content_data => self.content_data,
        :content_type => self.content_type,
        :dest         => _dest,
        :template     => _template
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
      _content = ::File.read(self.path)

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

      # _parse_content = _content.to_s.split(/---+\n/)

      # if _parse_content.size > 2 && _parse_content.first.to_s == ''
      #   # 从上下文中读取配置
      #   _yaml = ::YAML.load(_parse_content[1])

      #   if _yaml.is_a?(Hash)
      #     _content_data.merge!(_yaml)
      #   end

      #   _content_text << _parse_content[2..(_parse_content.size)].join('')
      # else
      #   _content_text << _content
      # end

      {:data => ::Docwu::Utils.formated_hashed(_content_data), :text => _content_text}
    end
  end
end


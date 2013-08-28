module Docwu
  class Post
    # 一个文件夹下面可能会有很多文件或文件夹的
    attr_reader :parent, :path, :worker, :dir, :content_data,
      :space, :url, :dest

    def initialize attrs={}
      @path   = attrs[:path]
      @parent = attrs[:parent]
      @worker = attrs[:worker]

      # URL ---------------------------------
      @space = attrs[:space]
      @dir = attrs[:dir]

      # dest
      @dest = "#{self.worker.output_path}"
      if self.space
        @dest << "/#{self.space}"
      end
      @dest << self.dir
      # -------------------------------------

      _parse_content = self.parse_content

      @content_data = {}

      self.content_data.merge!(_parse_content[:data])
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

      ::Docwu::Render.generate(
        :content_text => _content_text,
        :content_data => self.content_data,
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

      _parse_content = _content.to_s.split(/---+\n/)

      if _parse_content.size > 2 && _parse_content.first.to_s == ''
        _content_text << _parse_content[2]
        # 从上下文中读取配置
        _content_data.merge!(::YAML.load(_parse_content[1]))
      end

      {:data => _content_data, :text => _content_text}
    end
  end
end


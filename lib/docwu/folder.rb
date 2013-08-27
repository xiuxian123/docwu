module Docwu
  class Folder
    attr_reader :doc_path, 
      :name, 
      :default_marktype, 
      :output_path,
      :asset_files_map,   # 静态文件的map表
      :doc_files_map,
      :layout_files_map,  # 布局文件的map表
      :space

    def initialize attrs={}
      @doc_path             = attrs[:doc_path]
      @name                 = attrs[:name]
      @default_marktype     = attrs[:default_marktype]
      @output_path          = attrs[:output_path]
      @space                = attrs[:space]

      @asset_files_map  = {}
      @doc_files_map    = {}
      @layout_files_map = {}

      _perform_parse_context
    end

    def output!
      self.doc_files_map.each do |_path, _dir|
        content = File.read(_dir)
      
        content_html = ""
        content_text = ''
        context_data = {}

        _parse_content = content.split(/---+\n/)

        if _parse_content.size > 2 && _parse_content.first.to_s == ''
          content_text << _parse_content[2]
          context_data = context_data.merge(::YAML.load(_parse_content[1]))
        end

        # 读取标记类型
        marktype = context_data['marktype'] || self.default_marktype

        layout_file_path = self.layout_files_map[context_data['layout']] || self.layout_files_map['default.mustache']

        case marktype
        when :markdown
          _mark_options = [:hard_wrap, :autolink, :no_intraemphasis, :fenced_code, :gh_blockcode]

          content_html << ::RedcarpetCompat.new(content_text, *_mark_options).to_html
        else
          # FIXME: no
        end

        puts ::MustacheRender::Mustache.render(File.read(layout_file_path), {:title => 'Hello World', :content => content_html})
        # puts layout_file_path
        # puts context_data
        # puts content_html
      end
    end

    private

    def _perform_parse_context
      # 解析静态文件的配置
      _assets_path = "#{doc_path}/assets"

      ::Dir.glob("#{_assets_path}/**/*").each do |_dir|
        if File.file?(_dir) && File.exists?(_dir)
          self.asset_files_map["#{_dir.sub("#{_assets_path}/", '')}"] = _dir
        end
      end

      _doc_path = "#{doc_path}/doc"

      # 解析文档文件
      ::Dir.glob("#{_doc_path}/**/*").each do |_dir|
        if File.file?(_dir) && File.exists?(_dir)
          self.doc_files_map["#{_dir.sub(doc_path, '')}"] = _dir
        end
      end

      _layouts_path = "#{doc_path}/layouts"

      ::Dir.glob("#{_layouts_path}/**/*").each do |_dir|
        if File.file?(_dir) && File.exists?(_dir)
          self.layout_files_map["#{_dir.sub("#{_layouts_path}/", '')}"] = _dir
        end
      end

    end
  end
end

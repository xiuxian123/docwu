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

    end

    def generate
      _perform_parse_context

      self.doc_files_map.each do |_path, _dir|
        content = File.read(_dir)

        content_html = ''
        content_text = ''
        context_data = {
          'title' => ""
        }

        _parse_content = content.split(/---+\n/)

        if _parse_content.size > 2 && _parse_content.first.to_s == ''
          content_text << _parse_content[2]

          # 从context中读取配置
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

        context_data['content'] = content_html

        # 页面的内容
        _page_content = ::MustacheRender::Mustache.render(File.read(layout_file_path), context_data)

        _page_output_path = "#{self.output_path}#{_path}.html"

        write_file_with_content _page_output_path, _page_content

        puts " page_content --> #{_page_content}"
        puts " path -> #{_page_output_path}"

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

      self.asset_files_map.each do |_dest, _dir|
        copy_with_path(_dir, "#{self.output_path}/#{_dest}")
      end

      _doc_path = "#{doc_path}/doc"

      # 解析文档文件
      ::Dir.glob("#{_doc_path}/**/*").each do |_dir|
        if File.file?(_dir) && File.exists?(_dir)
          _filepath = "#{_dir.sub(_doc_path, '')}"
          # 获取文件名，无扩展名
          _filename_with_path = _filepath.chomp(File.extname(_filepath))
          self.doc_files_map[_filename_with_path] = _dir
        end
      end

      _layouts_path = "#{doc_path}/layouts"

      ::Dir.glob("#{_layouts_path}/**/*").each do |_dir|
        if File.file?(_dir) && File.exists?(_dir)
          self.layout_files_map["#{_dir.sub("#{_layouts_path}/", '')}"] = _dir
        end
      end

    end

    private

    # 根据内容，文件名来写文件
    def write_file_with_content dst, content=''
      FileUtils.mkdir_p(File.dirname(dst))

      file = File.new(dst, 'w')
      file.write(content)
      file.close
    end

    def copy_with_path(src, dst)
      FileUtils.mkdir_p(File.dirname(dst))
      FileUtils.cp_r(src, dst)
    end
  end
end

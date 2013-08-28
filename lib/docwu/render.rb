module Docwu
  class Render
    class << self
      def generate(*args)
        self.new.generate(*args)
      end
    end

    def generate(options={})
      content_data = options[:content_data] || {}
      content_text = options[:content_text] || ''
      content_result = ''
      dest         = options[:dest]
      template     = options[:template]

      # 读取标记类型
      marktype = (content_data['marktype'] || 'markdown').to_s
      content_type = (content_data['content_type'] || 'html').to_s

      case marktype
      when 'markdown'
        _mark_options = [:hard_wrap, :autolink, :no_intraemphasis, :fenced_code, :gh_blockcode]

        content_result << ::RedcarpetCompat.new(content_text, *_mark_options).to_html
      else
        # FIXME: no
      end

      content_data['content'] = content_result

      puts " --------------------> write to: #{dest}, #{content_result}"

      # 页面的内容
      ::Docwu::Utils.write_file dest, ::MustacheRender::Mustache.render(template, content_data)
    end

  end
end

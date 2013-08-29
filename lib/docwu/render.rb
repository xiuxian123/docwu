# -*- encoding : utf-8 -*-
require 'redcarpet'
require 'coderay'
require "nokogiri"

module Docwu
  class Render
    class << self
      def generate(*args)
        self.new.generate(*args)
      end
    end

    #
    # usage:
    #   ::Docwu::Render.generate(
    #     :content_data => ''
    #   )
    # options:
    #   - content_data
    #   - content_text
    #   - dest
    #   - template
    #
    def generate(options={})
      content_data = options[:content_data] || {}
      content_text = options[:content_text] || ''
      content_result = ''
      dest         = options[:dest]
      template     = options[:template]

      # 读取标记类型
      marktype = (content_data['marktype'] || 'markdown').to_s

      case marktype
      when 'markdown'
        _mark_options = [:hard_wrap, :autolink, :no_intraemphasis, :fenced_code, :gh_blockcode]

        content_result << ::Docwu::Utils.syntax_highlighter(
          ::RedcarpetCompat.new(content_text, *_mark_options).to_html
        )
      else
        # FIXME: no
      end

      content_data['page'] ||= {}
      content_data['page']['content'] = content_result

      ::Docwu::Utils.formated_hashed!(content_data)

      # pp content_data
      # puts "#{template}"

      # 页面的内容
      ::Docwu::Utils.write_file dest, ::MustacheRender::Mustache.render(template, content_data)
    end

  end
end

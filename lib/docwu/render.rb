# -*- encoding : utf-8 -*-
require 'redcarpet'
require 'coderay'
require "nokogiri"
# require "pdfkit"

module Docwu
  class Render
    class << self
      def generate(*args)
        self.new.generate(*args)
      end
    end

    # 生成pdf
    # https://github.com/pdfkit/PDFKit
    # def generate_pdf options={}
    #   kit = ::PDFKit.new(::File.new(options[:dest]))
    # end

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

      # 目录
      _catalogs = []

      case marktype
      when 'markdown'
        _mark_options = [
          :hard_wrap,
          :autolink,
          :no_intraemphasis,
          :fenced_code,
          :gh_blockcode,
          :tables,
          :footnotes,
          :superscript,
          :underline,
          :strikethrough,
          :space_after_headers,
          :quote,
          :highlight
        ]

        _html = ::RedcarpetCompat.new(content_text, *_mark_options).to_html

        # markdown = Redcarpet::Markdown.new(
        #   Redcarpet::Render::HTML,
        #   :autolink            => true,
        #   :space_after_headers => true,    # 头部必须有个空格
        #   :fenced_code_blocks  => true,    # ```括起来的代码段落
        #   :strikethrough       => true,    # ~~ 删除
        #   :superscript         => true,
        #   :underline           => true,
        #   :highlight           => true,
        #   :quote               => true,
        #   :footnotes           => true,
        #   :hard_wrap           => true
        # )

        # _html = markdown.render(content_text)

        # 获取一个html代码的目录结果
        _catalogs_result = ::Docwu::Utils.html_catalogable(_html)

        _catalogs = _catalogs_result['catalogs']

        content_result << ::Docwu::Utils.syntax_highlighter(_catalogs_result['html'])
      else
        # FIXME: no
      end

      content_data['page'] ||= {}

      # 正文
      content_data['page']['content'] = content_result
      content_data['page']['content_present?'] = content_result.size > 0

      # 目录
      content_data['page']['catalogs'] = _catalogs

      ::Docwu::Utils.formated_hashed!(content_data)

      # pp content_data
      # puts "#{template}"

      # 页面的内容
      ::Docwu::Utils.write_file dest, ::MustacheRender::Mustache.render(template, content_data)
    end

  end
end

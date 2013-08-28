module Docwu
  class Utils
    class << self
      def filename_extless _path=''
        _path.chomp(File.extname(_path))
      end

      def read_file path
        ::File.read(path)
      end

      def write_file dst, content=''
        ::FileUtils.mkdir_p(::File.dirname(dst))

        file = ::File.new(dst, 'w')
        file.write(content)
        file.close
      end

      # 复制文件 或者 文件夹
      def copy_with_path(src, dst)
        ::FileUtils.mkdir_p(::File.dirname(dst))
        ::FileUtils.cp_r(src, dst)
      end

      def syntax_highlighter(html)
        doc = ::Nokogiri::HTML(html)

        doc.search("//pre").each do |pre|
          lang = pre.attr('lang')

          if lang
            _lang_class = pre.attr('class').to_s.split(' ').select {|_itm| _itm.include?('lang-') }.first

            if _lang_class
              lang = _lang_class.gsub('lang-', '')
            end
          end

          # debugger
          if pre_code=pre.css('code')
            lang = pre_code.attr('class').to_s
          end

          unless lang
            lang = :text
          end

          text = pre.text.rstrip

          begin
            pre.replace ::CodeRay.scan(text, lang).div.to_s
          rescue Exception => error
            puts "#{__FILE__} syntax_highlighter error: \ntext => #{text} \nlang => #{lang}\n origin error:#{error}"
          end
        end

        doc.css('body').inner_html.to_s
      end

    end
  end
end


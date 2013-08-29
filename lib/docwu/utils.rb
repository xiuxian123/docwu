# -*- encoding : utf-8 -*-
module Docwu
  class Utils
    class << self
      def hash_deep_merge(hash, other_hash)
        hash.merge(other_hash) do |key, oldval, newval|
          oldval = oldval.to_hash if oldval.respond_to?(:to_hash)
          newval = newval.to_hash if newval.respond_to?(:to_hash)
          oldval.class.to_s == 'Hash' && newval.class.to_s == 'Hash' ? self.hash_deep_merge(oldval, newval) : newval
        end
      end

      def hash_deep_merge!(hash, other_hash)
        hash.replace(self.hash_deep_merge(hash, other_hash))
      end

      def formated_hashed! hash={}
        hash.replace(self.formated_hashed(hash))
      end

      # 将hash中所有非hash的类型，转为hash, 以便前端调用
      def formated_hashed hash={}
        _res = {}

        hash.each do |key, value|
          if value.is_a?(Array)
            _res[key] = value.map do |_val|
              if _val.is_a?(Hash)
                self.formated_hashed(_val)
              else
                {'value' => _val}
              end
            end

            _res["#{key}_any?"] = value.any?
            _res["#{key}_count"] = value.size

          elsif value.is_a?(Hash)
            _res[key] = self.formated_hashed(value)
          else
            _res[key] = value
          end
        end

        _res
      end

      # 获取文件名
      def filename path=''
        path.split('/').last
      end

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
            # TODO: error log
            # puts "#{__FILE__} syntax_highlighter error: \ntext => #{text} \nlang => #{lang}\n origin error:#{error}"
          end
        end

        doc.css('body').inner_html.to_s
      end

    end

  end
end


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
          # begin
          #   if pre_code=pre.css('code')
          #     lang = pre_code.attr('class').to_s
          #   end
          # rescue
          # end

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

      # 解析 mark
      def parse_marked_content src_content=''
        _content_text = ''
        _content_data = {}

        # 读取页面的配置
        content_lines = src_content.split(/\n/)  # 根据换行分割

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
          _content_text = src_content
        end

        {:data => _content_data, :text => _content_text}

      end

      # 获取一个html代码的目录结果
      def html_catalogable html=''
        doc = ::Nokogiri::HTML(html)

        paths = doc.xpath('//h1|//h2|//h3|//h4|//h5|//h6')

        index = 1

        catalogs = paths.map do |path|
          _name = path.name
          _text = path.text

          _anchor = "markup-#{_name}-#{index}"

          index += 1

          path.replace("<#{_name}><a name='#{_anchor}'></a>#{_text}</#{_name}>")

          {
            'text'   => _text,
            'name'   => _name,
            'anchor' => _anchor
          }
        end

        {
          'catalogs' => catalogs,
          'html'     => doc.css('body').inner_html.to_s
        }
      end
    end

  end
end


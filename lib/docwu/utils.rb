module Docwu
  class Utils
    class << self

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

    end
  end
end


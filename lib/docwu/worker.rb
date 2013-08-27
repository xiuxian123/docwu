# -*- encoding : utf-8 -*-
module Docwu
  class Worker
    attr_reader :layout_file_path, :doc_paths, :output_path, :default_marktype, :output_type,
      :layout_template, # 布局文件的模板
      :folders

    def initialize attrs={}
      @doc_paths           = attrs[:doc_paths]        || Docwu.config.doc_paths
      @output_path         = attrs[:output_path]      || Docwu.config.output_path
      @default_marktype    = attrs[:default_marktype] || Docwu.config.default_marktype || :markdown
      @output_type         = attrs[:output_type]      || Docwu.config.output_type      || :html
      @folders             = {}

      _perform_validate_attrs
      _perform_parse_context
    end

    # 输出
    def output!
      self.folders.each do |space, folder|
        folder.output!
      end
    end

    private

    # 执行参数校验
    def _perform_validate_attrs

    end

    # 解析上下文
    def _perform_parse_context
      self.doc_paths.each do |doc|
        if File.directory?(doc[:path])
          @folders[doc[:space]] = ::Docwu::Folder.new(
            :doc_path         => doc[:path],
            :name             => doc[:name],
            :layout_file_path => self.layout_file_path,
            :default_marktype => self.default_marktype,
            :output_path      => self.output_path,
            :space            => doc[:space]
          )
        end
      end
    end
  end
end

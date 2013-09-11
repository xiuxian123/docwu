# -*- encoding : utf-8 -*-
module Docwu
  class Topic
    attr_reader :worker, :dest, :path, :src, :url, :content_data, :file_name, :name, :title

    def initialize attrs={}
      @worker = attrs[:worker]

      @path = attrs[:path]
      @src = attrs[:src]

      _parse_content = self.parse_content

      # 将合并来自worker的数据
      @content_data = ::Docwu::Utils.hash_deep_merge(self.worker.data, 'page' => _parse_content[:data])  # 来自页面的数据

      # URL ---------------------------------
      _filename_extless = ::Docwu::Utils.filename_extless(self.path)

      @url  = "/#{@path}"
      @dest = "#{self.worker.tmp_deploy_path}/#{self.path}"

      @file_name = ::Docwu::Utils.filename(_filename_extless)

      @name = self.content_data['page']['name'] || self.file_name

      # -------------------------------------
    end

    # 页面数据
    def page_data
      self.content_data['page'] ||= {}
    end

    def title
      self.page_data['title'] || self.url
    end

    def url
      self.path
    end

    def to_data
      {
        'name'  => self.name,
        'url'   => self.url,
        'title' => self.title
      }
    end

    def generate
      _prepare_data

      _parse_content = self.parse_content

      _content_text = _parse_content[:text]

      ::Docwu::Render.generate(
        :content_text => _content_text,
        :content_data => self.content_data,
        :dest         => self.dest,
        :template     => self.template
      )
    end

    def layout
      self.page_data['layout']
    end

    def template
      self.worker.layouts[self.layout] || self.worker.layouts['topic'] || self.worker.layouts['application']
    end

    # 解析正文
    def parse_content
      _content = ::File.read(self.src)

      ::Docwu::Utils.parse_marked_content(_content)
    end

    private

    def _prepare_data
      self.content_data['reader'] ||= {}

      _data = {
        'topic' => self.to_data
      }

      # 合并, datas
      self.content_data['reader'].merge!(_data)
    end
  end
end

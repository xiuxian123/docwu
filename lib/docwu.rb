# -*- encoding : utf-8 -*-
require "#{File.dirname(__FILE__)}/docwu/config"
require "#{File.dirname(__FILE__)}/docwu/utils"
require "#{File.dirname(__FILE__)}/docwu/worker"
require "#{File.dirname(__FILE__)}/docwu/render"
require "#{File.dirname(__FILE__)}/docwu/folder"
require "#{File.dirname(__FILE__)}/docwu/post"
require "#{File.dirname(__FILE__)}/docwu/category"
require "#{File.dirname(__FILE__)}/docwu/server"

require 'yaml'
require 'fileutils'
require 'mustache_render'

module Docwu

  def self.generate
    Docwu::Worker.new.generate
  end

end

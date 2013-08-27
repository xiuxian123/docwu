# -*- encoding : utf-8 -*-
require "#{File.dirname(__FILE__)}/docwu/config"
require "#{File.dirname(__FILE__)}/docwu/worker"
require "#{File.dirname(__FILE__)}/docwu/folder"
require "#{File.dirname(__FILE__)}/docwu/server"

require 'redcarpet'
require 'coderay'
require 'yaml'
require 'fileutils'
require 'mustache_render'

module Docwu

  def self.generate
    Docwu::Worker.new.generate
  end

end

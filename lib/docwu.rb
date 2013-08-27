# -*- encoding : utf-8 -*-
require "#{File.dirname(__FILE__)}/docwu/config"
require "#{File.dirname(__FILE__)}/docwu/worker"
require "#{File.dirname(__FILE__)}/docwu/folder"

require 'redcarpet'
require 'coderay'
require 'yaml'
require 'mustache_render'

module Docwu

  def self.output!
    Docwu::Worker.new.output!
  end

end

# -*- encoding : utf-8 -*-
require 'spec_helper'

describe ::Docwu::Utils do
  context 'html_catalogable' do
    it 'start ok' do
    end

    it '解析成功' do
      html = <<-HTML_END
<h1>title 1</h1>
helloworld headline 1
<h2>title 1-1</h2>
helloworld headline 1-1
<div><h1>inner</h1></div>
<h3>title 1-1-1</h3>
<h4>title 1-1-1-1</h4>
<h4>title 1-1-1-2</h4>
<h4>title 1-1-1-3</h4>
<h2>title 1-2</h2>
<h3>title 1-2-1</h3>
<h4>title 1-2-1-1</h4>
<h4>title 1-2-1-2</h4>
<h4>title 1-2-1-3</h4>
<h2>title 1-3</h2>
<h1>title 2</h1>
<h1>title 3</h1>
<h1>title 4</h1>
<h1>title 5</h1>
      HTML_END

      catalogs = ::Docwu::Utils.html_catalogable(html)

      puts catalogs
    end
  end
end

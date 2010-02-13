class DocsController < ApplicationController
  def show_doc
    doc = request.path.split('/').last
    render "#{doc}.html"
  end
end

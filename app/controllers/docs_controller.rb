class DocsController < ApplicationController
  def show
    render :action => params[:path].join('/')
  end
end

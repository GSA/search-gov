class FormsController < ApplicationController
  
  def index
    @serch = FormSearch.new
    @title = "Form Search Home - "
  end
end

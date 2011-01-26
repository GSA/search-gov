class FormsController < ApplicationController

  def index
    @title = "Form Search Home - "
    @top_forms = []
    1.upto(3) do |index|
      @top_forms << TopForm.find_all_by_column_number(index, :order => 'sort_order ASC')
    end
  end
end

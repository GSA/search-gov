class Admin::TopFormsController < Admin::AdminController
  before_filter :setup_variables
  
  def index
    load_top_forms
  end
  
  def create
    @top_form = TopForm.new(params[:top_form].merge(:column_number => @column_number))
    if @top_form.save
      flash[:success] = "Successfully added top form to Column #{@top_form.column_number} in position #{@top_form.sort_order}."
    else
      flash[:error] = "The Top Form could not be saved.  Please verify that you haven't duplicated any sort numbers."
    end
    load_top_forms
    redirect_to admin_top_forms_path(:column_number => @column_number)
  end
  
  def update
    @updated_top_form = TopForm.find(params[:id])
    @updated_top_form.update_attributes(params[:top_form])
    load_top_forms
    redirect_to admin_top_forms_path(:column_number => @column_number)
  end
  
  def destroy
    @top_form = TopForm.find(params[:id])
    @top_form.destroy
    flash[:success] = "Successfully Removed Top Form."
    load_top_forms
    redirect_to admin_top_forms_path(:column_number => @column_number)
  end
  
  private
  
  def setup_variables
    @column_number = (params[:column_number] || "1").to_i
    @top_form = TopForm.new(:column_number => @column_number)
  end
  
  def load_top_forms
    @top_forms = TopForm.find_all_by_column_number(@column_number, :order => 'sort_order ASC')
  end
end
class CseAnnotationsController < ApplicationController

  def index
    @cse_annotations = CseAnnotation.all
  end

end

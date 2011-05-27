class GovForm < ActiveRecord::Base
  validates_presence_of :name, :form_number, :agency, :description, :url
end

class AutoRecall < ActiveRecord::Base
  belongs_to :recall
  
  def to_json(options = {})
    hash = {:make => self.make, :model => self.model, :year => self.year, :component_description => self.component_description, :manufacturing_begin_date => self.manufacturing_begin_date, :manufacturing_end_date => self.manufacturing_end_date, :manufacturer => self.manufacturer, :recalled_component_id => self.recalled_component_id}
    hash.to_json
  end
end

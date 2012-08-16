class Form < ActiveRecord::Base
  DETAIL_FIELD_NAMES = [:title, :file_size, :landing_page_url].freeze
  attr_accessible :agency, :number, :url, :file_type
  validates_presence_of :agency, :number, :url, :file_type
  serialize :details, Hash

  DETAIL_FIELD_NAMES.each do |name|
    define_method name do
      send(:details).send("[]", name)
    end

    define_method :"#{name}=" do |arg|
      send(:details).send("[]=", name, arg)
    end
  end
end

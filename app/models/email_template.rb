class EmailTemplate < ActiveRecord::Base
  validates_presence_of :name, :body
  validates_uniqueness_of :name

  class << self
    
    def load_default_templates
      EmailTemplate.destroy_all
      emailer_directory = Dir.glob(Rails.root.to_s + "/db/email_templates/*")
      emailer_directory.each do |email_file|
        name = email_file.split("/").last.split(".").first
        body = File.read(email_file)
        EmailTemplate.create!(:name => name, :body => body)
      end
    end
  end
end

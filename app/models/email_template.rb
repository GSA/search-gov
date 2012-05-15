class EmailTemplate < ActiveRecord::Base
  validates_presence_of :name, :body
  validates_uniqueness_of :name

  class << self
    
    def load_default_templates(template_list = [])
      emailer_directory = Dir.glob(Rails.root.to_s + "/db/email_templates/*")
      emailer_directory.each do |email_file|
        name = email_file.split("/").last.split(".").first
        next if template_list.any? and !template_list.include?(name)
        EmailTemplate.delete_all(["name=?", name])
        body = File.read(email_file)
        EmailTemplate.create!(:name => name, :body => body)
      end
    end
  end
end

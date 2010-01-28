require 'rexml/document'

namespace :usasearch do
  namespace :faq do

    desc "Load an XML file of FAQs into the database"
    task :load, :faq_file_name, :needs => :environment do |t, args|
      RAILS_DEFAULT_LOGGER.error("usage: rake usasearch:faq:load[ faq_file_name ]") and return if (args.faq_file_name.nil?)
      doc = REXML::Document.new(File.new(args.faq_file_name))
      Faq.delete_all
      doc.root.elements.each('Row') do |row|
        items = row.elements.to_a('Item')
        Faq.create(:url => items[0].text,
                   :question => items[1].text,
                   :answer => items[2].text,
                   :ranking => items[3].text.to_i)
      end
    end
    
    desc "Delete all existing FAQs in the database"
    task :clean, :needs => :environment do |t, args|
      Faq.delete_all
    end  
  end
end
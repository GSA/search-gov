require 'rexml/document'

namespace :usasearch do
  namespace :gov_form do

    desc "Load an XML file of FAQs into the database"
    task :load, :form_file_name, :needs => :environment do |t, args|
      if !args.form_file_name
        Rails.logger.error("usage: rake usasearch:faq:load[ form_file_name ]")
      else
        doc = REXML::Document.new(File.new(args.form_file_name))
        GovForm.delete_all
        doc.root.elements.each('XMLDump') do |form|
          @bureau = form.elements['Bureau'].text if form.elements['Bureau']
          @description = form.elements['Description'].text if form.elements['Description']
          GovForm.create( :name => form.elements['Name'].text,
                          :form_number => form.elements['Form_x0020_Number'].text.strip,
                          :agency => form.elements['Agency'].text,
                          :bureau => @bureau,
                          :description => @description,
                          :url => form.elements['URL'].text)
        end
        GovForm.reindex
      end
    end
    
    desc "Delete all existing FAQs in the database"
    task :clean, :needs => :environment do |t, args|
      GovForm.delete_all
    end  
  end
end
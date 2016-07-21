class RenameAffiliateAndFcImageColumns < ActiveRecord::Migration
  def change
    %i{image_file_name image_content_type image_file_size image_updated_at}.each do |col|
       rename_column :featured_collections, col, "rackspace_#{col}"
       rename_column :featured_collections, "aws_#{col}", col
    end

    %i{header_tagline_logo header_image page_background_image mobile_logo}.each do |image|
      %w{file_name content_type file_size updated_at}.each do |col|
        rename_column :affiliates, "#{image}_#{col}", "rackspace_#{image}_#{col}"
        rename_column :affiliates, "aws_#{image}_#{col}", "#{image}_#{col}"
      end
    end
  end
end

class ChangeAffiliateStringColsToText < ActiveRecord::Migration
  def self.up
    change_column :affiliates, :staged_domains, :text
    change_column :affiliates, :staged_header,  :text
    change_column :affiliates, :staged_footer,  :text

    Affiliate.all.each { |aff| aff.update_attributes( :staged_domains => aff.domains, :staged_header => aff.header, :staged_footer => aff.footer) }
  end

  def self.down
  end
end

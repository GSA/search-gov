class SetThemeColumnsOnAffiliates < ActiveRecord::Migration
  def self.up
    Affiliate.all.each do |a|
      next if a.uses_one_serp?
      a.theme = 'default' if a.theme.blank?
      a.staged_theme = 'default' if a.staged_theme.blank?
      a.save!
    end
  end

  def self.down
  end
end

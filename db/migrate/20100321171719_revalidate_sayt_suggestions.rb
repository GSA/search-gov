class RevalidateSaytSuggestions < ActiveRecord::Migration
  def self.up
    SaytSuggestion.all.each{|sayt| sayt.delete unless sayt.valid?}
  end

  def self.down
  end
end

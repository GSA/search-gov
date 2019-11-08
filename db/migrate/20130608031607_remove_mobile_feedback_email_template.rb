class RemoveMobileFeedbackEmailTemplate < ActiveRecord::Migration
  def up
    EmailTemplate.where(name: 'mobile_feedback').delete_all
  end

  def down
    EmailTemplate.load_default_templates(%w(mobile_feedback))
  end
end

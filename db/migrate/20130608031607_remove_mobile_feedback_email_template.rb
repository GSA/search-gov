class RemoveMobileFeedbackEmailTemplate < ActiveRecord::Migration
  def up
    EmailTemplate.delete_all(name: 'mobile_feedback')
  end

  def down
    EmailTemplate.load_default_templates(%w(mobile_feedback))
  end
end

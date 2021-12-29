class SeedSubjectOnEmailTemplates < ActiveRecord::Migration
  def self.up
    EmailTemplate::DEFAULT_SUBJECT_HASH.each do |name, subject|
      template = EmailTemplate.find_by_name(name)
      template.update!(:subject => subject)
    end
  end

  def self.down
  end
end

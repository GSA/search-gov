class UpdateEmailTemplatesEmailAddress < ActiveRecord::Migration[6.1]
  def change
    EmailTemplate.load_default_templates

    update_searchgov_email
    update_email_template_body(
      'affiliate_header_footer_change',
      'copy the code below. Paste it into the',
      'copy the code below and paste it into the'
    )
    update_email_template_body(
      'welcome_to_new_user',
      'please request a colleague add you',
      'please request a colleague to add you'
    )
  end

  def update_searchgov_email
    templates = EmailTemplate.where("body LIKE ?", "%search@support.digitalgov.gov%")
    templates.each do |t|
      t.body.gsub!('search@support.digitalgov.gov', 'search@gsa.gov')
      t.save
    end
  end

  def update_email_template_body(name, from, to)
    template = EmailTemplate.find_by(name: name)
    return if template.nil?

    template.body.gsub!(from, to)
    template.save
  end
end

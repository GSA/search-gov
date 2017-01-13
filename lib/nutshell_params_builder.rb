module NutshellParamsBuilder
  def get_contact_params(id)
    { contactId: id }
  end

  def search_contacts_params(email)
    [email, 1]
  end

  def edit_contact_non_email_params(user)
    { contactId: user.nutshell_id,
      rev: 'REV_IGNORE'
    }.merge contact_params(user)
  end

  def edit_contact_email_params(user, contact)
    contact_emails = extract_contact_emails contact.email

    unless user_email_overlap?(user.email, contact_emails)
      emails = [user.email] | contact_emails
      email_hash = build_email_hash emails

      { contactId: contact.id,
        contact: { email: email_hash },
        rev: contact.rev }
    end
  end

  def extract_contact_emails(contact_emails)
    return [] unless contact_emails.present?

    emails = contact_emails
    emails &&= contact_emails.values if contact_emails.is_a?(Hash)
    emails.compact.uniq.reject(&:blank?)
  end

  def user_email_overlap?(user_email, contact_emails)
    contact_emails.present? &&
      contact_emails.map(&:downcase).include?(user_email.downcase)
  end

  def build_email_hash(emails)
    Hash[emails.each_with_index.map { |email, i| [i.to_s, email] }]
  end

  def new_contact_params(user)
    params = contact_params(user)
    params[:contact][:email] = [user.email]
    params
  end

  def contact_params(user)
    {
      contact: {
        customFields: {
          :'Approval status' => user.nutshell_approval_status,
          :'Super Admin URL' => "https://search.usa.gov/admin/users?search[id]=#{user.id}"
        },
        name: user.contact_name
      }
    }
  end

  def new_lead_params(site)
    {
      lead: {
        contacts: lead_contacts(site),
        createdTime: site.created_at.to_datetime.iso8601,
        customFields: lead_custom_fields(site),
        description: lead_description(site)
      }
    }
  end

  def edit_lead_params(site)
    params = {
      leadId: site.nutshell_id,
      rev: 'REV_IGNORE',
      lead: {
        contacts: lead_contacts(site),
        customFields: lead_custom_fields(site),
        description: lead_description(site),
      }
    }

    params[:lead][:outcome] = { id: 3 } if site.status.inactive_deleted?
    params
  end

  def lead_contacts(site)
    site.users.pluck(:nutshell_id).compact.uniq.map do |user_nutshell_id|
      { id: user_nutshell_id }
    end
  end

  def lead_custom_fields(site)
    {
      :'Admin Center URL' => "https://search.usa.gov/sites/#{site.id}",
      :'Homepage URL' => site.website,
      :'Previous month query count' => site.last_month_query_count,
      :'SERP URL' => "https://search.usa.gov/search?affiliate=#{site.name}",
      :'Site handle' => site.name,
      :'Super Admin URL' => "https://search.usa.gov/admin/affiliates?search[id]=#{site.id}"
    }
  end

  def lead_description(site)
    "(#{site.name}) #{site.display_name}".squish.truncate(100, separator: ' ')
  end

  def new_note_params(entity, note)
    entity_type = entity.is_a?(User) ? 'Contacts' : 'Leads'

    {
      entity: {
        entityType: entity_type,
        id: entity.nutshell_id,
      },
      note: note,
    }
  end
end

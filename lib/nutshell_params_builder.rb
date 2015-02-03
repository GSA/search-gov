module NutshellParamsBuilder
  def edit_contact_params(user)
    new_contact_params(user).merge(
      {
        contactId: user.nutshell_id,
        rev: 'REV_IGNORE'
      }
    )
  end

  def new_contact_params(user)
    {
      contact: {
        customFields: {
          :'Approval status' => user.approval_status,
          :'Super Admin URL' => "http://search.usa.gov/admin/users?search[id]=#{user.id}"
        },
        email: [user.email],
        name: user.contact_name
      }
    }
  end

  def new_lead_params(site)
    {
      lead: {
        contacts: lead_contacts(site),
        createdTime: site.created_at.to_datetime.iso8601,
        customFields: new_lead_custom_fields(site),
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

    if site.status.inactive_deleted?
      params[:lead][:customFields][:Status] = Status::INACTIVE_DELETED_NAME
    end
    params
  end

  def lead_contacts(site)
    site.users.pluck(:nutshell_id).compact.map do |user_nutshell_id|
      { id: user_nutshell_id }
    end
  end

  def new_lead_custom_fields(site)
    lead_custom_fields(site).merge(Status: site.status.name)
  end

  def lead_custom_fields(site)
    {
      :'Admin Center URL' => "http://search.usa.gov/sites/#{site.id}",
      :'Homepage URL' => site.website,
      :'Previous month query count' => site.last_month_query_count,
      :'SERP URL' => "http://search.usa.gov/search?affiliate=#{site.name}",
      :'Site handle' => site.name,
      :'Super Admin URL' => "http://search.usa.gov/admin/affiliates?search[id]=#{site.id}"
    }
  end

  def lead_description(site)
    "#{site.display_name} (#{site.name})"
  end
end

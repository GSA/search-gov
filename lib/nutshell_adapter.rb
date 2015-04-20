class NutshellAdapter
  include NutshellParamsBuilder
  attr_reader :client

  def initialize
    @client = NutshellClient.new if NutshellClient.enabled?
  end

  def push_user(user)
    user.nutshell_id? ? edit_contact(user) : new_contact(user)
  end

  def edit_contact(user)
    on_client_present do
      params = edit_contact_non_email_params(user)
      is_success, body = client.post __method__, params

      if is_success && body && body.result && body.result.id
        edit_contact_email(user, body.result)
      elsif !is_success && body.error && body.error.message =~ /contact has been merged|invalid contact/i
        update_user_with_nutshell_id(user, nil)
      end
    end
  end

  def edit_contact_email(user, contact)
    on_client_present do
      params = edit_contact_email_params(user, contact)
      client.post(:edit_contact, params) if params
    end
  end

  def new_contact(user)
    contact = get_contact_by_email user.email
    if contact
      update_user_with_nutshell_id(user, contact.id)
      return edit_contact(user)
    end

    when_post_response_has_result_id __method__, new_contact_params(user) do |result|
      update_user_with_nutshell_id(user, result.id)
    end
  end

  def get_contact(id)
    contact = nil
    params = get_contact_params(id)
    when_post_response_has_result_id(__method__, params) do |result|
      contact = result
    end
    contact
  end

  def get_contact_by_email(email)
    contact = nil

    params = search_contacts_params(email)
    when_post_is_successful :search_contacts, params do |body|
      if body.result.present?
        candidate = get_contact body.result.first.id
        candidate_emails = extract_contact_emails candidate.email
        contact = candidate if user_email_overlap?(email, candidate_emails)
      end
    end

    contact
  end

  def push_site(site)
    site.nutshell_id? ? edit_lead(site) : new_lead(site)
  end

  def new_lead(site)
    when_post_response_has_result_id __method__, new_lead_params(site) do |result|
      site.update_attributes(nutshell_id: result.id)
    end
  end

  def edit_lead(site)
    on_client_present { client.post __method__, edit_lead_params(site) }
  end

  def new_note(entity, note)
    on_client_present do
      return unless entity.nutshell_id
      client.post __method__, new_note_params(entity, note)
    end
  end

  private

  def when_post_is_successful(method, params)
    on_client_present do
      is_success, rash = client.post method, params
      yield rash if is_success
    end
  end

  def when_post_response_has_result_id(method, params)
    on_client_present do
      is_success, rash = client.post method, params
      if is_success && rash && rash.result && rash.result.id
        yield rash.result
      end
      [is_success, rash]
    end
  end

  def on_client_present
    yield if client
  end

  def update_user_with_nutshell_id(user, nutshell_id)
    User.where(id: user.id).update_all(nutshell_id: nutshell_id,
                                       updated_at: Time.current)
    user.nutshell_id = nutshell_id
  end
end

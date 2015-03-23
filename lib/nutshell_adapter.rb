class NutshellAdapter
  include NutshellParamsBuilder
  attr_reader :client

  def initialize
    @client = NutshellClient.new if NutshellClient.enabled?
  end

  def push_user(user)
    user.nutshell_id? ? edit_contact(user) : new_contact(user)
  end

  def edit_contact(user, contact = nil)
    on_client_present do
      contact ||= get_contact user.nutshell_id
      client.post __method__, edit_contact_params(user, contact) if contact
    end
  end

  def new_contact(user)
    contact = get_contact_by_email user.email
    if contact
      update_user_with_nutshell_id(user, contact.id)
      return edit_contact(user, contact)
    end

    when_post_response_has_result_id __method__, contact_params(user) do |result|
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

        if candidate.email.present? && candidate.email.values.include?(email)
          contact = candidate
        end
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
    when_post_response_has_result_id __method__, edit_lead_params(site) do |result|
      if result.custom_fields && (status_name = result.custom_fields.status)
        status = Status.where(name: status_name.downcase.squish).first_or_create
        if status && status.id
          site.update_attributes(status_id: status.id)
        end
      end
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
  end
end

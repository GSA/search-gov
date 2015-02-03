class NutshellAdapter
  include NutshellParamsBuilder
  attr_reader :client

  def initialize
    @client = NutshellClient.new if NutshellClient.enabled?
  end

  def push_user(user)
    user.nutshell_id? ? edit_contact(user) : new_contact(user)
  end

  def new_contact(user)
    on_successful_post __method__, new_contact_params(user) do |result|
      User.where(id: user.id).update_all(nutshell_id: result.id,
                                         updated_at: Time.current)
    end
  end

  def edit_contact(user)
    on_client_present { client.post __method__, edit_contact_params(user) }
  end

  def push_site(site)
    site.nutshell_id? ? edit_lead(site) : new_lead(site)
  end

  def new_lead(site)
    on_successful_post __method__, new_lead_params(site) do |result|
      site.update_attributes(nutshell_id: result.id)
    end
  end

  def edit_lead(site)
    on_successful_post __method__, edit_lead_params(site) do |result|
      if result.custom_fields && (status_name = result.custom_fields.status)
        status = Status.where(name: status_name.downcase.squish).first_or_create
        if status && status.id
          site.update_attributes(status_id: status.id)
        end
      end
    end
  end

  private

  def on_successful_post(method, params, &block)
    on_client_present do
      is_success, rash = client.post method, params
      if is_success && rash && rash.result && rash.result.id
        yield rash.result
      end
      [is_success, rash]
    end
  end

  def on_client_present(&block)
    yield if client
  end
end

require 'mandrill'

class MandrillAdapter
  class NoClient < StandardError; end
  class UnknownTemplate < StandardError; end

  attr_reader :config

  ENVIRONMENT_CONFIG = Rails.application.config_for(:mandrill) rescue {}

  def initialize(config=nil)
    @config = config || ENVIRONMENT_CONFIG
  end

  def smtp_settings
    if config[:api_username] && config[:api_key]
      {
        address: 'smtp.mandrillapp.com',
        port: 587,
        enable_starttls_auto: true,
        user_name: config[:api_username],
        password: config[:api_key],
        authentication: 'login',
      }
    end
  end

  def bcc_setting
    config[:bcc_email]
  end

  def base_url_params
    config[:base_url_params] || { protocol: 'https', host: 'search.usa.gov' }
  end

  def client
    if !config[:api_key].blank?
      Mandrill::API.new(config[:api_key])
    end
  end

  def send_user_email(user, template_name, merge_vars={})
    on_client_present do
      recipient = MandrillRecipient.new(user, config, merge_vars)
      send_email(template_name, recipient.to_user, recipient.user_merge_vars_array)
    end
  end

  def send_admin_email(user, template_name, merge_vars={})
    return unless config[:admin_email]

    on_client_present do
      recipient = MandrillRecipient.new(user, config, merge_vars)
      send_email(template_name, recipient.to_admin, recipient.admin_merge_vars_array)
    end
  end

  def template_names
    raise NoClient unless client

    templates.map { |t| t['name'] }
  end

  def force_to
    @config[:force_to]
  end

  def preview_info(user, template_name)
    raise NoClient unless client

    template = templates.detect { |t| t['name'] == template_name }
    raise UnknownTemplate unless template

    merge_tag_names = read_merge_tag_names(template)
    recipient = MandrillRecipient.new(user, config)

    to_admin = template['labels'].include?('admin')

    {
      to: to_admin ? recipient.to_admin.first[:email] : "#{recipient.to_user.first[:name]} <#{recipient.to_user.first[:email]}>",
      subject: template['subject'],
      to_admin: to_admin,
      merge_tags: {
        available: recipient.default_merge_vars.slice(*merge_tag_names),
        needed: merge_tag_names.select { |n| !recipient.default_merge_vars.include?(n) }.sort,
      },
    }
  end

  private

  def on_client_present
    yield if client
  end

  def send_email(template_name, to, merge_vars)
    begin
      message = default_message_options.merge({ to: to, merge_vars: merge_vars })
      client.messages.send_template(template_name, [], message)
    rescue Mandrill::UnknownTemplateError, Mandrill::InvalidKeyError => e
      Rails.logger.error "could not send mandrill email: #{e.message}"
    end
  end

  def default_message_options
    {
      from_email: config[:from_email],
      from_name: config[:from_name],
      inline_css: true,
      track_opens: false,
      global_merge_vars: [],
    }
  end

  def templates
    client.templates.list
  end

  def read_merge_tag_names(template)
    names = template['code'].scan(%r{\*\|(IF:|ELSE:)?(\w*?)\|\*}).map { |s| s[1] }
    names = names.sort.uniq.map { |s| s.downcase.to_sym }
    names - [:archive, :current_year, :subject, :unsub, :update_profile]
  end
end

class Watcher < ActiveRecord::Base
  extend HashColumnsAccessible
  include LogstashPrefix
  include WatcherDSL
  INTERVAL_REGEXP = /\A\d+[mhdw]\z/

  belongs_to :user
  belongs_to :affiliate

  validates_presence_of :name, :conditions, :type
  validates_uniqueness_of :name, case_sensitive: false
  validates_format_of :check_interval, with: INTERVAL_REGEXP
  validates_format_of :throttle_period, with: INTERVAL_REGEXP
  validates_length_of :query_blocklist, maximum: 150, allow_nil: true
  validates :time_window, format: INTERVAL_REGEXP, time_window: true

  serialize :conditions, Hash

  def body
    Jbuilder.encode do |json|
      trigger(json)
      input(json)
      condition(json)
      throttle(json)
      transform(json)
      actions(json)
      metadata(json)
    end
  end

  def metadata(json)
    json.metadata do
      metadata_hash.each_pair do |key, value|
        json.set! key, value
      end
    end
  end

  def trigger(json)
    json.trigger do
      json.schedule do
        json.interval self.check_interval
      end
    end
  end

  def throttle(json)
    json.throttle_period throttle_period
  end

  def input_search_request(json, options)
    json.input do
      json.search do
        json.request do
          options.each do |option, value|
            json.set! option, value
          end
        end
      end
    end
  end

  def condition(json)
    json.condition do
      json.script condition_script
    end
  end

  def transform(json)
    json.transform do
      json.script transform_script
    end
  end

  def actions(json)
    json.actions do
      json.analytics_alert do
        json.webhook do
          json.method :POST
          json.scheme :https
          json.host "mandrillapp.com"
          json.port 443
          json.path "/api/1.0/messages/send-template.json"
          json.headers do
            json.set! "Content-type", "application/json"
          end
          json.body mandrill_body
        end
      end
    end
  end

  def mandrill_template_name
    self.class.name.underscore.dasherize
  end

  def mandrill_body
    config = MandrillAdapter.new.config
    Jbuilder.encode do |json|
      json.key config[:api_key]
      json.template_name mandrill_template_name
      json.template_content []
      json.message do
        message_details(json, config)
        to_user(json)
        global_merge_vars(json)
      end
    end
  end

  def global_merge_vars(json)
    json.global_merge_vars do
      global_merge_hash.each_pair do |name, content|
        global_merge_var_entry(json, name, content)
      end
    end
  end

  def message_details(json, config)
    json.from_email config[:from_email]
    json.from_name config[:from_name]
    json.merge_language :handlebars
    json.track_opens false
    json.inline_css true
  end

  def to_user(json)
    json.to do
      json.child! do
        json.email user.email
        json.name user.contact_name
      end
    end
  end

  def global_merge_var_entry(json, name, content)
    json.child! do
      json.name name
      json.content content
    end
  end

  def global_merge_hash
    {
      alert_name: name,
      site_name: affiliate.name,
      site_homepage_url: affiliate.website,
      contact_name: user.contact_name,
      query_terms: ["{{ctx.payload._value}}"]
    }
  end

  def metadata_hash
    {
      affiliate: affiliate.name,
      affiliate_id: affiliate.id,
      user_email: user.email,
      user_id: user.id,
      user_contact_name: user.contact_name,
      watcher_type: self.class.name
    }
  end

end

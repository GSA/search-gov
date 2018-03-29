class Watcher < ActiveRecord::Base
  extend HashColumnsAccessible
  include ActionView::Helpers::NumberHelper
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
        json.email do
          json.to user.email
          json.from Emailer::DELIVER_FROM_EMAIL_ADDRESS
          json.bcc Emailer::ADMIN_EMAIL_ADDRESS
          json.subject email_template.subject
          json.body { json.html email_template.body }
        end
      end
    end
  end

  def email_template
    EmailTemplate.find_by_name(self.class.name.underscore)
  end

  def metadata_hash
    {
      affiliate: affiliate.name,
      affiliate_id: affiliate.id,
      affiliate_homepage_url: affiliate.website,
      alert_name: name,
      user_email: user.email,
      user_id: user.id,
      user_contact_name: user.contact_name,
      watcher_type: self.class.name
    }
  end

end

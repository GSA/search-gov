# frozen_string_literal: true

class Watcher < ApplicationRecord
  include ActionView::Helpers::NumberHelper
  include LogstashPrefix
  include WatcherDsl
  INTERVAL_REGEXP = /\A\d+[mhdw]\z/

  belongs_to :user
  belongs_to :affiliate

  validates :name, :conditions, :type, presence: true
  # Disabling the Rubocop check for a unique index to back up a uniquness validation.
  # This validation is as old as the class, but I'm not sure it is correct/needed.
  # It may make sense to enforce unique names per user/affiliate, but I doubt that
  # the name needs to be universally unique, unless it affects something on the Elasticsearch
  # side. Until that is determined, I'm leaving this as-is.
  # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates :name, uniqueness: { case_sensitive: false }
  # rubocop:enable Rails/UniqueValidationWithoutIndex
  validates :check_interval, format: { with: INTERVAL_REGEXP }
  validates :throttle_period, format: { with: INTERVAL_REGEXP }
  validates :query_blocklist, length: { maximum: 150, allow_nil: true }
  validates :time_window, format: INTERVAL_REGEXP, time_window: true

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

  private

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
        json.interval check_interval
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
      json.script do
        json.source condition_script
        json.lang 'painless'
      end
    end
  end

  def transform(json)
    json.transform do
      json.script do
        json.source transform_script
        json.lang 'painless'
      end
    end
  end

  def actions(json)
    json.actions do
      json.analytics_alert do
        json.email do
          json.to user.email
          json.from DELIVER_FROM_EMAIL_ADDRESS
          json.bcc ADMIN_EMAIL_ADDRESS
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
    { affiliate: affiliate.name,
      affiliate_id: affiliate.id,
      affiliate_homepage_url: affiliate.website,
      alert_name: name,
      user_email: user.email,
      user_id: user.id,
      user_first_name: user.first_name,
      user_last_name: user.last_name,
      watcher_type: self.class.name }
  end
end

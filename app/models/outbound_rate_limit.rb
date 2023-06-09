class OutboundRateLimit < ApplicationRecord
  VALID_INTERVALS = %w(day month)
  attr_readonly :name
  validates_presence_of :limit, :name, :interval
  validates_uniqueness_of :name, case_sensitive: false
  validates_inclusion_of :interval, in: VALID_INTERVALS

  def self.load_defaults
    create!(name: AzureEngine::NAMESPACE,
            interval: 'month',
            limit: 5000) unless find_by_name(AzureEngine::NAMESPACE)
    create!(name: AzureCompositeEngine::NAMESPACE,
            interval: 'month',
            limit: 1000) unless find_by_name(AzureCompositeEngine::NAMESPACE)
  end

  def current_interval
    case interval
    when 'day'
      Date.current.strftime('%Y-%m-%d')
    when 'month'
      Date.current.strftime('%Y-%m')
    else
      raise "Unknown interval #{interval}"
    end
  end

  def ttl
    case interval
    when 'day'
      8.days.to_i
    when 'month'
      13.months.to_i
    else
      raise "Unknown interval #{interval}"
    end
  end
end

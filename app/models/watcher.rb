class Watcher < ActiveRecord::Base
  include LogstashPrefix
  INTERVAL_REGEXP = /\A\d+[mhdw]\z/

  belongs_to :user
  belongs_to :affiliate

  validates_presence_of :name, :conditions, :type
  validates_uniqueness_of :name, case_sensitive: false
  validates_format_of :check_interval, with: INTERVAL_REGEXP
  validates_format_of :throttle_period, with: INTERVAL_REGEXP

  serialize :conditions, Hash

  def self.define_hash_columns_accessors(args)
    column_name_method = args[:column_name_method]
    fields = args[:fields]

    fields.each do |field|
      define_method field do
        self.send(column_name_method).send("[]", field)
      end

      define_method :"#{field}=" do |arg|
        self.send(column_name_method).send("[]=", field, arg)
      end
    end
  end

  def body
    Jbuilder.encode do |json|
      trigger(json)
      input(json)
      condition(json)
      transform(json)
      actions(json)
    end
  end

  def trigger(json)
    json.trigger do
      json.schedule do
        json.interval self.check_interval
      end
    end
  end

end

require 'active_support/concern'

module Hintable
  extend ActiveSupport::Concern

  included do
    class_eval do
      class_attribute :hints_name_prefix,
                      instance_writer: false
      initialize_class_attributes
    end
  end

  module ClassMethods
    def initialize_class_attributes
      self.hints_name_prefix = self.name.demodulize.sub(/Controller$/, '').underscore.singularize
    end
  end

  def load_hints
    hints = Hint.name_starts_with(hints_name_prefix).collect do |hint|
      [hint_name_key(hint.name), hint.value]
    end
    @hints = Hash[hints]
  end

  def hint_name_key(hint_name)
    hint_name
  end
end

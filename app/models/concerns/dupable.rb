# frozen_string_literal: true

module Dupable
  extend ActiveSupport::Concern

  module ClassMethods
    def do_not_dup_attributes
      @@do_not_dup_attributes ||= %w(affiliate_id).freeze
    end
  end

  def dup
    dup_instance = super
    self.class.do_not_dup_attributes.each do |do_not_dup_attribute|
      dup_instance.send :"#{do_not_dup_attribute}=", nil
    end
    dup_instance
  end
end

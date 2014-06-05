require 'active_support/concern'

module Sites::ProfilesController
  extend ActiveSupport::Concern

  included do
    class_eval do
      class_attribute :pluralized_profile_type,
                      :profile_type,
                      :profile_type_klass,
                      instance_writer: false
      initialize_class_attributes
    end
  end

  module ClassMethods
    def initialize_class_attributes
      self.pluralized_profile_type = :"#{self.name.demodulize.gsub(/controller/i, '').underscore}"
      self.profile_type = :"#{pluralized_profile_type.to_s.singularize}"
      self.profile_type_klass = profile_type.to_s.camelize.constantize
    end
  end
end

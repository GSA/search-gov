# frozen_string_literal: true

require 'active_support/concern'

module DefaultModuleTaggable
  extend ActiveSupport::Concern

  included do
    class_eval do
      class_attribute :default_module_tag, instance_writer: false
      class_attribute :default_spelling_module_tag, instance_writer: false
    end
  end
end

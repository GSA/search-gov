require 'active_support/concern'

module FastDeleteFromDbAndEs
  extend ActiveSupport::Concern

  module ClassMethods
    def fast_delete(ids)
      return if ids.blank?

      "Elastic#{name}".constantize.delete(ids)
      delete_all(id: ids)
    end
  end
end

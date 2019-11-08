require 'active_support/concern'

module FastDeleteFromDbAndEs
  extend ActiveSupport::Concern

  module ClassMethods
    def fast_delete(ids)
      return if ids.blank?

      "Elastic#{name}".constantize.delete(ids)
      where(id: ids).delete_all
    end
  end
end

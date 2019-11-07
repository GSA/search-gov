require 'active_support/concern'

module FastDeleteFromDbAndEs
  extend ActiveSupport::Concern

  module ClassMethods
    def fast_delete(ids)
      return if ids.blank?

      "Elastic#{name}".constantize.delete(ids)
      # puts self
      # puts ids
      # puts(self.find(ids))
      # where(:id => ids).delete_all
      where(:id => ids).delete_all unless (where(:id => ids) == nil)
    end
  end
end

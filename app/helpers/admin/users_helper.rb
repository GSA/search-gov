module Admin::UsersHelper
  def options_for_association_conditions(association)
    if association.name == :default_affiliate
      ['affiliates.id IN (?)', @record.affiliate_ids]
    else
      super
    end
  end
end

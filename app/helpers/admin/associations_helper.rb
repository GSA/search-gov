module Admin::AssociationsHelper
  def options_for_association_conditions(association, record)
    if association.name == :default_affiliate
      ['affiliates.id IN (?)', @record.affiliate_ids]
    else
      super
    end
  end
end

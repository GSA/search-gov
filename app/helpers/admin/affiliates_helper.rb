module Admin::AffiliatesHelper
  def options_for_association_conditions(association)
    if association.name == :owner
      ['id in (select user_id from affiliates_users where affiliate_id = ?)', @record.id]
    else
      super
    end

  end
end

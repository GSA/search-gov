# frozen_string_literal: true

class TopNMissingQuery < TopNModulesQuery
  def additional_must_nots(json)
    json.child! { json.exists { json.field 'modules' } }
  end
end

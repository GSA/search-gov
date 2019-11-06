# frozen_string_literal: true

class TopNExistsQuery < TopNModulesQuery
  def additional_musts(json)
    json.child! { json.exists { json.field 'modules' } }
  end

  def additional_must_nots(json)
    json.child! { json.term { json.modules 'QRTD' } }
  end
end

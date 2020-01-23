class TopNExistsQuery < TopNModulesQuery

  def modules_must(json)
    json.child! { json.exists { json.field "modules" } }
  end

  def additional_must_nots(json)
    json.child! { json.term { json.modules "QRTD" } }
  end

end
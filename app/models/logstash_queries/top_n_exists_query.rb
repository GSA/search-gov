class TopNExistsQuery < TopNModulesQuery

  def modules_must(json)
    json.child! { json.exists { json.field "modules" } }
  end

end
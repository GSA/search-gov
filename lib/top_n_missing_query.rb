class TopNMissingQuery < TopNModulesQuery

  def modules_must(json)
    json.child! { json.missing { json.field "modules" } }
  end

end
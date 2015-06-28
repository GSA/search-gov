class TopNModulesQuery < TopNQuery

  def booleans(json)
    json.must do
      json.child! { json.term { json.affiliate @affiliate_name } }
      modules_must(json)
      additional_musts(json)
    end
    json.must_not do
      json.child! { json.term { json.set! "useragent.device", "Spider" } }
      json.child! { json.term { json.raw "" } }
    end
  end

  def additional_musts(json)
  end

end

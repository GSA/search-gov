class TopNMissingQuery < TopNQuery

  def booleans(json)
    json.must do
      json.child! { json.term { json.affiliate @affiliate_name } }
      json.child! { json.missing { json.field "modules" } }
    end
    json.must_not do
      json.child! { json.term { json.set! "useragent.device", "Spider" } }
      json.child! { json.term { json.raw "" } }
    end
  end

end
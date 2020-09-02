# frozen_string_literal: true

class TopNModulesQuery < TopNQuery
  def booleans(json)
    must_affiliate(json, affiliate_name)
    must_type(json, type)
    json.filter do
      modules_must(json)
      additional_musts(json)
    end
    json.must_not do
      json.child! { json.term { json.set! 'useragent.device', 'Spider' } }
      json.child! { json.term { json.set! 'params.query.raw', '' } }
      additional_must_nots(json)
    end
  end

  def additional_musts(json); end

  def additional_must_nots(json); end

  def modules_must(json); end
end

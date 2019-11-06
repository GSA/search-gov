# frozen_string_literal: true

class TopNModulesQuery < TopNQuery
  def booleans(json)
    json.must do
      json.child! { json.term { json.set! 'params.affiliate', @affiliate_name } }
      additional_musts(json)
    end
    json.must_not do
      json.child! { json.term { json.set! 'useragent.device', 'Spider' } }
      json.child! { json.term { json.raw '' } }
      additional_must_nots(json)
    end
  end

  def additional_musts(json); end

  def additional_must_nots(json); end
end

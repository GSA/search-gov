class CountQuery
  include AffiliateMinusSpiderFilter

  def initialize(affiliate_name)
    @affiliate_name = affiliate_name
  end

  def body
    Jbuilder.encode do |json|
      filter(json)
    end
  end

end

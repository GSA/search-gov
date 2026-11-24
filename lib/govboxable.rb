module Govboxable
  delegate :boosted_contents,
           :federal_register_documents,
           :med_topic,
           :jobs,
           :related_search,
           :to => :@govbox_set,
           :allow_nil => true

  def has_best_bets?
    has_boosted_contents?
  end

  def has_boosted_contents?
    boosted_contents and boosted_contents.total > 0 and boosted_contents.results.size > 0
  end

  def best_bets_count
    boosted_contents_count
  end

  def boosted_contents_count
    has_boosted_contents? ? boosted_contents.results.size : 0
  end

  def method_missing(meth, *args, &block)
    if meth.to_s =~ /^has_(.+)\?$/
      run_has_method($1)
    else
      super
    end
  end

  private
  def run_has_method(member_name)
    send(member_name).present? and send(member_name).total > 0
  end

end

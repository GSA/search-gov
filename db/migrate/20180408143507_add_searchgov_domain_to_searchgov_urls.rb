class AddSearchgovDomainToSearchgovUrls < ActiveRecord::Migration
  def change
    add_reference :searchgov_urls, :searchgov_domain, index: true, foreign_key: true
  end
end

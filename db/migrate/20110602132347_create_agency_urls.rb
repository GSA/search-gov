class CreateAgencyUrls < ActiveRecord::Migration
  def self.up
    create_table :agency_urls do |t|
      t.references :agency
      t.string :url
      t.string :locale
      t.timestamps
    end
    Agency.all.each do |agency|
      AgencyUrl.create(:agency => agency, :url => agency.url, :locale => 'en') if agency.url.present?
      AgencyUrl.create(:agency => agency, :url => agency.es_url, :locale => 'es') if agency.es_url.present?
    end
    remove_column :agencies, :url
    remove_column :agencies, :es_url
  end

  def self.down
    add_column :agencies, :url, :string
    add_column :agencies, :es_url, :string
    AgencyUrl.all.each do |agency_url|
      agency_url.locale == 'en' ? agency_url.agency.url = agency_url.url : agency_url.agency.es_url = agency_url.url
      agency_url.agency.save
    end
    drop_table :agency_urls
  end
end

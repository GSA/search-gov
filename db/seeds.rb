#agencies
agency = Agency.create :name => "Internal Revenue Service", :abbreviation => "IRS"

agency = Agency.create :name => "National Aeronautics and Space Administration", :abbreviation => "NASA"

agency = Agency.create :name => "House of Representatives", :abbreviation => nil

agency = Agency.create :name => "Senate", :abbreviation => nil

agency = Agency.create :name => "Department of Homeland Security", :abbreviation => "DHS"

agency = Agency.create :name => "White House", :abbreviation => nil

agency = Agency.create :name => "Environmental Protection Agency", :abbreviation => "EPA"

agency = Agency.create :name => "Department of State", :abbreviation => nil

agency = Agency.create :abbreviation => "SSA", :name => "Social Security Administration"

agency = Agency.create :name => "Department of Education", :abbreviation => nil

agency = Agency.create :name => "USAJOBS", :abbreviation => nil

agency = Agency.create :name => "USA.gov", :abbreviation => nil

Affiliate.create { |a| a.name = 'usagov'; a.display_name = 'USA.gov' }
Affiliate.create { |a| a.name = 'gobiernousa'; a.display_name = 'GobiernoUSA.gov'; a.locale = 'es' }
EmailTemplate.load_default_templates

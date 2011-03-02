class SeedAgencies < ActiveRecord::Migration
  def self.up
    Agency.create(:name => 'Internal Revenue Service', :domain => 'irs.gov', :url => 'http://www.irs.gov/', :phone => '800-829-1040', :abbreviation => 'IRS')
    Agency.create(:name => 'National Aeronautics and Space Administration', :domain => 'nasa.gov', :url => 'http://www.nasa.gov/', :phone => '202-358-0001', :abbreviation => 'NASA')
    Agency.create(:name => 'House of Representatives', :domain => 'house.gov', :url => 'http://www.house.gov/', :phone => '202-224-3121', :name_variants => 'House of Representative')
    Agency.create(:name => 'Senate', :domain => 'senate.gov', :url => 'http://senate.gov/', :phone => '202-224-3121')
    Agency.create(:name => 'Department of Homeland Security', :domain => 'dhs.gov', :url => 'http://www.dhs.gov/', :phone => '202-282-8000', :abbreviation => 'DHS', :name_variants => 'homeland security department, dept of homeland security, homeland security dept')
    Agency.create(:name => 'White House', :domain => 'whitehouse.gov', :url => 'http://www.whitehouse.gov/', :phone => '202-456-1111', :name_variants => 'whitehouse')
    Agency.create(:name => 'Environmental Protection Agency', :domain => 'epa.gov', :url => 'http://www.epa.gov/', :phone => '202-272-0167', :abbreviation => 'EPA')
    Agency.create(:name => 'Department of State', :domain => 'state.gov', :url => 'http://www.state.gov/', :phone => '202-647-4000', :name_variants => 'state department, dept of state, state dept')
    Agency.create(:name => 'Social Security Administration', :domain => 'ssa.gov', :url => 'http://www.ssa.gov/', :phone => '800-772-1213', :abbreviation => 'SSA')
    Agency.create(:name => 'Department of Education', :domain => 'ed.gov', :url => 'http://www.ed.gov/', :phone => '800-872-5327', :name_variants => 'education department, dept of education, education dept')
    Agency.create(:name => 'USAJOBS', :domain => 'usajobs.gov', :url => 'http://www.usajobs.opm.gov/', :name_variants => 'usajob, usa jobs, usa.gov.jobs, usajobs.opm.gov, usa.jobs.gov')
    Agency.create(:name => 'USA.gov', :domain => 'usa.gov', :url => 'http://www.usa.gov/', :phone => '800-333-4636', :name_variants => 'firstgov, firstgov.gov')
  end

  def self.down
    Agency.destroy_all
  end
end

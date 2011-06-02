#agencies
agency = Agency.create :toll_free_phone=>"800-829-1040", :name=>"Internal Revenue Service", :tty_phone=>"800-829-4059", :twitter_username=>"IRSnews", :name_variants=>nil, :domain=>"irs.gov", :flickr_url=>nil, :abbreviation=>"IRS", :facebook_username=>nil, :phone=>nil, :youtube_username=>"irsvideos"
AgencyUrl.create(:agency => agency, :url => 'http://www.irs.gov/', :locale => 'en')

agency = Agency.create :toll_free_phone=>nil, :name=>"National Aeronautics and Space Administration", :tty_phone=>nil, :twitter_username=>"NASA", :name_variants=>nil, :domain=>"nasa.gov", :flickr_url=>nil, :abbreviation=>"NASA", :facebook_username=>"NASA", :phone=>"202-358-0001", :youtube_username=>"NASAtelevision"
AgencyUrl.create(:agency => agency, :url => 'http://www.nasa.gov/', :locale => 'en')

agency = Agency.create :toll_free_phone=>nil, :name=>"House of Representatives", :tty_phone=>nil, :twitter_username=>nil, :name_variants=>"House of Representative", :domain=>"house.gov", :flickr_url=>nil, :abbreviation=>nil, :facebook_username=>nil, :phone=>"202-224-3121", :youtube_username=>nil
AgencyUrl.create(:agency => agency, :url=>"http://www.house.gov/", :locale => 'en')

agency = Agency.create :toll_free_phone=>nil, :name=>"Senate", :tty_phone=>nil, :twitter_username=>nil, :name_variants=>nil, :domain=>"senate.gov", :flickr_url=>nil, :abbreviation=>nil, :facebook_username=>nil, :phone=>"202-224-3121", :youtube_username=>nil
AgencyUrl.create(:agency => agency, :url=>"http://senate.gov/", :locale => 'en')

agency = Agency.create :toll_free_phone=>nil, :name=>"Department of Homeland Security", :tty_phone=>nil, :twitter_username=>"dhsjournal", :name_variants=>"homeland security department, dept of homeland security, homeland security dept", :domain=>"dhs.gov", :flickr_url=>nil, :abbreviation=>"DHS", :facebook_username=>"homelandsecurity", :phone=>"202-282-8000", :youtube_username=>"ushomelandsecurity"
AgencyUrl.create(:agency => agency, :url=>"http://www.dhs.gov/", :locale => 'en')

agency = Agency.create :toll_free_phone=>nil, :name=>"White House", :tty_phone=>nil, :twitter_username=>"whitehouse", :name_variants=>"whitehouse", :domain=>"whitehouse.gov", :flickr_url=>nil, :abbreviation=>nil, :facebook_username=>"WhiteHouse", :phone=>"202-456-1111", :youtube_username=>"whitehouse"
AgencyUrl.create(:agency => agency, :url=>"http://www.whitehouse.gov/", :locale => 'en')

agency = Agency.create :toll_free_phone=>nil, :name=>"Environmental Protection Agency", :tty_phone=>nil, :twitter_username=>"EPAgov", :name_variants=>nil, :domain=>"epa.gov", :flickr_url=>nil, :abbreviation=>"EPA", :facebook_username=>"EPA", :phone=>"202-272-0167", :youtube_username=>nil
AgencyUrl.create(:agency => agency, :url=>"http://www.epa.gov/", :locale => 'en')

agency = Agency.create :toll_free_phone=>nil, :name=>"Department of State", :tty_phone=>"888-874-7793", :twitter_username=>"StateDept", :name_variants=>"state department, dept of state, state dept", :domain=>"state.gov", :flickr_url=>nil, :abbreviation=>nil, :facebook_username=>"usdos", :phone=>"202-647-4000", :youtube_username=>"statevideo"
AgencyUrl.create(:agency => agency, :url=>"http://www.state.gov/", :locale => 'en')

agency = Agency.create :toll_free_phone=>"800-772-1213", :name=>"Social Security Administration", :tty_phone=>"800-325-0778", :twitter_username=>"SocialSecurity", :name_variants=>nil, :domain=>"ssa.gov", :flickr_url=>nil, :abbreviation=>"SSA", :facebook_username=>"socialsecurity", :phone=>nil, :youtube_username=>nil
AgencyUrl.create(:agency => agency, :url=>"http://www.ssa.gov/", :locale => 'en')
AgencyUrl.create(:agency => agency, :url=>"http://www.socialsecurity.gov/", :locale => 'en')

agency = Agency.create :toll_free_phone=>"800-872-5327", :name=>"Department of Education", :tty_phone=>"800-437-0833", :twitter_username=>"usedgov", :name_variants=>"education department, dept of education, education dept", :domain=>"ed.gov", :flickr_url=>nil, :abbreviation=>nil, :facebook_username=>"ED.gov", :phone=>nil, :youtube_username=>"usedgov"
AgencyUrl.create(:agency => agency, :url=>"http://www.ed.gov/", :locale => 'en')

agency = Agency.create :toll_free_phone=>nil, :name=>"USAJOBS", :tty_phone=>nil, :twitter_username=>"usajobs", :name_variants=>"usajob, usa jobs, usa.gov.jobs, usajobs.opm.gov, usa.jobs.gov", :domain=>"usajobs.gov", :flickr_url=>nil, :abbreviation=>nil, :facebook_username=>"USAJOBS", :phone=>nil, :youtube_username=>nil
AgencyUrl.create(:agency => agency, :url=>"http://www.usajobs.opm.gov/", :locale => 'en')

agency = Agency.create :toll_free_phone=>"800-333-4636", :name=>"USA.gov", :tty_phone=>nil, :twitter_username=>"USAgov", :name_variants=>"firstgov, firstgov.gov", :domain=>"usa.gov", :flickr_url=>"usagov", :abbreviation=>nil, :facebook_username=>"USAgov", :phone=>nil, :youtube_username=>"USGovernment"
AgencyUrl.create(:agency => agency, :url=>"http://www.usa.gov/", :locale => 'en')
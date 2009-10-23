require "#{File.dirname(__FILE__)}/../spec_helper"

describe Search do
  fixtures :affiliates

  before do
    @affiliate = affiliates(:basic_affiliate)
    @valid_options = {:query => 'government', :page => 3, :affiliate => @affiliate}
  end

  describe "when new" do
    it "should have a settable query" do
      search = Search.new(@valid_options)
      search.query.should == 'government'
    end

    it "should have a settable affiliate" do
      search = Search.new(@valid_options)
      search.affiliate.should == @affiliate
    end

    it "should not require a query or affiliate" do
      lambda { Search.new }.should_not raise_error(ArgumentError)
    end
  end

  context "when using different search indexes" do

    it "should default to Bing" do
      Search.new(@valid_options).engine.should be_instance_of Bing
    end

    it "should run the appropriate search engine" do
      Search::ENGINES.each do | sym, klass |
        engine = klass.new(@valid_options)
        klass.stub!(:new).and_return(engine)
        klass.should_receive(:new).once.with(@valid_options).and_return(engine)
        Search.new(@valid_options.merge(:engine => sym.to_s))
      end
    end

    Search::ENGINES.each do | sym, klass |

      context "when searching with valid queries on #{klass.name}" do
        before do
          @search = Search.new(@valid_options.merge(:engine => sym.to_s))
          @search.run
        end

        it "should find results based on query" do
          @search.results.size.should > 0
        end

        it "should have a total at least as large as the first set of results" do
          @search.total.should >= @search.results.size
        end

        it "should have a related searches array" do
          @search.related_search.size.should > 0
          @search.related_search.first.title.should_not be_nil
          @search.related_search.first.url.should_not be_nil
        end

      end

      context "when searching with really long queries" do
        before do
          @search = Search.new(@valid_options.merge(:engine => sym.to_s, :query => "X"*10000))
        end

        it "should return false when searching" do
          @search.run.should be_false
        end

        it "should have 0 results" do
          @search.run
          @search.results.size.should == 0
        end

        it "should set error message" do
          @search.run
          @search.error_message.should_not be_nil
        end
      end

      context "when searching with nonsense queries" do
        before do
          @search = Search.new(@valid_options.merge(:engine => sym.to_s, :query => 'kjdfgkljdhfgkldjshfglkjdsfhg'))
        end

        it "should return true when searching" do
          @search.run.should be_true
        end

        it "should have 0 results" do
          @search.run
          @search.results.size.should == 0
        end
      end

      context "when searching for misspelled terms" do
        before do
          @search = Search.new(@valid_options.merge(:engine => sym.to_s, :query => 'casa blanka'))
          response = mock("response")
          Net::HTTP.should_receive(:get_response).and_return(response)
          body = "{\"SearchResponse\":{\"Version\":\"2.2\",\"Query\":{\"SearchTerms\":\"casa blanka (site:gov OR site:mil)\"},\"Spell\":{\"Total\":1,\"Results\":[{\"Value\":\"some suggestion\"}]},\"Web\":{\"Total\":61600,\"Offset\":30,\"Results\":[{\"Title\":\"Search for Public Schools - School Detail for Casa Blanca Continuation\",\"Description\":\"Use the Search For Public Schools locator to retrieve information on all U.S. public schools. This data is collected annually directly from State Education Agencies (SEAs).\",\"Url\":\"http:\\/\\/nces.ed.gov\\/ccd\\/schoolsearch\\/school_detail.asp?Search=1&DistrictID=0614250&ID=061425001637\",\"CacheUrl\":\"http:\\/\\/cc.bingj.com\\/cache.aspx?q=casa+blanka&d=76870682423253&w=980bbc5f,6547e050\",\"DisplayUrl\":\"nces.ed.gov\\/ccd\\/schoolsearch\\/school_detail.asp?Search=1&DistrictID=0614250&ID=061425001637\",\"DateTime\":\"2009-09-15T12:42:35Z\"},{\"Title\":\"CASA BLANCA MAN SENTENCED TO 7 ½ YEARS IN PRISON FOR AGGRAVATED ...\",\"Description\":\"Office of the United States Attorney District of Arizona FOR IMMEDIATE RELEASE For Information Contact Public Affairs Tuesday, August 12, 2008 SANDRA RAYNOR Telephone: (602) 514 ...\",\"Url\":\"http:\\/\\/www.usdoj.gov\\/usao\\/az\\/press_releases\\/2008\\/2008-202(Manuel).pdf\",\"CacheUrl\":\"http:\\/\\/cc.bingj.com\\/cache.aspx?q=casa+blanka&d=76855472759544&w=16c8c66c,e8f04b3d\",\"DisplayUrl\":\"www.usdoj.gov\\/usao\\/az\\/press_releases\\/2008\\/2008-202(Manuel).pdf\",\"DateTime\":\"2009-05-04T19:17:43Z\"},{\"Title\":\"CASA BLANCA MAN SENTENCED TO OVER 6 YEARS IN PRISON FOR ROBBERY\",\"Description\":\"Office of the United States Attorney District of Arizona FOR IMMEDIATE RELEASE For Information Contact Public Affairs Tuesday, September 2, 2008 SANDY RAYNOR Telephone: (602) 514 ...\",\"Url\":\"http:\\/\\/www.usdoj.gov\\/usao\\/az\\/press_releases\\/2008\\/2008-222(Renteria).pdf\",\"CacheUrl\":\"http:\\/\\/cc.bingj.com\\/cache.aspx?q=casa+blanka&d=76851361556313&w=bf8d9398,ea796712\",\"DisplayUrl\":\"www.usdoj.gov\\/usao\\/az\\/press_releases\\/2008\\/2008-222(Renteria).pdf\",\"DateTime\":\"2009-06-23T18:32:44Z\"},{\"Title\":\"National Historic Landmarks Program (NHL)\",\"Description\":\"Casa Blanca, New Mexico: County of Cibola. 13 miles south of Casa Blanca on New Mexico 23; Acomita, New Mexico 87034; I-40 Exit 102: National Register Number: 66000500\",\"Url\":\"http:\\/\\/tps.cr.nps.gov\\/nhl\\/detail.cfm?ResourceId=357&ResourceType=District\",\"CacheUrl\":\"http:\\/\\/cc.bingj.com\\/cache.aspx?q=casa+blanka&d=76843204412300&w=e2f84fb4,47ab2d35\",\"DisplayUrl\":\"tps.cr.nps.gov\\/nhl\\/detail.cfm?ResourceId=357&ResourceType=District\",\"DateTime\":\"2009-10-14T17:58:56Z\"},{\"Title\":\"Citrus Label Collection \\/ Casa Blanca Brand (2).jpg\",\"Description\":\"Citrus Label Collection\\/Casa Blanca Brand (2).jpg Previous | Home | Next\",\"Url\":\"http:\\/\\/www.riversideca.gov\\/library\\/local-history\\/Citrus%20Labels\\/pages\\/Casa%20Blanca%20Brand%20(2)_jpg.htm\",\"CacheUrl\":\"http:\\/\\/cc.bingj.com\\/cache.aspx?q=casa+blanka&d=76870031245700&w=bc4e0691,85a0a08d\",\"DisplayUrl\":\"www.riversideca.gov\\/library\\/local-history\\/Citrus%20Labels\\/pages\\/Casa%20Blanca%20Brand%20...\",\"DateTime\":\"2009-05-15T06:40:13Z\"},{\"Title\":\"Política de Confidencialidad de la Casa Blanca\",\"Description\":\"Privacy Policy in Spanish. Política de Confidencialidad de la Casa Blanca. This is historical material, \\\"frozen in time.\\\" The web site is no longer updated and links to external ...\",\"Url\":\"http:\\/\\/georgewbush-whitehouse.archives.gov\\/privacy.es.html\",\"CacheUrl\":\"http:\\/\\/cc.bingj.com\\/cache.aspx?q=casa+blanka&d=76871941183290&w=3d250265,d9f390f4\",\"DisplayUrl\":\"georgewbush-whitehouse.archives.gov\\/privacy.es.html\",\"DateTime\":\"2009-10-22T08:16:47Z\"},{\"Title\":\"Tarahumara Frog Conservation Program\",\"Description\":\"All known populations of the Tarahumara frog have been extirpated from Arizona . The species was last seen in Gardner Canyon in 1977, Adobe Canyon in 1974, Big Casa Blanca Canyon ...\",\"Url\":\"http:\\/\\/www.fws.gov\\/southwest\\/es\\/arizona\\/T_Frog.htm\",\"CacheUrl\":\"http:\\/\\/cc.bingj.com\\/cache.aspx?q=casa+blanka&d=76836948477663&w=be38ce8d,423c5fb0\",\"DisplayUrl\":\"www.fws.gov\\/southwest\\/es\\/arizona\\/T_Frog.htm\",\"DateTime\":\"2009-10-13T02:43:52Z\"},{\"Title\":\"Acoma Pueblo 13 miles south of Casa Blanca on New Mexico Route 23\",\"Description\":\"Acoma Pueblo 13 miles south of Casa Blanca on New Mexico Route 23 Acoma Pueblo, built on top of a giant, craggy mesa, is one of the oldest continuously occupied settlements in the ...\",\"Url\":\"http:\\/\\/www.nr.nps.gov\\/writeups\\/66000500.nl.pdf\",\"CacheUrl\":\"http:\\/\\/cc.bingj.com\\/cache.aspx?q=casa+blanka&d=76845542693645&w=675f4078,b7cac70f\",\"DisplayUrl\":\"www.nr.nps.gov\\/writeups\\/66000500.nl.pdf\",\"DateTime\":\"2009-09-08T07:28:45Z\"},{\"Title\":\"Declaraciones del Presidente Bush y el Presidente Lugo de Paraguay ...\",\"Description\":\"PRESIDENTE BUSH: Bienvenido, señor Presidente, a la Casa Blanca. Es un honor para mí que esté aquí para visitarme en la Casa Blanca. Tuvimos una conversación muy importante ...\",\"Url\":\"http:\\/\\/georgewbush-whitehouse.archives.gov\\/news\\/releases\\/2008\\/10\\/20081027.es.html\",\"CacheUrl\":\"http:\\/\\/cc.bingj.com\\/cache.aspx?q=casa+blanka&d=76853246171133&w=b636d829,125239ab\",\"DisplayUrl\":\"georgewbush-whitehouse.archives.gov\\/news\\/releases\\/2008\\/10\\/20081027.es.html\",\"DateTime\":\"2009-10-17T11:00:12Z\"},{\"Title\":\"Tucson District - Casa Grande Maintenance\",\"Description\":\"I-10 from Casa Blanca Road to Red Rock TI. milepost 175.81 to 226.00; SR 84 from Junction of I-8 (Hidden Valley) to Casa Grande milepost 155.16 to 177.97\",\"Url\":\"http:\\/\\/www.azdot.gov\\/highways\\/districts\\/tucson\\/CasaGrande.asp\",\"CacheUrl\":\"http:\\/\\/cc.bingj.com\\/cache.aspx?q=casa+blanka&d=76835553693004&w=a97880b0,a147b77e\",\"DisplayUrl\":\"www.azdot.gov\\/highways\\/districts\\/tucson\\/CasaGrande.asp\",\"DateTime\":\"2009-10-01T21:06:09Z\"}]},\"RelatedSearch\":{\"Results\":[{\"Title\":\"Casablanca Movie\",\"Url\":\"http:\\/\\/www.bing.com\\/search?q=Casablanca+Movie\"},{\"Title\":\"Casablanca\",\"Url\":\"http:\\/\\/www.bing.com\\/search?q=Casablanca\"},{\"Title\":\"Casa Blanca Mesquite NV\",\"Url\":\"http:\\/\\/www.bing.com\\/search?q=Casa+Blanca+Mesquite+NV\"},{\"Title\":\"Casa Blanca Golf Resort\",\"Url\":\"http:\\/\\/www.bing.com\\/search?q=Casa+Blanca+Golf+Resort\"},{\"Title\":\"Casa Blanca Fans\",\"Url\":\"http:\\/\\/www.bing.com\\/search?q=Casa+Blanca+Fans\"}]}}}"
          response.should_receive(:body).and_return(body)
          @search.run
        end

        it "should have spelling suggestions" do
          @search.spelling_suggestion.should == "some suggestion"
        end
      end
    end
  end

  context "when paginating" do
    default_page = 0

    it "should default to page 0 if no valid page number was specified" do
      options_without_page = @valid_options.reject{|k, v| k == :page}
      Search.new(options_without_page).page.should == default_page
      Search.new(@valid_options.merge(:page => '')).page.should == default_page
      Search.new(@valid_options.merge(:page => 'string')).page.should == default_page
    end

    it "should set the page number" do
      search = Search.new(@valid_options.merge(:page => 2))
      search.page.should == 2
    end

    it "should use the underlying engine's results per page" do
      search = Search.new(@valid_options)
      search.run
      search.results.size.should == search.per_page
    end

    it "should set startrecord/endrecord" do
      page = 7
      search = Search.new(@valid_options.merge(:page => page))
      search.run
      search.startrecord.should == search.per_page * page + 1
      search.endrecord.should == search.startrecord + search.results.size - 1
    end
  end
end

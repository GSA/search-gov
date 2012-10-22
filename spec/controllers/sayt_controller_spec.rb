require 'spec_helper'

describe SaytController do
  fixtures :affiliates

  let(:affiliate) { affiliates(:usagov_affiliate) }
  let(:results) { mock('results', to_json: 'some json string') }
  let(:search) { mock(SaytSearch, results: results) }

  describe '#index' do
    context 'when sanitized query is empty' do
      it 'returns empty string' do
        get :index, :q => ' \\ '
        response.body.should == ''
      end
    end

    context 'when sanitized_query is not empty and params[:name] is valid' do
      it 'should do SaytSearch' do
        Affiliate.should_receive(:find_by_name_and_is_sayt_enabled).with(affiliate.name, true).and_return(affiliate)
        SaytSearch.should_receive(:new).
            with(hash_including(affiliate_id: affiliate.id,
                                query: 'lorem ipsum',
                                extras: false,
                                number_of_results: 10)).
            and_return(search)

        get :index, :q => 'lorem \\ ipsum', :name => affiliate.name, :callback => 'jsonp1234'
        response.body.should == %Q{jsonp1234(some json string)}
      end
    end

    context 'when sanitized_query, params[:name] and params[:extras] are present' do
      it 'should do SaytSearch' do
        Affiliate.should_receive(:find_by_name_and_is_sayt_enabled).with(affiliate.name, true).and_return(affiliate)

        SaytSearch.should_receive(:new).
            with(hash_including(:affiliate_id => affiliate.id,
                                :query => 'lorem ipsum',
                                :extras => true,
                                number_of_results: 10)).
            and_return(search)

        get :index, :q => 'lorem \\ ipsum', :name => affiliate.name, :callback => 'jsonp1234', :extras => 'true'
        response.body.should == %Q{jsonp1234(some json string)}
      end
    end

    context 'when sanitized_query is not empty and params[:name] is not valid' do
      it 'should return blank' do
        SaytSearch.should_not_receive(:new)

        get :index, :q => 'lorem \\ ipsum', :name => 'invalid'
        response.body.should == ''
      end
    end

    context 'when sanitized_query is not empty and params[:aid] is valid' do
      it 'should do SaytSearch' do
        Affiliate.should_receive(:exists?).with(id: affiliate.id.to_s, is_sayt_enabled: true).and_return(true)
        SaytSearch.should_receive(:new).
            with(hash_including(affiliate_id: affiliate.id,
                                query: 'lorem ipsum',
                                extras: false,
                                number_of_results: 10)).
            and_return(search)

        get :index, :q => 'lorem \\ ipsum', :aid => affiliate.id, :callback => 'jsonp1234'
        response.body.should == %Q{jsonp1234(some json string)}
      end
    end

    context 'when sanitized_query, params[:aid] and params[:extras] are present' do
      it 'should do SaytSearch' do
        Affiliate.should_receive(:exists?).with(id: affiliate.id.to_s, is_sayt_enabled: true).and_return(true)
        SaytSearch.should_receive(:new).
            with(hash_including(affiliate_id: affiliate.id,
                                query: 'lorem ipsum',
                                extras: true,
                                number_of_results: 10)).
            and_return(search)

        get :index, :q => 'lorem \\ ipsum', :aid => affiliate.id, :callback => 'jsonp1234', :extras => 'true'
        response.body.should == %Q{jsonp1234(some json string)}
      end
    end

    context 'when sanitized_query is not empty and params[:aid] is not valid' do
      it 'should return blank' do
        Affiliate.should_receive(:exists?).with(id: '0', is_sayt_enabled: true).and_return(false)
        SaytSearch.should_not_receive(:new)

        get :index, :q => 'lorem // ipsum', :aid => 0
        response.body.should == ''
      end
    end

    context 'when request is from mobile device' do
      before { controller.stub(:is_mobile_device?).and_return(true) }

      context 'when sanitized_query is not empty and params[:name] is valid' do
        it 'should do SaytSearch' do
          Affiliate.should_receive(:find_by_name_and_is_sayt_enabled).with(affiliate.name, true).and_return(affiliate)
          SaytSearch.should_receive(:new).
              with(hash_including(affiliate_id: affiliate.id,
                                  query: 'lorem ipsum',
                                  extras: false,
                                  number_of_results: 6)).
              and_return(search)

          get :index, :q => 'lorem \\ ipsum', :name => affiliate.name, :callback => 'jsonp1234'
          response.body.should == %Q{jsonp1234(some json string)}
        end
      end

      context 'when sanitized_query is not empty and params[:aid] is valid' do
        it 'should do SaytSearch' do
          Affiliate.should_receive(:exists?).with(id: affiliate.id.to_s, is_sayt_enabled: true).and_return(true)
          SaytSearch.should_receive(:new).
              with(hash_including(affiliate_id: affiliate.id,
                                  query: 'lorem ipsum',
                                  extras: false,
                                  number_of_results: 6)).
              and_return(search)

          get :index, :q => 'lorem \\ ipsum', :aid => affiliate.id, :callback => 'jsonp1234'
          response.body.should == %Q{jsonp1234(some json string)}
        end
      end
    end
  end
end


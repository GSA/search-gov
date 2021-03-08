# coding: utf-8
require 'spec_helper'

describe ApplicationHelper do
  before do
    allow(helper).to receive(:image_search?).and_return false
  end

  describe 'time_ago_in_words' do
    context 'English' do
      it "should include 'ago'" do
        expect(time_ago_in_words(4.hours.ago)).to eq('about 4 hours ago')
        expect(time_ago_in_words(33.days.ago)).to eq('about 1 month ago')
        expect(time_ago_in_words(2.days.ago)).to eq('2 days ago')
        expect(time_ago_in_words(1.day.ago)).to eq('1 day ago')
      end
    end

    context 'es' do
      before :each do
        I18n.locale = :es
      end
      after :each do
        I18n.locale = :en
      end
      it 'should use the Aproximadamente form' do
        expect(time_ago_in_words(4.hours.ago)).to eq('Hace 4 horas')
        expect(time_ago_in_words(33.days.ago)).to eq('Hace un mes')
        expect(time_ago_in_words(2.days.ago)).to eq('Hace 2 días')
        expect(time_ago_in_words(1.day.ago)).to eq('Ayer')
      end
    end
  end

  describe '#current_user_is? for specific role' do
    context 'when the current user is an affiliate_admin' do
      it 'should detect that' do
        user = double('User', :is_affiliate_admin? => true)
        allow(helper).to receive(:current_user).and_return(user)
        expect(helper.current_user_is?(:affiliate_admin)).to be true
      end
    end

    context 'when the current user is an affiliate' do
      it 'should detect that' do
        user = double('User', :is_affiliate? => true)
        allow(helper).to receive(:current_user).and_return(user)
        expect(helper.current_user_is?(:affiliate)).to be true
      end
    end

    context 'when the current user has no role' do
      it 'should detect that' do
        user = double('User', :is_affiliate_admin? => false, :is_affiliate? => false)
        allow(helper).to receive(:current_user).and_return(user)
        expect(helper.current_user_is?(:affiliate)).to be false
        expect(helper.current_user_is?(:affiliate_admin)).to be false
      end
    end

    context 'when there is no current user' do
      it 'should detect that' do
        allow(helper).to receive(:current_user).and_return(nil)
        expect(helper.current_user_is?(:affiliate)).to be_falsey
        expect(helper.current_user_is?(:affiliate_admin)).to be_falsey
      end
    end

  end

  describe '#basic_header_navigation_for' do
    it 'should contain My Account and Sign Out links' do
      user = double('User', :email => 'user@fixtures.org')
      content = helper.basic_header_navigation_for(user)
      expect(content).not_to have_selector('a', text: 'Sign In')
      expect(content).to have_content('user@fixtures.org')
      expect(content).to have_selector('a', text: 'My Account')
      expect(content).to have_selector('a', text: 'Sign Out')
    end
  end

end

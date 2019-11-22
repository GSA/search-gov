require 'spec_helper'

describe HumanSessionsController do
  fixtures :affiliates

  describe '#new' do
    render_views

    context 'when the referenced affiliate does not exist' do
      it 'redirects to the usa.gov search-error page' do
        get :new, params: { r: '/search?affiliate=imaginaryaffiliate&query=building' }
        expect(response).to redirect_to('https://www.usa.gov/search-error')
      end
    end

    context 'when the referenced affiliate does exist' do
      it 'records the "challenge" captcha activity' do
        expect(subject).to receive(:record_captcha_activity).with('challenge')
        get :new, params: { r: '/search?affiliate=usagov&query=building' }
      end

      it 'includes the "r" parameter in a "redirect_to" form input' do
        get :new, params: { r: '/search?affiliate=usagov&query=building' }
        expect(response.body).to have_selector(:css, 'input[name=redirect_to][value="%2Fsearch%3Faffiliate%3Dusagov%26query%3Dbuilding"]', visible: false)
      end

      it 'includes a noscript tag with a span for holding the "please enable javascript" message' do
        get :new, params: { r: '/search?affiliate=usagov&query=building' }
        expect(response.body).to have_selector('//noscript/span')
      end

      context 'when using an english-language affiliate' do
        it 'says "Search" in the captcha form submit button' do
          get :new, params: { r: '/search?affiliate=usagov&query=building' }
          expect(response.body).to have_selector('input[type=submit][value=Search]')
        end
      end

      context 'when using a spanish-lanugage affiliate' do
        after { I18n.locale = I18n.default_locale }
        it 'says "Buscar" in the captcha form submit button' do
          get :new, params: { r: '/search?affiliate=gobiernousa&query=building' }
          expect(response.body).to have_selector('input[type=submit][value=Buscar]')
        end
      end
    end
  end

  describe '#create' do
    before { allow(subject).to receive(:verify_recaptcha).and_return(challenge_outcome) }

    context 'when the result is actually a success' do
      let(:challenge_outcome) { true }

      before { allow(Digest::SHA256).to receive(:hexdigest).and_return('sha-na-na') }
      before { Timecop.freeze(Time.gm(1997, 8, 4, 5, 14)) }
      after { Timecop.return }

      it 'records the "success" captcha activity' do
        expect(subject).to receive(:record_captcha_activity).with('success')
        post :create, params: { redirect_to: '%2Flol%2Fwut' }
      end

      it 'does not record a "failure" captcha activity' do
        expect(subject).not_to receive(:record_captcha_activity).with('failure')
        post :create, params: { redirect_to: '%2Flol%2Fwut' }
      end

      it 'sets the "bon" cookie to a combination of client_ip, timestamp, and digest' do
        post :create, params: { redirect_to: '%2Flol%2Fwut' } 
        expect(response.cookies['bon']).to eq('0.0.0.0:870671640:sha-na-na')
      end

      context 'when the redirect_to parameter starts with a URL-encoded slash' do
        it 'should redirect to the redirect_to parameter' do
          post :create, params: { redirect_to: '%2Flol%2Fwut' }
          expect(response).to redirect_to('/lol/wut')
        end
      end

      context 'when the redirect_to parameter does not start with a URL-encoded slash' do
        it 'should redirect to the usa.gov search-error URL' do
          post :create, params: { redirect_to: 'http:%2F%2Flol%2Fwut' }
          expect(response).to redirect_to(ApplicationController::PAGE_NOT_FOUND)
        end
      end
    end

    context 'when the result is a failure' do
      let(:challenge_outcome) { false }

      it 'recods the "failure" captcha activity' do
        expect(subject).to receive(:record_captcha_activity).with('failure')
        post :create, params: { redirect_to: '%2Flol%2Fwut' }
      end

      it 'does not record a "success" captcha activity' do
        expect(subject).not_to receive(:record_captcha_activity).with('success')
        post :create, params: { redirect_to: '%2Flol%2Fwut' }
      end

      it 'does not set a "bon" cookie' do
        post :create, params: { redirect_to: '%2Flol%2Fwut' }
        expect(response.cookies[:bon]).to be_nil
      end

      context 'when the redirect_to parameter starts with a URL-encoded slash' do
        it 'should redirect to the redirect_to parameter' do
          post :create, params: { redirect_to: '%2Flol%2Fwut' }
          expect(response).to redirect_to('/lol/wut')
        end
      end

      context 'when the redirect_to parameter does not start with a URL-encoded slash' do
        it 'should redirect to the usa.gov search-error URL' do
          post :create, params: { redirect_to: 'http:%2F%2Flol%2Fwut' }
          expect(response).to redirect_to(ApplicationController::PAGE_NOT_FOUND)
        end
      end
    end
  end
end

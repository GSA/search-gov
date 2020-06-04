require 'spec_helper'

describe ClickSerp do
  context "with required params" do
    let(:url) { "http://www.fda.gov/foo.html" }
    let(:click) do
      ClickSerp.new url: url,
                query: "my query",
                client_ip: "12.34.56.789",
                affiliate: "nps.gov",
                position: "7",
                module_code: "RECALL",
                vertical: "web",
                user_agent: "mozilla"
    end
    before { allow(Rails.logger).to receive(:info) }

    describe "#valid?" do
      it "should be valid" do
        expect(click.valid?).to be_truthy
      end
    end

    describe "#log" do
      it "should log almost-JSON info about the click" do
        click.log

        expect(Rails.logger).to have_received(:info) do |str|
          expect(str).to match(/^\[Click\] \{.*\}$/)
          expect(str).to include('"url":"http://www.fda.gov/foo.html"')
          expect(str).to include('"query":"my query"')
          expect(str).to include('"client_ip":"12.34.56.789"')
          expect(str).to include('"affiliate":"nps.gov"')
          expect(str).to include('"position":"7"')
          expect(str).to include('"module_code":"RECALL"')
          expect(str).to include('"vertical":"web"')
          expect(str).to include('"user_agent":"mozilla"')
        end
      end
    end

    describe "#cleaned_url" do
      let(:url) { 'https://search.gov/%28 %3A%7C%29' }

      it 'should return an unescaped url' do
        click.log

        expect(Rails.logger).to have_received(:info) do |str|
          expect(str).to include('"url":"https://search.gov/(+:|)"')
        end
      end

      context "with invalid utf-8 in the url" do
        # https://cm-jira.usa.gov/browse/SRCHAR-415
        let(:url) { 'https://example.com/wymiana+teflon%F3w' }

        it "drops the unescapable url" do
          expect(click.url).to be nil
        end
      end
    end
  end

  context "without required params" do
    let(:click) do
      ClickSerp.new url: nil,
                query: nil,
                client_ip: nil,
                affiliate: nil,
                position: nil,
                module_code: nil,
                vertical: nil,
                user_agent: nil
    end

    describe "#valid?" do
      it "should not be valid" do
        expect(click.valid?).to be_falsey
      end
    end

    describe "#errors" do
      it "has expected errors" do
        click.valid?

        expected_errors = ["Url can't be blank",
                           "Query can't be blank",
                           "Position can't be blank",
                           "Module code can't be blank",
                           "Client ip can't be blank",
                           "User agent can't be blank"]
        expect(click.errors.full_messages).to eq expected_errors
      end
    end
  end
end

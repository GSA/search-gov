require 'spec_helper'

describe Click do
  context "with required params" do
    let(:click) do
      Click.new url: "http://www.fda.gov/foo.html",
                query: "my query",
                client_ip: "12.34.56.789",
                affiliate: "nps.gov",
                position: "7",
                module_code: "RECALL",
                vertical: "web",
                user_agent: "mozilla",
                access_key: "basic_key"
    end

    describe "#valid?" do
      it "should be valid" do
        expect(click.valid?).to be_truthy
      end
    end

    describe "#log" do
      it "should log almost-JSON info about the click" do
        allow(Rails.logger).to receive(:info)

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
          expect(str).to include('"access_key":"basic_key"')
        end
      end
    end
  end

  context "without required params" do
    let(:click) do
      Click.new url: nil,
                query: nil,
                client_ip: nil,
                affiliate: nil,
                position: nil,
                module_code: nil,
                vertical: nil,
                user_agent: nil,
                access_key: nil
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
                           "Module code can't be blank"]
        expect(click.errors.full_messages).to eq expected_errors
      end
    end
  end
end

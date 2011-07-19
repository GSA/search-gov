require 'spec/spec_helper'
describe SearchApiLogFile do
  fixtures :affiliates, :users

  describe "#parse_and_emit_line(log_entry)" do
    context "when log entry is well-formed" do
      before do
        @log_entry = <<'EOF'
165.83.132.248 - - [18/Jul/2011:00:01:09 +0000] "GET /api/search?affiliate=noaa.gov&api_key=affiliate_manager_key&format=json&page=1&hl=true&query=camping%20reservations%20mammoth%20cave&sitelimit=nps%2Egov%2Fdeto HTTP/1.1" 200 105 "-" "ColdFusion"
EOF
      end

      it "should emit a tab-delimited record with all the fields [ipaddr, time_of_day (in GMT), path, query term, normalized query term, affiliate, locale]" do
        SearchApiLogFile.should_receive(:puts).with("165.83.132.248\t00:01:09\t/api/search?affiliate=noaa.gov&api_key=affiliate_manager_key&format=json&page=1&hl=true&query=camping%20reservations%20mammoth%20cave&sitelimit=nps%2Egov%2Fdeto\tcamping reservations mammoth cave\tcamping reservations mammoth cave\tnoaa.gov\ten")
        SearchApiLogFile.parse_and_emit_line(@log_entry)
      end
    end

    context "when affiliate param is not present" do
      before do
        @log_entry = <<'EOF'
165.83.132.248 - - [18/Jul/2011:00:01:09 +0000] "GET /api/search?api_key=affiliate_manager_key&format=json&page=1&hl=true&query=camping%20reservations%20mammoth%20cave&sitelimit=nps%2Egov%2Fdeto HTTP/1.1" 200 105 "-" "ColdFusion"
EOF
      end

      it "should not emit a record" do
        SearchApiLogFile.should_not_receive(:puts)
        SearchApiLogFile.parse_and_emit_line(@log_entry)
      end
    end

    context "when the affiliate does not exist" do
      before do
        @log_entry = <<'EOF'
165.83.132.248 - - [18/Jul/2011:00:01:09 +0000] "GET /api/search?affiliate=unknown.gov&api_key=affiliate_manager_key&format=json&page=1&hl=true&query=camping%20reservations%20mammoth%20cave&sitelimit=nps%2Egov%2Fdeto HTTP/1.1" 200 105 "-" "ColdFusion"
EOF
      end

      it "should ignore the record" do
        SearchApiLogFile.should_not_receive(:puts)
        SearchApiLogFile.parse_and_emit_line(@log_entry)
      end
    end

    context "when the API key does not match the affiliate" do
      before do
        @log_entry = <<'EOF'
165.83.132.248 - - [18/Jul/2011:00:01:09 +0000] "GET /api/search?affiliate=noaa.gov&api_key=oops&format=json&page=1&hl=true&query=camping%20reservations%20mammoth%20cave&sitelimit=nps%2Egov%2Fdeto HTTP/1.1" 200 105 "-" "ColdFusion"
EOF
      end

      it "should ignore the record" do
        SearchApiLogFile.should_not_receive(:puts)
        SearchApiLogFile.parse_and_emit_line(@log_entry)
      end
    end

    context "when query param is not present" do
      before do
        @log_entry = <<'EOF'
165.83.132.248 - - [18/Jul/2011:00:01:09 +0000] "GET /api/search?affiliate=noaa.gov&api_key=affiliate_manager_key&format=json&page=1&hl=true HTTP/1.1" 200 105 "-" "ColdFusion"
EOF
      end

      it "should ignore the record" do
        SearchApiLogFile.should_not_receive(:puts)
        SearchApiLogFile.parse_and_emit_line(@log_entry)
      end
    end

  end
end

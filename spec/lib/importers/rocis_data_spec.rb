require 'spec_helper'

describe RocisData do
  let(:rocis_data_path) { "#{Rails.root}/spec/fixtures/csv/forms/rocis_data.csv" }
  let(:rocis_hash) { RocisData.new(rocis_data_path).to_hash }

  it 'should normalize GSA for number' do
    rocis_hash['GSA/GSA'][:forms]['GSA527'].should be_present
    rocis_hash['GSA/GSA'][:forms]['GSA1142'].should be_present
  end
end

require 'spec_helper'

describe RocisData do
  let(:rocis_data_path) { "#{Rails.root}/spec/fixtures/csv/forms/rocis_data.csv" }
  let(:rocis_hash) { RocisData.new(rocis_data_path).to_hash }

  it 'should normalize DOD form number' do
    rocis_hash['DOD/DODDEP'][:forms]['DD-149'].should be_present
    rocis_hash['DOD/DODDEP'][:forms]['DD-293'].should be_present
    rocis_hash['DOD/DODDEP'][:forms]['DD-1718'].should be_present
  end

  it 'should normalize GSA form number' do
    rocis_hash['GSA/GSA'][:forms]['GSA527'].should be_present
    rocis_hash['GSA/GSA'][:forms]['GSA1142'].should be_present
  end
end

require 'spec_helper'

describe Domain do
  describe 'schema' do
    it { should have_db_column(:domain).of_type(:string).with_options(null: false) }
    it { should have_db_column(:retain_query_strings).of_type(:boolean).with_options(default: false, null: false) }
  end
end

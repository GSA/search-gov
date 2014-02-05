require 'spec_helper'

describe Synonym do
  fixtures :affiliates
  let(:affiliate) { affiliates(:basic_affiliate) }

  describe ".format_entry(entry)" do
    it 'should normalize comma-separated entry' do
      Synonym.format_entry('d,a   B , c ').should == 'a b, c, d'
    end

    it 'should normalize array entry' do
      Synonym.format_entry(%w(foo bar blat foo)).should == 'bar, blat, foo'
    end
  end

  describe ".create_entry_for(entry, locale)" do
    before do
      Synonym.create_entry_for(['internal revenue service', 'irs'], affiliate)
    end

    it 'should attempt to create a Synonym entry for a list of synonyms and a locale' do
      Synonym.last.entry.should == 'internal revenue service, irs'
      Synonym.last.locale.should == 'en'
    end

    it 'should only log the first affiliate associated with the synonym/locale' do
      Synonym.create_entry_for(['internal revenue service', 'irs'], affiliates(:power_affiliate))
      Synonym.last.affiliate.id.should == affiliate.id
    end

    context 'when a race condition causes a duplicate record insert to be attempted' do
      before do
        Synonym.stub(:find_or_create_by_locale_and_entry).and_raise(ActiveRecord::RecordNotUnique.new("Dupe", Exception))
      end

      it 'should rescue the exception and just log the warning' do
        Rails.logger.should_receive(:warn).with("Already created record for 'internal revenue service, irs' and 'en'")
        Synonym.create_entry_for(['internal revenue service', 'irs'], affiliate)
      end
    end
  end

  describe ".label" do
    it 'should return a human-readable label like "Synonym 72"' do
      syn = Synonym.create!(entry: 'bar, foo', locale: 'en', affiliate: affiliate)
      syn.label.should == "Synonym #{syn.id}"
    end
  end

  describe "#group_overlapping_synonyms(locale)" do
    before do
      gobierno = affiliates(:gobiernousa_affiliate)
      Synonym.delete_all
      Synonym.create_entry_for('adopt, adopted, adopting', affiliate)
      Synonym.create_entry_for('adopt, adoptive', affiliate)
      Synonym.create_entry_for('renovation, renovator', affiliate)
      Synonym.create_entry_for('adopted, adoption', affiliate)
      Synonym.create_entry_for('retire, retired, retirement, retiring', affiliate)
      Synonym.create_entry_for('adopt, adoptito', gobierno)
    end

    it 'should group overlapping synonyms for a specific locale' do
      Synonym.group_overlapping_synonyms('en')
      Synonym.count.should == 4
      Synonym.find_by_entry('adopt, adopted, adopting, adoption, adoptive').should be_present
    end
  end
end

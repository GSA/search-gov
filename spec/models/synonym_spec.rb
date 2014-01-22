require 'spec_helper'

describe Synonym do
  it 'should normalize entry before saving' do
    syn = Synonym.create!(entry: 'd,a   b , c ', locale: 'en')
    syn.entry.should == 'a b, c, d'
  end

  describe ".create_entry_for(entry, locale)" do
    before do
      Synonym.create_entry_for('internal revenue service, irs', 'en')
    end

    it 'should attempt to create a Synonym entry for a list of synonyms and a locale' do
      Synonym.last.entry.should == 'internal revenue service, irs'
      Synonym.last.locale.should == 'en'
    end

    context 'when a race condition causes a duplicate record insert to be attempted' do
      before do
        Synonym.stub(:find_or_create_by_locale_and_entry).and_raise(ActiveRecord::RecordNotUnique.new("Dupe", Exception))
      end

      it 'should rescue the exception and just log the warning' do
        Rails.logger.should_receive(:warn).with("Already created record for 'internal revenue service, irs' and 'en'")
        Synonym.create_entry_for('internal revenue service, irs', 'en')
      end
    end
  end

  describe ".label" do
    it 'should return a human-readable label like "Synonym 72"' do
      syn = Synonym.create!(entry: 'd,a   b , c ', locale: 'en')
      syn.label.should == "Synonym #{syn.id}"
    end
  end
end

require 'spec_helper'

describe AffiliateNote do
  fixtures :affiliates

  it { should belong_to :affiliate }

  describe '#save' do
    it 'should strip note' do
      note = AffiliateNote.create!(affiliate: affiliates(:basic_affiliate), note: '   a note  ')
      note.note.should == 'a note'
    end
  end

  describe '#to_label' do
    it 'should truncate note' do
      text = <<-TEXT
If a man is called to be a street sweeper,
he should sweep streets even as Michelangelo painted,
or Beethoven composed music, or Shakespeare wrote poetry.
      TEXT
      note = AffiliateNote.new(note: text)
      note.to_label.should == "If a man is called to be a street sweeper,\nhe should sweep streets even as Michelangelo..."
    end
  end
end

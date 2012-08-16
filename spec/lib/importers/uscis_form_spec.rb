# coding: utf-8
require 'spec_helper'

describe UscisForm do
  describe '.import' do
    let(:forms_index_page) { File.open(Rails.root.to_s + '/spec/fixtures/html/forms/uscis/forms.html') }
    let(:forms_index_url) { 'http://www.uscis.gov/vgn-ext-templating/v/index.jsp?vgnextoid=db0' }
    let(:form1_landing_page) { File.read(Rails.root.to_s + '/spec/fixtures/html/forms/uscis/form1.html') }
    let(:form1) { mock(File, :read => form1_landing_page) }
    let(:form2_landing_page) { File.read(Rails.root.to_s + '/spec/fixtures/html/forms/uscis/form2.html') }
    let(:form2) { mock(File, :read => form2_landing_page) }
    let(:instruction1_landing_page) { File.read(Rails.root.to_s + '/spec/fixtures/html/forms/uscis/instruction1.html') }
    let(:instruction1) { mock(File, :read => instruction1_landing_page) }

    before do
      UscisForm.should_receive(:retrieve_forms_index_url).and_return(forms_index_url)
      UscisForm.should_receive(:open).with(forms_index_url).and_return(forms_index_page)
      UscisForm.should_receive(:open).
          with(%r[^http://www.uscis.gov/portal/site/uscis/menuitem.5af9bb95919f35e66f614176543f6d1a]).
          exactly(3).times.
          and_return(form1, instruction1, form2)
    end

    context 'when there is no existing Form' do
      before { UscisForm.import }

      it 'should create forms' do
        Form.count.should == 3
      end

      it 'should populate all the available fields' do
        form = Form.where(:agency => 'uscis.gov', :number => 'AR-11').first
        form.title.should == 'Change of Address'
        form.landing_page_url.should == 'http://www.uscis.gov/portal/site/uscis/menuitem.5af9bb95919f35e66f614176543f6d1a/?vgnextoid=c1a94154d7b3d010VgnVCM10000048f3d6a1RCRD&vgnextchannel=db029c7755cb9010VgnVCM10000045f3d6a1RCRD'
        form.file_size.should == '370KB'
        form.file_type.should == 'PDF'
      end

      it 'should handle latin characters' do
        Form.where(:number => 'I-129F').first.title.should == 'Petition for Alien Fiancé(e)'
      end
    end

    context 'when there is existing Form with the same agency and number' do
      let!(:existing_form) { Form.create!(:agency => 'uscis.gov',
                                          :number => 'AR-11',
                                          :url => 'http://www.uscis.gov/form.pdf',
                                          :file_type => 'PDF') }

      before { UscisForm.import }

      it 'should create/update forms' do
        Form.count.should == 3
      end

      it 'should update existing form' do
        form = Form.where(:agency => 'uscis.gov', :number => 'AR-11').first
        form.id.should == existing_form.id
      end
    end

    context 'when there is an obsolete Form from the same agency' do
      let!(:obsolete_form) { Form.create!(:agency => 'uscis.gov',
                                          :number => 'obsolete',
                                          :url => 'http://www.uscis.gov/form.pdf',
                                          :file_type => 'PDF') }

      before { UscisForm.import }

      it 'should create forms' do
        Form.count.should == 3
      end

      it 'should delete the obsolete form' do
        Form.find_by_id(obsolete_form.id).should be_nil
      end
    end
  end

  describe '.retrieve_forms_index_url' do
    let(:forms_index_page) { File.read(Rails.root.to_s + '/spec/fixtures/html/forms/uscis/forms.html') }
    let(:forms_index_url) { 'http://www.uscis.gov/vgn-ext-templating/v/index.jsp?vgnextoid=db0' }

    it 'should return form_index_url' do
      UscisForm.should_receive(:open).
          with('http://www.uscis.gov/portal/site/uscis').
          and_return(forms_index_page)
      UscisForm.retrieve_forms_index_url.should == forms_index_url
    end
  end
end

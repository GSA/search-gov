# frozen_string_literal: true

describe SitesHelper do
  describe '#initialize_filters_for_display' do
    let(:site) { mock_model(Affiliate, display_name: 'Active', name: 'active', filter_setting: filter_setting) }

    context 'when site has a filter_setting' do
      let(:filter_setting) { mock_model(FilterSetting, filters: [existing_filter]) }
      let(:existing_filter) { mock_model(Filter, label: 'Test Filter', type: 'CustomFilter', position: 0) }

      it 'returns the existing filters' do
        filters = helper.initialize_filters_for_display(site)
        expect(filters).to eq([existing_filter])
        expect(filters.first.label).to eq('Test Filter')
      end
    end

    context 'when site does not have a filter_setting' do
      let(:filter_setting) { nil }
      let(:mock_filter_setting) { instance_double(FilterSetting) }

      before do
        @default_filters = [
          mock_model(Filter, label: 'Topic', type: 'TopicFilter', position: 0, enabled: false),
          mock_model(Filter, label: 'FileType', type: 'FileTypeFilter', position: 1, enabled: false),
          mock_model(Filter, label: 'ContentType', type: 'ContentTypeFilter', position: 2, enabled: false),
          mock_model(Filter, label: 'Audience', type: 'AudienceFilter', position: 3, enabled: false),
          mock_model(Filter, label: 'Date', type: 'DateFilter', position: 4, enabled: false),
          mock_model(Filter, label: 'Custom1', type: 'CustomFilter', position: 5, enabled: false),
          mock_model(Filter, label: 'Custom2', type: 'CustomFilter', position: 6, enabled: false),
          mock_model(Filter, label: 'Custom3', type: 'CustomFilter', position: 7, enabled: false)
        ]

        allow(FilterSetting).to receive(:new).and_return(mock_filter_setting)
        allow(mock_filter_setting).to receive(:initialize_default_filters_preview).and_return(@default_filters)
      end

      it 'returns dynamically generated default filters' do
        filters = helper.initialize_filters_for_display(site)
        expect(filters.size).to eq(8)
        expect(filters.first.label).to eq('Topic')
        expect(filters.first.type).to eq('TopicFilter')
      end
    end
  end

  describe '#site_select' do
    let(:active_affiliate) { mock_model(Affiliate, display_name: 'Active', name: 'active') }
    let(:inactive_affiliate) { mock_model(Affiliate, display_name: 'Inactive', name: 'Inactive') }

    context 'when the user is a super admin' do
      let(:user) { mock_model(User, is_affiliate_admin: true) }

      before do
        allow(helper).to receive(:current_user).and_return(user)
        allow(user).to receive(:affiliates).
          and_return([active_affiliate, inactive_affiliate])
      end

      it 'returns a drop-down for all affiliates' do
        expect(helper.site_select).to match(/Active.+\n.+Inactive/)
      end
    end

    context 'when the user is not a super admin' do
      let(:user) { mock_model(User, is_affiliate_admin: false) }

      before do
        allow(helper).to receive(:current_user).and_return(user)
        allow(user).to receive_message_chain(:affiliates, :active).and_return([active_affiliate])
      end

      it 'returns a drop-down for active affiliates' do
        expect(helper.site_select).to match(/Active/)
        expect(helper.site_select).not_to match(/Inactive/)
      end
    end
  end

  describe '#user_row_css_class_hash' do
    let(:approval_status) { RSpec.current_example.metadata[:approval_status] }
    let(:user) { mock_model(User, approval_status: approval_status) }
    let(:subject) { helper.user_row_css_class_hash(user) }

    context 'when User has', approval_status: 'pending_approval' do
      specify { expect(subject).to eq(class: 'warning') }
    end

    context 'when User has', approval_status: 'not_approved' do
      specify { expect(subject).to eq(class: 'error') }
    end
  end
end
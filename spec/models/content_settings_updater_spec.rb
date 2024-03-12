# spec/models/content_settings_updater_spec.rb

describe ContentSettingsUpdater do
  context 'when updating content settings' do
    before do
      3.times do |i|
        affiliate = Affiliate.create!(name: "content_settings_affiliate_#{i}",
                                      display_name: "Content Settings Affiliate #{i}",
                                      mobile_logo_file_name: "logo_#{i}.png",
                                      mobile_logo_content_type: 'image/png')

        affiliate.update(managed_header_links_attributes: { '0' => { position: '0', title: 'Header', url: 'http://www.acpt.nsf.gov/statistics/2016/nsb20161/' } })
        affiliate.update(managed_footer_links_attributes: { '0' => { position: '0', title: 'Footer', url: 'http://www.acpt.nsf.gov/statistics/2016/nsb20161/#/report' } })
      end
      allow(Rails.logger).to receive(:info)
      allow(Rails.logger).to receive(:error)
    end

    let(:content_settings_updater) { described_class.new }
    let(:first_affiliate) { Affiliate.find_by(name: 'content_settings_affiliate_0') }
    let(:second_affiliate) { Affiliate.find_by(name: 'content_settings_affiliate_1') }
    let(:third_affiliate) { Affiliate.find_by(name: 'content_settings_affiliate_2') }
    let(:success_message) { '[content_settings_updater_task] The following affiliates were updated successfully:' }

    context 'when specific ids are passed to update' do
      let(:ids) { [first_affiliate.id, second_affiliate.id] }

      it 'updates the specified affiliates content settings' do
        expect { content_settings_updater.update(ids) }.
          to change { first_affiliate.reload.header_logo.attached? }.from(false).to(true).
          and change { second_affiliate.reload.header_logo.attached? }.from(false).to(true)
      end

      it 'updates header links for specified affiliates' do
        expect { content_settings_updater.update(ids) }.
          to change { first_affiliate.reload.primary_header_links.count }.from(0).to(1).
          and change { second_affiliate.reload.primary_header_links.count }.from(0).to(1)
      end

      it 'updates footer links for specified affiliates' do
        expect { content_settings_updater.update(ids) }.
          to change { first_affiliate.reload.footer_links.count }.from(0).to(1).
          and change { second_affiliate.reload.footer_links.count }.from(0).to(1)
      end

      it 'does not update header logo for other affiliates' do
        expect { content_settings_updater.update(ids) }.
          not_to change { third_affiliate.reload.header_logo.attached? }
      end

      it 'does not update primary header links for other affiliates' do
        expect { content_settings_updater.update(ids) }.
          not_to change { third_affiliate.reload.primary_header_links.count }
      end

      it 'does not update footer links for other affiliates' do
        expect { content_settings_updater.update(ids) }.
          not_to change { third_affiliate.reload.footer_links.count }
      end

      it 'logs successes' do
        content_settings_updater.update(ids)
        expect(Rails.logger).to have_received(:info).
          with("#{success_message} #{ids}.")
      end
    end

    context 'when all ids are passed to update' do
      let(:ids) { 'all' }

      it 'updates all affiliate content settings' do
        expect { content_settings_updater.update(ids) }.
          to change { third_affiliate.reload.header_logo_attachment }.
          and change { third_affiliate.reload.footer_links.count }
      end

      it 'logs successes' do
        content_settings_updater.update(ids)
        expect(Rails.logger).to have_received(:info).at_least(:once) do |message|
          message =~ /\[content_settings_updater_task\] The following affiliates were updated successfully: \[#{[first_affiliate.id, second_affiliate.id, third_affiliate.id].join(', ')}\]\./
        end
      end
    end

    context 'when something goes wrong' do
      before do
        allow(content_settings_updater).to receive(:update_affiliate_content_setings).and_raise(StandardError)
      end

      let(:ids) { [first_affiliate.id] }
      let(:failure_message) { '[content_settings_updater_task] The following affiliates failed to update:' }

      it 'logs failures' do
        content_settings_updater.update(ids)
        expect(Rails.logger).to have_received(:error).
          with("#{failure_message} [{:affiliate_id=>#{first_affiliate.id}, :reason=>\"#<StandardError: StandardError>\"}].")
      end
    end
  end
end

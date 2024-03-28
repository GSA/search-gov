# spec/models/header_and_footer_links_updater_spec.rb

describe HeaderAndFooterLinksUpdater do
  context 'when updating header and footer links' do
    before do
      3.times do |i|
        affiliate = Affiliate.create!(name: "header_and_footer_affiliate_#{i}",
                                      display_name: "Header and Footer Affiliate #{i}")

        affiliate.update(managed_header_links_attributes: { '0' => { position: '0', title: 'Header', url: 'http://www.acpt.nsf.gov/statistics/2016/nsb20161/' } })
        affiliate.update(managed_footer_links_attributes: { '0' => { position: '0', title: 'Footer', url: 'http://www.acpt.nsf.gov/statistics/2016/nsb20161/#/report' } })
      end
      allow(Rails.logger).to receive(:info)
      allow(Rails.logger).to receive(:error)
    end

    let(:header_and_footer_links_updater) { described_class.new }
    let(:first_affiliate) { Affiliate.find_by(name: 'header_and_footer_affiliate_0') }
    let(:second_affiliate) { Affiliate.find_by(name: 'header_and_footer_affiliate_1') }
    let(:third_affiliate) { Affiliate.find_by(name: 'header_and_footer_affiliate_2') }
    let(:success_message) { '[header_and_footer_links_updater_task] The following affiliates were updated successfully:' }

    context 'when specific ids are passed to update' do
      let(:ids) { [first_affiliate.id, second_affiliate.id] }

      it 'updates header links for specified affiliates' do
        expect { header_and_footer_links_updater.update(ids) }.
          to change { first_affiliate.reload.primary_header_links.count }.from(0).to(1).
          and change { second_affiliate.reload.primary_header_links.count }.from(0).to(1)
      end

      it 'updates footer links for specified affiliates' do
        expect { header_and_footer_links_updater.update(ids) }.
          to change { first_affiliate.reload.footer_links.count }.from(0).to(1).
          and change { second_affiliate.reload.footer_links.count }.from(0).to(1)
      end

      it 'does not update primary header links for other affiliates' do
        expect { header_and_footer_links_updater.update(ids) }.
          not_to change { third_affiliate.reload.primary_header_links.count }
      end

      it 'does not update footer links for other affiliates' do
        expect { header_and_footer_links_updater.update(ids) }.
          not_to change { third_affiliate.reload.footer_links.count }
      end

      it 'logs successes' do
        header_and_footer_links_updater.update(ids)
        expect(Rails.logger).to have_received(:info).
          with("#{success_message} #{ids}.")
      end
    end

    context 'when all ids are passed to update' do
      let(:ids) { 'all' }

      it 'updates all affiliate header and footer links' do
        expect { header_and_footer_links_updater.update(ids) }.
          to change { third_affiliate.reload.primary_header_links.count }.
          and change { third_affiliate.reload.footer_links.count }
      end

      it 'logs successes' do
        header_and_footer_links_updater.update(ids)
        expect(Rails.logger).to have_received(:info).at_least(:once) do |message|
          message =~ /\[header_and_footer_links_updater_task\] The following affiliates were updated successfully: \[#{[first_affiliate.id, second_affiliate.id, third_affiliate.id].join(', ')}\]\./
        end
      end
    end

    context 'when something goes wrong' do
      before do
        allow(header_and_footer_links_updater).to receive(:update_affiliate_header_and_footer_links).and_raise(StandardError)
      end

      let(:ids) { [first_affiliate.id] }
      let(:failure_message) { '[header_and_footer_links_updater_task] The following affiliates failed to update:' }

      it 'logs failures' do
        header_and_footer_links_updater.update(ids)
        expect(Rails.logger).to have_received(:error).
          with("#{failure_message} [{:affiliate_id=>#{first_affiliate.id}, :reason=>\"#<StandardError: StandardError>\"}].")
      end
    end
  end
end

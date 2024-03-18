# spec/models/image_content_updater_spec.rb

describe ImageContentUpdater do
  context 'when updating header and footer links' do
    before do
      3.times do |i|
        Affiliate.create!(name: "image_content_affiliate_#{i}",
                                      display_name: "Header and Footer Affiliate #{i}",
                                      mobile_logo_file_name: "logo_#{i}.png",
                                      mobile_logo_content_type: 'image/png')
      end
      allow(Rails.logger).to receive(:info)
      allow(Rails.logger).to receive(:error)
    end

    let(:image_content_updater) { described_class.new }
    let(:first_affiliate) { Affiliate.find_by(name: 'image_content_affiliate_0') }
    let(:second_affiliate) { Affiliate.find_by(name: 'image_content_affiliate_1') }
    let(:third_affiliate) { Affiliate.find_by(name: 'image_content_affiliate_2') }
    let(:success_message) { '[image_content_updater_task] The following affiliates were updated successfully:' }

    context 'when specific ids are passed to update' do
      let(:ids) { [first_affiliate.id, second_affiliate.id] }

      it 'updates the header logo for specified affiliates' do
        expect { image_content_updater.update(ids) }.
          to change { first_affiliate.reload.header_logo.attached? }.from(false).to(true).
          and change { second_affiliate.reload.header_logo.attached? }.from(false).to(true)
      end

      it 'does not update header logo for other affiliates' do
        expect { image_content_updater.update(ids) }.
          not_to change { third_affiliate.reload.header_logo.attached? }
      end

      it 'logs successes' do
        image_content_updater.update(ids)
        expect(Rails.logger).to have_received(:info).
          with("#{success_message} #{ids}.")
      end
    end

    context 'when all ids are passed to update' do
      let(:ids) { 'all' }

      it 'updates all affiliate header and footer links' do
        expect { image_content_updater.update(ids) }.
          to change { third_affiliate.reload.header_logo_attachment }
      end

      it 'logs successes' do
        image_content_updater.update(ids)
        expect(Rails.logger).to have_received(:info).at_least(:once) do |message|
          message =~ /\[image_content_updater_task\] The following affiliates were updated successfully: \[#{[first_affiliate.id, second_affiliate.id, third_affiliate.id].join(', ')}\]\./
        end
      end
    end

    context 'when something goes wrong' do
      before do
        allow(image_content_updater).to receive(:update_affiliate_image_content).and_raise(StandardError)
      end

      let(:ids) { [first_affiliate.id] }
      let(:failure_message) { '[image_content_updater_task] The following affiliates failed to update:' }

      it 'logs failures' do
        image_content_updater.update(ids)
        expect(Rails.logger).to have_received(:error).
          with("#{failure_message} [{:affiliate_id=>#{first_affiliate.id}, :reason=>\"#<StandardError: StandardError>\"}].")
      end
    end
  end
end

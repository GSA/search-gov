# frozen_string_literal: true

describe FontAndColorUpdater do
  context 'when custom colors are set for an existing affiliate' do
    before do
      3.times do |i|
        Affiliate.create!(name: "custom_color_affiliate_#{i}",
                          display_name: "Custom Color Affiliate #{i}",
                          visual_design_json: starting_visual_design)
      end
      allow(Rails.logger).to receive(:info)
      allow(Rails.logger).to receive(:error)
    end

    let(:font_and_color_updater) { described_class.new }
    let(:starting_visual_design) { { banner_background_color: '#123456' } }
    let(:first_affiliate) { Affiliate.find_by(name: 'custom_color_affiliate_0') }
    let(:second_affiliate) { Affiliate.find_by(name: 'custom_color_affiliate_1') }
    let(:third_affiliate) { Affiliate.find_by(name: 'custom_color_affiliate_2') }
    let(:success_message) { '[font_and_color_updater_task] The following affiliates were updated successfully:' }

    context 'when specific ids are passed to update' do
      let(:ids) { [first_affiliate.id, second_affiliate.id] }

      it 'updates those affiliates colors to defaults' do
        expect { font_and_color_updater.update(ids) }.
          to change { first_affiliate.reload.visual_design_json['banner_background_color'] }.
          from('#123456').to('#F0F0F0').
          and change { second_affiliate.reload.visual_design_json['banner_background_color'] }.
          from('#123456').to('#F0F0F0')
      end

      it 'does not update other affiliate colors' do
        expect { font_and_color_updater.update(ids) }.
          not_to change { third_affiliate.reload.visual_design_json['banner_background_color'] }
      end

      it 'logs successes' do
        font_and_color_updater.update(ids)
        expect(Rails.logger).to have_received(:info).
          with("#{success_message} #{ids}.")
      end
    end

    context 'when all ids are passed to update' do
      let(:ids) { 'all' }

      it 'updates all affiliate colors to defaults' do
        expect { font_and_color_updater.update(ids) }.
          to change { third_affiliate.reload.visual_design_json['banner_background_color'] }.
          from('#123456').to('#F0F0F0')
      end

      it 'logs successes' do
        font_and_color_updater.update(ids)
        expect(Rails.logger).to have_received(:info).
          with("#{success_message} [#{first_affiliate.id}, #{second_affiliate.id}, #{third_affiliate.id}].")
      end
    end

    context 'when something goes wrong' do
      before do
        allow(font_and_color_updater).to receive(:update_affiliate_font_and_color).and_raise(StandardError)
      end

      let(:ids) { [first_affiliate.id] }
      let(:failure_message) { '[font_and_color_updater_task] The following affiliates failed to update:' }

      it 'logs failures' do
        font_and_color_updater.update(ids)
        expect(Rails.logger).to have_received(:error).
          with("#{failure_message} [{:affiliate_id=>#{first_affiliate.id}, :reason=>\"#<StandardError: StandardError>\"}].")
      end
    end
  end
end

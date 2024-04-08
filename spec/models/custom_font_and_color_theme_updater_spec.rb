# frozen_string_literal: true

describe CustomFontAndColorThemeUpdater do
  context 'when custom colors are set for an existing affiliate' do
    before do
      2.times do |i|
        Affiliate.create!(name: "default_visual_design_#{i}",
                          display_name: "Default Visual Design #{i}",
                          visual_design_json: default_visual_design,
                          theme: 'custom',
                          css_property_hash: css_property_hash)
        Affiliate.create!(name: "modified_visual_design_#{i}",
                          display_name: "Modified Visual Design #{i}",
                          visual_design_json: modified_visual_design,
                          theme: 'custom',
                          css_property_hash: css_property_hash)
      end
      allow(Rails.logger).to receive(:info)
      allow(Rails.logger).to receive(:error)
    end

    let(:custom_font_and_color_theme_updater) { described_class.new }
    let(:default_visual_design) { { banner_background_color: '#F0F0F0' } }
    let(:modified_visual_design) { { banner_background_color: '#1B1B1B' } }
    let(:css_property_hash) { { font_family: 'Arial, sans-serif' } }
    let(:default_first_affiliate) { Affiliate.find_by(name: 'default_visual_design_0') }
    let(:default_second_affiliate) { Affiliate.find_by(name: 'default_visual_design_1') }
    let(:modified_first_affiliate) { Affiliate.find_by(name: 'modified_visual_design_0') }
    let(:modified_second_affiliate) { Affiliate.find_by(name: 'modified_visual_design_1') }
    let(:success_message) { '[custom_font_and_color_theme_updater_task] The following affiliates were updated successfully:' }

    context 'when specific ids are passed to update' do
      let(:ids) { [default_first_affiliate.id, modified_first_affiliate.id] }

      it 'updates those affiliates default visual design colors with legacy colors' do
        expect { custom_font_and_color_theme_updater.update(ids) }.
          to change { default_first_affiliate.reload.visual_design_json['banner_background_color'] }.
          from('#F0F0F0').to('#000000')
      end

      it 'does not update those affiliates with modified visual design colors with legacy colors' do
        expect { custom_font_and_color_theme_updater.update(ids) }.
          not_to change { modified_first_affiliate.reload.visual_design_json['banner_background_color'] }
      end

      it 'does not update other affiliate visual design colors with legacy colors' do
        expect { custom_font_and_color_theme_updater.update(ids) }.
          not_to change { default_second_affiliate.reload.visual_design_json['banner_background_color'] }
      end

      it 'logs successes' do
        custom_font_and_color_theme_updater.update(ids)
        expect(Rails.logger).to have_received(:info).
          with("#{success_message} [#{default_first_affiliate.id}].")
      end
    end

    context 'when all ids are passed to update' do
      before do
        allow(Affiliate).to receive_message_chain(:where, :find_each).
          and_yield(default_first_affiliate).and_yield(default_second_affiliate).
          and_yield(modified_first_affiliate).and_yield(modified_second_affiliate)
      end

      let(:ids) { 'all' }

      it 'updates all affiliate colors to defaults' do
        expect { custom_font_and_color_theme_updater.update(ids) }.
          to change { default_second_affiliate.reload.visual_design_json['banner_background_color'] }.
          from('#F0F0F0').to('#000000')
      end

      it 'does not update those affiliates with modified visual design colors with legacy colors' do
        expect { custom_font_and_color_theme_updater.update(ids) }.
          not_to change { modified_second_affiliate.reload.visual_design_json['banner_background_color'] }
      end

      it 'logs successes' do
        custom_font_and_color_theme_updater.update(ids)
        expect(Rails.logger).to have_received(:info).
          with("#{success_message} [#{default_first_affiliate.id}, #{default_second_affiliate.id}].")
      end
    end

    context 'when something goes wrong' do
      before do
        allow(custom_font_and_color_theme_updater).to receive(:update_font_and_color).and_raise(StandardError)
      end

      let(:ids) { [default_first_affiliate.id] }
      let(:failure_message) { '[custom_font_and_color_theme_updater_task] The following affiliates failed to update:' }

      it 'logs failures' do
        custom_font_and_color_theme_updater.update(ids)
        expect(Rails.logger).to have_received(:error).
          with("#{failure_message} [{:affiliate_id=>#{default_first_affiliate.id}, :reason=>\"#<StandardError: StandardError>\"}].")
      end
    end
  end
end

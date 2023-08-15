# frozen_string_literal: true

module VisualDesignHelper
  def render_affiliate_visual_design_value(visual_design_json, property)
    if visual_design_json.present? && visual_design_json[property.to_s]
      visual_design_json[property.to_s]
    else
      Affiliate::DEFAULT_VISUAL_DESIGN[property]
    end
  end
end

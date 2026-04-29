class NavigableNameUpdater
  EN_ES = %w(en es)

  def initialize(except: EN_ES)
    @locales = Language.pluck(:code) - except
  end

  def update
    update_image_search_label
  end

  private

  def update_image_search_label
    ImageSearchLabel.joins(:affiliate).where(affiliates: { locale: @locales }).readonly(false).each do |image_search_label|
      Rails.logger.info("Updating ImageSearchLabel #{image_search_label.id} name from #{image_search_label.name}")
      image_search_label.name = nil
      image_search_label.save!
      Rails.logger.info("...Updated ImageSearchLabel #{image_search_label.id} name to #{image_search_label.name}")
    end
  end
end

module GeoipExtensions
  module GeoIP
    module City
      def location_name
        [city_name, real_region_name, country_name].reject(&:blank?).join(', ')
      end
    end
  end
end

GeoIP::City.include GeoipExtensions::GeoIP::City

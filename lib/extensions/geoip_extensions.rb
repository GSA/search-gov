module GeoipExtensions
  module GeoIP
    module City
      def location_name
        "foo"
      end
    end
  end
end

GeoIP::City.include GeoipExtensions::GeoIP::City

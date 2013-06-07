if Rails::VERSION::MAJOR == 3
  module Mime
    class Type
      class << self
        def lookup_by_extension(extension)
          mime_type = EXTENSION_LOOKUP[extension.to_s]
          if mime_type.nil?
            mime_type = NullType.new('')
          end
          mime_type
        end
      end
    end

    class NullType < Type
      def nil?
        true
      end

      def html?
        false
      end
    end
  end
end

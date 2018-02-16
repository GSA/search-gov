require 'builder/blankslate'
require 'builder/xmlmarkup'

module Builder
  class XmlBase < BlankSlate

    require 'builder/xchar'
    if ::String.method_defined?(:encode)
      def _escape(text)
        result = XChar.encode(text)
        begin
          result.encode(@encoding)
        rescue
          # if the encoding can't be supported, use numeric character references
          result.
            gsub(/[^\u0000-\u007F]/) {|c| "&##{c.ord};"}.
            force_encoding('ascii')
        end
      end
    else
      def _escape(text)
        text.to_xs
      end
    end
  end
end

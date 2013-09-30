module ActionView
  module Helpers
    class FormBuilder
      def optional_label(method, content = nil, options = nil)
        @template.content_tag :div, class: 'optional' do
          @template.label(@object_name, method, content, options) <<
              ' ' <<
              @template.content_tag(:span, '(Optional)')
        end
      end
    end
  end
end

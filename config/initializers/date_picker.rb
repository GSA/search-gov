module ActionView
  module Helpers
    module FormHelper
      def date_picker_field(object_name, method, options = {})
        object = options[:object]
        value = options[:value] || object.send(method)
        formatted_value = value ? value.strftime('%m/%d/%Y') : nil
        assign_start_date = options.delete :assign_start_date
        data = { provide: 'datepicker', 'date-autoclose' => true }
        if formatted_value && assign_start_date
          data['date-start-date'] = formatted_value
        elsif assign_start_date
          data['date-start-date'] = Date.current.strftime('%m/%d/%Y')
        end
        options.merge!(value: formatted_value, class: 'date', data: data, size: nil)
        text_field object_name, method, options
      end
    end

    class FormBuilder
      def date_picker_field(method, options = {})
        @template.date_picker_field @object_name, method, objectify_options(options)
      end
    end
  end
end

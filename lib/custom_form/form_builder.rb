module CustomForm
  class FormBuilder < ActionView::Helpers::FormBuilder
    attr_reader :hints

    def initialize(object_name, object, template, options)
      @hints = options.delete(:hints) || options[:parent_builder].hints
      super
    end

    def text_field(method, options = {})
      hint_name = "#{object_name.to_s.gsub(/\[(.*)_attributes\]\[\d\]/, '.\1')}.#{method}"
      hint_value = @hints[hint_name]
      options[:data] = { original_title: hint_value, toggle: 'tooltip' } if hint_value
      super
    end
  end
end

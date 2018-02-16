module FormHelper
  def custom_form_for(record, options = {}, &block)
    options.merge!(builder: ::CustomForm::FormBuilder, hints: @hints)
    form_for record, options, &block
  end

  def custom_fields_for(record_name, record_object = nil, options = {}, &block)
    options.merge!(builder: ::CustomForm::FormBuilder, hints: @hints)
    fields_for(record_name, record_object, options, &block)
  end

  def render_error_messages(record)
    if record.errors.count > 0
      render partial: 'shared/error_messages', locals: { record: record }
    end
  end
end

class FakeMandrillAdapter < MandrillAdapter
  attr_reader :last_user, :last_template_name, :last_merge_vars

  def send_user_email(user, template_name, merge_vars={})
    @last_user = user
    @last_template_name = template_name
    @last_merge_vars = merge_vars
  end

  def clear
    @last_user = nil
    @last_template_name = nil
    @last_merge_vars = nil
  end
end

MandrillAdapter.instance_eval do
  class_variable_set(:@@fake_mandrill_adapter, FakeMandrillAdapter.new)

  def new(config=nil)
    class_variable_get(:@@fake_mandrill_adapter)
  end
end

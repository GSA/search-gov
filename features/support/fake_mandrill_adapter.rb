class FakeMandrillAdapter
  attr_reader :last_user, :last_template_name, :last_merge_vars, :bcc_setting

  def send_user_email(user, template_name, merge_vars={})
    @last_user = user
    @last_template_name = template_name
    @last_merge_vars = merge_vars
  end
end

MandrillAdapter.instance_eval do
  class_variable_set(:@@fake_mandrill_adapter, FakeMandrillAdapter.new)

  def new(config=nil)
    class_variable_get(:@@fake_mandrill_adapter)
  end
end

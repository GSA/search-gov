class MandrillRecipient
  attr_reader :config, :merge_vars, :user

  def initialize(user, config, merge_vars={ })
    @user = user
    @config = config
    @merge_vars = merge_vars
  end

  def to_user
    [{ email: user.email, name: user.contact_name }]
  end

  def to_admin
    [{ email: config[:admin_email] }]
  end

  def user_merge_vars_array
    [{ rcpt: user.email, vars: merge_var_array }]
  end

  def admin_merge_vars_array
    [{ rcpt: config[:admin_email], vars: merge_var_array }]
  end

  def default_merge_vars
    global_merge_vars.merge({
      id: user.id,
      email: user.email,
      email_verification_token: user.email_verification_token,
      contact_name: user.contact_name,
      organization_name: user.organization_name,
      requires_manual_approval: user.requires_manual_approval?,
      has_sites: user.affiliates.any?,
      latest_site: user.affiliates.last.try(:name),
    })
  end

  private

  def global_merge_vars
    config[:global_merge_vars] || { }
  end

  def merge_var_array
    combined = default_merge_vars.merge(merge_vars)
    combined.merge!(global_merge_vars)

    result = combined.to_a.map do |kv_pair|
      { name: kv_pair[0].to_s, content: kv_pair[1] }
    end

    result.sort { |a, b| a[:name] <=> b[:name] }
  end
end

class MandrillRecipient
  attr_reader :config, :merge_vars, :user

  def initialize(user, config, merge_vars={ })
    @user = user
    @config = config
    @merge_vars = merge_vars
  end

  def to_user
    [{ email: recipient_email, name: user.contact_name }] + bcc_recipients
  end

  def to_admin
    [{ email: admin_recipient_email }] + bcc_recipients
  end

  def user_merge_vars_array
    merge_vars_array(recipient_email)
  end

  def admin_merge_vars_array
    merge_vars_array(admin_recipient_email)
  end

  def default_merge_vars
    {
      id: user.id,
      email: user.email,
      contact_name: user.contact_name,
    }
  end

  private

  def merge_vars_array(email)
    [{ rcpt: email, vars: merge_var_array }] + bcc_merge_vars
  end

  def bcc_emails
    [config[:bcc_email]].flatten.compact
  end

  def bcc_recipients
    bcc_emails.map { |email| { email: email, type: 'bcc' } }
  end

  def bcc_merge_vars
    bcc_emails.map { |email| { rcpt: email, vars: merge_var_array } }
  end

  def recipient_email
    config[:force_to] || user.email
  end

  def admin_recipient_email
    config[:force_to] || config[:admin_email]
  end

  def merge_var_array
    combined = default_merge_vars.merge(merge_vars)

    result = combined.to_a.map do |kv_pair|
      { name: kv_pair[0].to_s, content: kv_pair[1] }
    end

    result.sort { |a, b| a[:name] <=> b[:name] }
  end
end

# frozen_string_literal: true

# This configuration is used to direct all application emails
# to a specific address in staging
SearchGovInterceptor = Struct.new(:force_to) do
  def delivering_email(message)
    message.to = [force_to] if force_to
  end
end

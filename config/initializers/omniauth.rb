Rails.application.config.middleware.use OmniAuth::Builder do
  private_key_path = ENV['LOGIN_CERT_LOCATION'] || 'config/logindotgov.pem'

  if File.exist?(private_key_path)
    begin
      # Read PEM content for validation
      pem_content = File.read(private_key_path)
      
      # Diagnostic logging
      Rails.logger.info("Attempting to load Login.gov certificate from: #{private_key_path}")
      Rails.logger.info("PEM file size: #{pem_content.bytesize} bytes")
      
      # Check for basic PEM structure
      unless pem_content.include?('-----BEGIN') && pem_content.include?('-----END')
        raise OpenSSL::PKey::RSAError, "PEM file missing required BEGIN/END markers"
      end
      
      # Attempt to parse the private key
      private_key = OpenSSL::PKey::RSA.new(pem_content)
      
      # Verify key properties
      unless private_key.private?
        raise OpenSSL::PKey::RSAError, "PEM file does not contain a private key"
      end
      
      Rails.logger.info("Successfully loaded Login.gov RSA key (#{private_key.n.num_bits} bits)")
      
      # Configure OmniAuth provider
      protocol = Rails.env.development? ? 'http://' : 'https://'
      provider :login_dot_gov, {
        name:         :logindotgov,
        client_id:    ENV['LOGIN_CLIENT_ID'],
        idp_base_url: ENV['LOGIN_IDP_BASE_URL'],
        ial:          1,
        private_key:  private_key,
        redirect_uri: "#{protocol}#{ENV['LOGIN_HOST']}/auth/logindotgov/callback"
      }
      
      Rails.logger.info("Login.gov authentication provider configured successfully")
      
    rescue OpenSSL::PKey::RSAError => e
      Rails.logger.error("Login.gov key parse failed at #{private_key_path}: #{e.class}")
      Rails.logger.error("Error details: #{e.message}")
      Rails.logger.error("This indicates the PEM file is corrupted or invalid")
      Rails.logger.error("Login.gov authentication will NOT be available")
      Rails.logger.error("To diagnose: Run verify_pem.sh script on the PEM file")
      
      # Log first and last few lines of the file for debugging (without exposing the key)
      lines = pem_content.lines
      if lines.length > 0
        Rails.logger.error("PEM file first line: #{lines.first.strip[0..50]}...")
        Rails.logger.error("PEM file last line: #{lines.last.strip[0..50]}...") if lines.length > 1
        Rails.logger.error("Total lines in PEM: #{lines.length}")
      end
      
    rescue StandardError => e
      Rails.logger.error("Unexpected error loading Login.gov certificate: #{e.class}")
      Rails.logger.error("Error details: #{e.message}")
      Rails.logger.error("Backtrace: #{e.backtrace.first(3).join("\n")}")
    end
  else
    Rails.logger.warn("Login.gov certificate not found at #{private_key_path}")
    Rails.logger.warn("Login.gov authentication will NOT be available")
    Rails.logger.warn("Expected file location: #{File.expand_path(private_key_path)}")
  end
end

# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_usasearch_session',
  :secret      => '9b5ce38a34ccfe7ac7e8f719204f29881e210d61c09c3ff9eafd4140722fc89593a67dec1a049d67e0dd20c0c2bf1ea0b7e0566899e81f09e866920541c6a6c1'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
ActionController::Base.session_store = :active_record_store

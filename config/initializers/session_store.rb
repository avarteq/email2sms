# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_email2sms_session',
  :secret      => 'ff8c9970531906645849fbb1118f02b7438978995f29f7d1c860f5e295d91128b4462c84b066de649771031370389cf96a154d26b1c1b5e5b6ec0292b950aa84'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store

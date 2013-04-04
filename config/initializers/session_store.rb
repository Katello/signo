# Be sure to restart your server when you modify this file.

Sso::Application.config.session_store :cookie_store, :key => '_sso_session',
                                      :expire_after => Configuration.config.session_life.hours.to_i

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Sso::Application.config.session_store :active_record_store

# Be sure to restart your server when you modify this file.

# 2016/06/24 add ƒZƒbƒVƒ‡ƒ“‚ğ5ŠÔ‚Í•Û
#BiruWeb::Application.config.session_store :cookie_store, key: '_biru-web_session'
BiruWeb::Application.config.session_store :cookie_store, key: '_biru-web_session', expire_after: 5.hours 

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# BiruWeb::Application.config.session_store :active_record_store

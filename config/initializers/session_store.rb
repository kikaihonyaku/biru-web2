# Be sure to restart your server when you modify this file.

# 2016/06/24 add セッション期限を8時間に延長
#BiruWeb::Application.config.session_store :cookie_store, key: '_biru-web_session'
BiruWeb::Application.config.session_store :cookie_store, key: '_biru-web_session', expire_after: 8.hours 

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# BiruWeb::Application.config.session_store :active_record_store

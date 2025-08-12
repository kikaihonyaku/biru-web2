# Provide Rails 3 compatibility shims for Rails 8.
# Restore update_attributes methods removed after Rails 6.
ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.class_eval do
    alias_method :update_attributes, :update
    alias_method :update_attributes!, :update!
  end
end

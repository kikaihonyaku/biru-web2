class BiruUser < ActiveRecord::Base
  
  self.table_name = 'biru.biru_users'
  def self.authenticate(code, password)
    where(:code=> code,
      :password => password).first
      #:password => Digest::SHA1.hexdigest(password)).first
  end
    
end

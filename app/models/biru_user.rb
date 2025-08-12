class BiruUser < ActiveRecord::Base
  
  def self.authenticate(code, password)
    where(:code=> code,
      :password => password).first
      #:password => Digest::SHA1.hexdigest(password)).first
  end
    
end

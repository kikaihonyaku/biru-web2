class TrustAttackStateHistory < ActiveRecord::Base
  
  belongs_to :attack_state_from, :class_name => 'AttackState'
  belongs_to :attack_state_to, :class_name => 'AttackState'
  belongs_to :trust
  belongs_to :manage_type
  
end

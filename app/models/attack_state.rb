class AttackState < ActiveRecord::Base
  # attr_accessible :title, :body
  
  # �����N�̃X�R�A�̔�r�B�����N�������Ȃ�0 rank_b�̕]���̕����Ⴏ���1�Arank_b�̕]���̕����������2��Ԃ�
  def self.compare_rank(rank_a, rank_b)
    
    if rank_a.score == rank_b.score
      return 0
    elsif rank_a.score > rank_b.score
      return 1
    else
      return 2
    end
    
  end
end

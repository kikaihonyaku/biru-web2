class AttackState < ActiveRecord::Base
  # attr_accessible :title, :body
  
  # ƒ‰ƒ“ƒN‚ÌƒXƒRƒA‚Ì”äŠrBƒ‰ƒ“ƒN‚ª“¯‚¶‚È‚ç0 rank_b‚Ì•]‰¿‚Ì•û‚ª’á‚¯‚ê‚Î1Arank_b‚Ì•]‰¿‚Ì•û‚ª‚‚¯‚ê‚Î2‚ğ•Ô‚·
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

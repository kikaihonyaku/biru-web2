# gmaps4rails gemの互換性修正
# Rails 8.0との互換性の問題を解決するため、acts_as_gmappableメソッドを手動で定義

module ActiveRecord
  module Acts
    module Gmappable
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def acts_as_gmappable(options = {})
          # 基本的なGoogle Maps機能を提供するメソッドを定義
          # 実際の実装は必要に応じて追加
          
          # 緯度・経度のバリデーション
          validates :latitude, :longitude, presence: true, if: :gmaps?
          
          # gmapsフラグのデフォルト値を設定
          before_save :set_gmaps_default
          
          # スコープを定義
          scope :with_gmaps, -> { where(gmaps: true) }
          
          # クラスメソッドを定義
          def self.gmaps_enabled
            where(gmaps: true)
          end
        end
      end
      
      private
      
      def set_gmaps_default
        self.gmaps = true if self.gmaps.nil? && self.latitude.present? && self.longitude.present?
      end
    end
  end
end

# ActiveRecord::Baseにモジュールをinclude
ActiveRecord::Base.include(ActiveRecord::Acts::Gmappable)

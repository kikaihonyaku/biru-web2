class FrontendController < ApplicationController
  def index
    # フロントエンドアプリのページでは既存のRailsヘッダーを非表示にする
    @header_hidden = true
  end
end

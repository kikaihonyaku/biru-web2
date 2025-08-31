class FrontendController < ApplicationController
  def index
    # フロントエンドアプリのページでは既存のRailsヘッダーを非表示にする
    if request.path.start_with?('/cosmos') || request.path == '/'
      @header_hidden = true
    end
  end
end

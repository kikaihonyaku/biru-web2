class HomeController < ApplicationController
  def index
    # Cosmosアプリ（React）のページでは既存のRailsヘッダーを非表示にする
    if request.path.start_with?('/cosmos') || request.path == '/'
      @header_hidden = true
    end
  end
end

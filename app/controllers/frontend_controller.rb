class FrontendController < ApplicationController
  def index
    # フロントエンドアプリのページでは既存のRailsヘッダーを非表示にする
    @header_hidden = true
    
    # React アプリを識別するために元のリクエストパスを設定
    @is_cosmos_app = request.original_fullpath.start_with?('/cosmos') || 
                     request.original_fullpath.start_with?('/map') ||
                     request.original_fullpath == '/'
    @is_react_app = @is_cosmos_app
  end
end

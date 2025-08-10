# -*- encoding:utf-8 -*-

class LoginController < ApplicationController
  skip_before_action :check_logined

  def index
    @login_code = ""
    @login_code = params[:login_code] if params[:login_code]
  end

  def auth
    if params[:code].to_i != 0
      @login_code = params[:code].to_i.to_s
    else
      @login_code = params[:code]
    end

    biru_user = BiruUser.authenticate(@login_code, params[:password])
    if biru_user

      # ログの保存
      log = LoginHistory.new
      log.biru_user_id = biru_user.id
      log.code = biru_user.code
      log.name = biru_user.name
      log.save!

      session[:biru_user] = biru_user.id

      # refererがブランクだったらルートに飛ばす。
      if params[:referer].blank?
        redirect_to "/biruweb/"
      else
        redirect_to params[:referer]
      end

    else
      flash.now[:referer] = params[:referer]
      @error = "社員番号またはパスワードが違います"
      render "index"
    end
  end

  def logout
    reset_session
    redirect_to "/biruweb/"
  end
end

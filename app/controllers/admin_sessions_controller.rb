class AdminSessionsController < ApplicationController
  def new
    @admin_configured = admin_credentials_configured?
    render 'pages/admin_login'
  end

  def create
    expected_username = ENV['ADMIN_USERNAME'].to_s
    expected_password = ENV['ADMIN_PASSWORD'].to_s
    username = params[:username].to_s
    password = params[:password].to_s

    if expected_username.present? && expected_password.present? &&
        secure_match?(username, expected_username) && secure_match?(password, expected_password)
      reset_session
      session[:admin_authenticated] = true
      redirect_to admin_shops_path, notice: 'ログインしました。'
    else
      @admin_configured = admin_credentials_configured?
      flash.now[:alert] = if @admin_configured
                            'ユーザー名またはパスワードが違います。'
                          else
                            '管理者の認証情報が未設定です。環境変数を設定してください。'
                          end
      render 'pages/admin_login', status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to root_path, notice: 'ログアウトしました。'
  end

  private

  def admin_credentials_configured?
    ENV['ADMIN_USERNAME'].present? && ENV['ADMIN_PASSWORD'].present?
  end

  def secure_match?(actual, expected)
    ActiveSupport::SecurityUtils.secure_compare(actual, expected)
  end
end

class ContactsController < ApplicationController
  def new
    @contact = contact_params_from(nil)
    @contact_email = ENV['CONTACT_EMAIL'].to_s
    render template: 'pages/contact'
  end

  def create
    @contact = contact_params_from(params[:contact])
    @contact_email = ENV['CONTACT_EMAIL'].to_s

    if valid_contact?
      @mailto_url = build_mailto_url
      render template: 'pages/contact_sent'
    else
      render template: 'pages/contact', status: :unprocessable_entity
    end
  end

  private

  def contact_params_from(attributes)
    values = attributes&.permit(:name, :email, :message) || ActionController::Parameters.new
    { name: values[:name].to_s.strip, email: values[:email].to_s.strip, message: values[:message].to_s.strip }
  end

  def valid_contact?
    @errors = []
    @errors << 'お名前を入力してください。' if @contact[:name].blank?
    @errors << 'メールアドレスを正しく入力してください。' unless @contact[:email].match?(URI::MailTo::EMAIL_REGEXP)
    @errors << 'お問い合わせ内容を入力してください。' if @contact[:message].blank?
    @errors << 'お問い合わせ内容は4000文字以内で入力してください。' if @contact[:message].length > 4000
    @errors << 'お問い合わせ先が設定されていません。' if @contact_email.blank?
    @errors.empty?
  end

  def build_mailto_url
    recipient = @contact_email
    subject = ERB::Util.url_encode("煮干ラーメンサイトへのお問い合わせ（#{@contact[:name]}）")
    body = ERB::Util.url_encode("お名前: #{@contact[:name]}\nメールアドレス: #{@contact[:email]}\n\n#{@contact[:message]}")
    "mailto:#{recipient}?subject=#{subject}&body=#{body}"
  end
end

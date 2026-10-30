require 'rails_helper'

RSpec.describe 'Contact form', type: :request do
  before do
    allow(ENV).to receive(:[]).and_call_original
  end

  it 'renders the contact form' do
    get contact_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include('お名前', 'メールアドレス', 'お問い合わせ内容')
  end

  it 'builds a mailto link for valid submissions without sending an email' do
    allow(ENV).to receive(:[]).with('CONTACT_EMAIL').and_return('owner@example.com')
    post contact_path, params: {
      contact: { name: 'テスト利用者', email: 'visitor@example.com', message: '店舗情報について' }
    }

    expect(response).to have_http_status(:success)
    expect(response.body).to include('owner@example.com', 'メールアプリを開く')
    expect(ActionMailer::Base.deliveries).to be_empty
  end

  it 'rejects invalid submissions' do
    allow(ENV).to receive(:[]).with('CONTACT_EMAIL').and_return('owner@example.com')
    post contact_path, params: { contact: { name: '', email: 'invalid', message: '' } }

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include('お名前を入力してください', 'メールアドレスを正しく入力してください')
  end

  it 'does not accept a submission when the recipient is missing' do
    allow(ENV).to receive(:[]).with('CONTACT_EMAIL').and_return('')
    post contact_path, params: {
      contact: { name: 'テスト利用者', email: 'visitor@example.com', message: '問い合わせ' }
    }

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include('お問い合わせ先が設定されていません')
  end
end

require "rails_helper"

RSpec.describe "Turbo prefetch", type: :request do
  it "レイアウトでホバー先読みが無効化されている" do
    get root_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('<meta name="turbo-prefetch" content="false">')
  end
end

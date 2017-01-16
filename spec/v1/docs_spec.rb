require "rails_helper"

RSpec.describe V1::DocsController, type: :request, helpers: true do

  it "shows the api documents" do
    get v1_docs_path
    expect(response).to be_success
    expect(response.body).to include("Print My Barcode")
  end

end



require "rails_helper"

RSpec.describe "Logo behaviour" do
  let!(:user) { create(:user) }

  before do
    sign_in user
  end

  it "renders the custom svg logo" do
    visit root_path
    within(".site-logo") do
      expect(page).to have_css("svg.site-logo__svg")
    end
  end
end

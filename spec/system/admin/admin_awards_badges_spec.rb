require "rails_helper"

RSpec.describe "Admin awards chips" do
  let(:admin) { create(:user, :super_admin) }
  let(:user) { create(:user) }
  let(:user2) { create(:user) }
  let(:badges) { Badge.pluck(:title) }

  def award_two_chips
    find(:xpath, "//option[contains(text(), \"#{badges.last}\")]").select_option
    fill_in "usernames", with: "#{user.username}, #{user2.username}"
    fill_in "message_markdown", with: "He who controls the spice controls the universe."
    click_on "Award Chips"
  end

  def award_no_chips
    fill_in "usernames", with: "#{user.username}, #{user2.username}"
    fill_in "message_markdown", with: "He who controls the spice controls the universe."
    click_on "Award Chips"
  end

  before do
    create_list(:badge, 5)
    sign_in admin
    visit admin_badge_achievements_award_badges_path
  end

  it "loads the view" do
    expect(page).to have_content("Chips")
  end

  it "lists the chips" do
    badges.each do |badge|
      expect(page).to have_content(badge)
    end
  end

  it "awards chips" do
    expect do
      sidekiq_perform_enqueued_jobs { award_two_chips }
    end.to change { user.badges.count }.by(1).and change { user2.badges.count }.by(1)
    expect(page).to have_content("Chips are being rewarded. The task will finish shortly")

    visit "/#{user.username}/"

    expect(page).to have_css("img[src='#{Badge.last.badge_image.url}']")
  end

  it "does not award chips if no chip is selected", js: true do
    expect do
      sidekiq_perform_enqueued_jobs { award_no_chips }
    end.not_to change { user.badges.count }

    expect(page).to have_content("Please choose a chip to award")
  end
end

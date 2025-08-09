require "rails_helper"

RSpec.describe EdgeCache::BustUser, type: :service do
  let(:user) { create(:user) }

  it "busts the cache" do
    expected_urls = [
      URL.user(user),
      URL.url("/api/users/#{user.id}"),
    ].compact

    allow(EdgeCache::Purger).to receive(:purge_urls)

    described_class.call(user)

    expect(EdgeCache::Purger).to have_received(:purge_urls).with(expected_urls)
  end
end

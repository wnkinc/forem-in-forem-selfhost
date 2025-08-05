require "rails_helper"

RSpec.describe CommentsHelper, type: :helper do
  describe "#commentable_author_is_op?" do
    it "returns true for co-author on regular article" do
      author = create(:user)
      co_author = create(:user)
      article = create(:article, user: author, co_author_ids: [co_author.id])
      comment = create(:comment, commentable: article, user: co_author)
      expect(helper.commentable_author_is_op?(article, comment)).to be(true)
    end

    it "returns false for co-author on anonymous article" do
      author = create(:user)
      mascot = create(:user)
      allow(Settings::General).to receive(:mascot_user_id).and_return(mascot.id)
      article = create(:article, user: author, tag_list: "anonymous")
      comment = create(:comment, commentable: article, user: author)
      expect(helper.commentable_author_is_op?(article, comment)).to be(false)
    end
  end
end

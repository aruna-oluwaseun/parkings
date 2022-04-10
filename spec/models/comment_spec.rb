require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe 'creating comment' do
    it 'has valid factory' do
      parking_violation = create(:parking_violation)
      comment = create(:comment, :with_violation, subject: parking_violation )
      expect(comment).to be_valid
      expect(comment.content).to be_present
      expect(comment.subject_type).to be_present
      expect(comment.subject_id).to be_present
    end
  end
end

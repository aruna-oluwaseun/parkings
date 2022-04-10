require 'rails_helper'

describe Statistics::ViolationReportsRejected do
  it_behaves_like 'a violation reports' do
    let(:suit_samples) do
      {
        title: '[Rejected] Violation Reports',
        label: 'Rejected',
        status: :rejected
      }
    end
  end
end

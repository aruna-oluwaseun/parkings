require 'rails_helper'

describe Statistics::ParkingTicketsOpened do
  skip 'a parking ticket statistic' do
    let(:suit_samples) do
      {
        title: '[Open] Citation Tickets',
        label: 'Open Tickets',
        status: :opened
      }
    end
  end
end

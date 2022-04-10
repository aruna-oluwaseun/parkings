require 'rails_helper'

describe Statistics::ParkingTicketsSettled do
  skip 'a parking ticket statistic' do
    let(:suit_samples) do
      {
        title: '[Settled] Citation Tickets',
        label: 'Settled Tickets',
        status: :closed
      }
    end
  end
end

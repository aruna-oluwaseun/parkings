require 'rails_helper'

RSpec.describe Logs::Dashboard::SessionLog, type: :service do

  describe 'Versioning' do

    context 'Return all Logs for parking session' do
      subject do
       @version = PaperTrail::Version.where(item_type: 'ParkingSession')
      end

      it 'Returns all logs for parkings session' do
        expect(subject).to match_array(@version)
      end
    end
  end
end

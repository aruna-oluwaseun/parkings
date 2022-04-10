require 'rails_helper'

RSpec.describe Api::Dashboard::VehiclesController, type: :request do
  let!(:town_manager) { create(:admin, role: town_manager_role) }
  let!(:super_admin) { create(:admin, role: super_admin_role) }
  let!(:user) { create(:user) }
  let!(:vehicle) { create_list(:vehicle, 10, user: user) }

  describe 'GET #index' do
     context 'success' do
      %w(super_admin town_manager).each do |admin_account|
        context "with #{admin_account} filter" do
          subject do
            get '/api/dashboard/vehicles', headers: { Authorization: get_auth_token(send(admin_account)) }
          end
          it_behaves_like 'response_200', :show_in_doc

          it 'should  return all the vehicles' do
            subject
            expect(json.size).to eq(10)
          end
        end
      end
    end
  end

  context 'when plate number is present' do
    subject do
      get '/api/dashboard/vehicles', headers: { Authorization: get_auth_token(super_admin) },
        params: {
          vehicle: {
           plate_number: @plate_name
          }
        }
    end

    it_behaves_like 'response_200', :show_in_doc
  end

  context 'when first name  is present' do
    subject do
      get '/api/dashboard/vehicles', headers: { Authorization: get_auth_token(super_admin) },
        params: {
          vehicle: {
           first_name: @first_name
          }
        }
    end

    it_behaves_like 'response_200', :show_in_doc
  end

  context 'when last name  is present' do
    subject do
      get '/api/dashboard/vehicles', headers: { Authorization: get_auth_token(super_admin) },
        params: {
          vehicle: {
           last_name: @last_name
          }
        }
    end

    it_behaves_like 'response_200', :show_in_doc
  end

  context 'when manufacturer_id is present' do
    subject do
      get '/api/dashboard/vehicles', headers: { Authorization: get_auth_token(super_admin) },
        params: {
         vehicle: {
           manufacturer_id: @manufacturer_id
          }
        }
    end

    it_behaves_like 'response_200', :show_in_doc
  end

  context 'when status is present' do
    subject do
      get '/api/dashboard/vehicles', headers: { Authorization: get_auth_token(super_admin) },
        params: {
         vehicle: {
           status: @status
          }
        }
    end

    it_behaves_like 'response_200', :show_in_doc
  end

  context 'when date created is present' do
    subject do
      get '/api/dashboard/vehicles', headers: { Authorization: get_auth_token(super_admin) },
        params: {
         vehicle: {
           created_at: @created_at
          }
        }
    end

    it_behaves_like 'response_200', :show_in_doc
  end

  context 'when date created is present' do
    subject do
      get '/api/dashboard/vehicles', headers: { Authorization: get_auth_token(super_admin) },
        params: {
         vehicle: {
           created_at: @created_at
          }
        }
    end

    it_behaves_like 'response_200', :show_in_doc
  end

  context 'set to active' do
    let!(:vehicle) { create(:vehicle, id: 30) }
    context 'Success' do
      subject do
        put "/api/dashboard/vehicles/#{vehicle.id}/active", headers: { Authorization: get_auth_token(super_admin) }, params: {
          status: '1'
        }
      end

      it 'should update status to active' do
        subject
        vehicle.reload
        expect(vehicle.status).to eq("active")
        expect(status).to eq(200)
      end

      it 'should send message on status change to active' do
         ActiveJob::Base.queue_adapter = :test
         expect { subject }.to( have_enqueued_job.on_queue('mailers').with(
          'VehicleMailer', 'active', 'deliver_now', vehicle.id)
         )
      end

    end
  end

  describe 'set to inactive' do
     let!(:vehicle) { create(:vehicle, id: 30) }

     context 'Success' do

       subject do
         put "/api/dashboard/vehicles/#{vehicle.id}/inactive", headers: { Authorization: get_auth_token(super_admin) }, params: {
           status: '2'
         }
       end

       it 'should update status to inactive' do
         expect(vehicle.status).to eq("active")
         subject
         vehicle.reload
         expect(vehicle.status).to eq("inactive")
         expect(status).to eq(200)
       end

       it 'should send message on status change to inactive' do
          ActiveJob::Base.queue_adapter = :test
          expect { subject }.to( have_enqueued_job.on_queue('mailers').with(
            'VehicleMailer', 'inactive', 'deliver_now', vehicle.id)
          )
       end

     end
   end

  describe 'set to Rejected' do
   let!(:vehicle) { create(:vehicle, id: 30) }
   context 'Success' do
     subject do
       put "/api/dashboard/vehicles/#{vehicle.id}/rejected", headers: { Authorization: get_auth_token(super_admin) }, params: {
         status: '3'
       }
     end

     it 'should update status to Rejected' do
       subject
       vehicle.reload
       expect(vehicle.status).to eq("rejected")
       expect(status).to eq(200)
     end

     it 'should send message on status change to Rejected' do
         ActiveJob::Base.queue_adapter = :test
         expect { subject }.to( have_enqueued_job.on_queue('mailers').with(
            'VehicleMailer', 'rejected', 'deliver_now', vehicle.id)
         )
      end

   end
 end

end

require 'rails_helper'

RSpec.describe Api::Dashboard::ImageSerializer, type: :serializer do

 let(:parking_session) { create(:parking_session) }
 let(:image) { create(:image, imageable: parking_session ) }
 let(:serializer) { described_class.new(image) }
 let(:serialization) { ActiveModelSerializers::Adapter.create(serializer) }
 let(:subject) { JSON.parse(serialization.to_json) }

 describe 'Validating serializer' do
  it 'has an id that matches' do
    expect(subject['id']).to eql(image.id)
  end
  it 'has a File that matches' do
     expect(subject['file_url']).to end_with('/test.jpg')
  end
 end
end

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe 'POST #create' do
    let(:valid_attributes) do
      {
        first_name: 'John',
        last_name: 'Doe',
        email: 'john@example.com',
        date_of_birth: '1990-01-01',
        uploaded_file: fixture_file_upload('spec/fixtures/files/test.pdf', 'application/pdf')
      }
    end

    let(:invalid_attributes) do
      {
        first_name: '',
        last_name: '',
        email: '',
        date_of_birth: nil
      }
    end

    context 'with valid parameters' do
      it 'creates a new User' do
        expect {
          post :create, params: { user: valid_attributes }
        }.to change(User, :count).by(1)
      end

      it 'renders a JSON response with the new user' do
        post :create, params: { user: valid_attributes }
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
      end

      it 'creates user with correct attributes' do
        post :create, params: { user: valid_attributes }
        user = User.last
        expect(user.first_name).to eq('John')
        expect(user.last_name).to eq('Doe')
        expect(user.email).to eq('john@example.com')
        expect(user.date_of_birth.to_s).to eq('1990-01-01')
        expect(user.uploaded_file).to be_attached
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new User' do
        expect {
          post :create, params: { user: invalid_attributes }
        }.to change(User, :count).by(0)
      end

      it 'renders a JSON response with errors' do
        post :create, params: { user: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end
end

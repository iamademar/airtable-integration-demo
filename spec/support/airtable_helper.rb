RSpec.configure do |config|
  config.before(:each) do
    allow(External::Airtable::UserRecord).to receive(:create_from_user).and_return(true)
  end
end

RSpec.configure do |config|
  config.before(:each) do
    ActiveStorage::Current.url_options = { host: "localhost", port: 3000 }
  end
end

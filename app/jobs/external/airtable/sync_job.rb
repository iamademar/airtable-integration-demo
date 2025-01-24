class External::Airtable::SyncJob < ApplicationJob
  queue_as :default
  retry_on Airrecord::Error, wait: 5.seconds, attempts: 3

  def perform(user_id)
    user = User.find(user_id)
    External::Airtable::UserRecord.create_from_user(user)
  end
end

class User < ApplicationRecord
  has_one_attached :uploaded_file

  validates :first_name, :last_name, :email, :date_of_birth, presence: true
  validates :uploaded_file, attached: true,
                          content_type: { in: [ "application/pdf", "image/png", "image/jpeg" ], message: "must be a PDF or PNG" },
                          size: { less_than: 5.megabytes, message: "must be less than 5MB" }

  after_commit :schedule_airtable_sync, on: :create

  private

    def schedule_airtable_sync
      External::Airtable::SyncJob.perform_later(id)
    end

end

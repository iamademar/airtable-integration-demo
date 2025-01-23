class User < ApplicationRecord
  has_one_attached :uploaded_file

  validates :first_name, :last_name, :email, :date_of_birth, presence: true
  validates :uploaded_file, attached: true,
                          content_type: { in: [ "application/pdf", "image/png", "image/jpeg" ], message: "must be a PDF or PNG" },
                          size: { less_than: 5.megabytes, message: "must be less than 5MB" }

  after_commit :sync_to_airtable, on: :create

  private

    def sync_to_airtable
      External::Airtable::UserRecord.create_from_user(self)
    end

end

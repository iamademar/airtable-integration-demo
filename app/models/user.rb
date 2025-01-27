class User < ApplicationRecord
  has_one_attached :uploaded_file

  validates :first_name, :last_name, :email, :date_of_birth, presence: true
  validates :uploaded_file, attached: true,
                          content_type: { in: [ "application/pdf", "image/png", "image/jpeg" ], message: "must be a PDF or PNG" },
                          size: { less_than: 5.megabytes, message: "must be less than 5MB" }

  after_commit :schedule_airtable_sync, on: :create
  after_create_commit :broadcast_new_user
  after_update_commit :broadcast_sync_status, if: :saved_change_to_synced_at?

  private

    def schedule_airtable_sync
      External::Airtable::SyncJob.perform_later(id)
    end

    def broadcast_new_user
      puts "================= BROADCASTING NEW USER =================="
      puts "Broadcasting new user: #{self.inspect}"
      ActionCable.server.broadcast "user_updates", {
        type: "new_user",
        user: {
          id: id,
          first_name: first_name,
          last_name: last_name,
          email: email,
          date_of_birth: date_of_birth,
          created_at: created_at,
          synced_at: synced_at
        }
      }
    end

    def broadcast_sync_status
      puts "================= BROADCASTING NEW USER =================="
      puts "Broadcasting sync status for user #{id}"
      ActionCable.server.broadcast("user_updates", {
        type: "sync_status_update",
        user: {
          id: id,
          synced_at: synced_at
        }
      })
    end

end

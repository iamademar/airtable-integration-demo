require "airrecord"
Airrecord.api_key = Rails.application.credentials.dig(:airtable, :api_key)

class External::Airtable::UserRecord < Airrecord::Table
  include Rails.application.routes.url_helpers

  self.base_key = Rails.application.credentials.dig(:airtable, :base_id)
  self.table_name = "User"

  def self.create_from_user(user)
    record = new

    file_attachment = if user.uploaded_file.attached?
      [ {
        url: user.uploaded_file.url(expires_in: 1.week),
        filename: user.uploaded_file.filename.to_s
      } ]
    end

    create(
      "First Name": user.first_name,
      "Last Name": user.last_name,
      "Email": user.email,
      "Date of Birth": user.date_of_birth.to_s,
      "File Uploaded": file_attachment
    )
  rescue Airrecord::Error => e
    Rails.logger.error "Failed to create Airtable record: #{e.message}"
    false
  end

end

FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    date_of_birth { Faker::Date.birthday(min_age: 18, max_age: 65) }

    trait :with_file do
      after(:build) do |user|
        file_path = Rails.root.join('spec/fixtures/files/test.pdf')
        user.uploaded_file.attach(
          io: File.open(file_path),
          filename: 'test.pdf',
          content_type: 'application/pdf'
        )
      end
    end
  end
end 
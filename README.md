# Profile API

A Rails API application that manages user profiles with real-time updates and Airtable synchronization.

## Tech Stack Overview

### Core Technologies
- **Ruby on Rails 8.0.1** (API-only mode)
- **PostgreSQL** database
- **Action Cable** for real-time updates
- **Active Storage** with AWS S3 for file uploads

### Key Gems
```
gem "rails", "~> 8.0.1"
gem "pg", "~> 1.1"
gem "airrecord" # Airtable integration
gem "aws-sdk-s3" # AWS S3 storage
gem "solid_cache" # Database-backed cache
gem "solid_queue" # Database-backed job processing
gem "solid_cable" # Database-backed Action Cable
gem "kamal" # Deployment
```

### Database Configuration
The application uses multiple PostgreSQL databases for different purposes:

Found on config/database.yml
```
production:
  primary: # Main application database
  cache: # For solid_cache
  queue: # For solid_queue
  cable: # For solid_cable
```

### Real-time Updates with Action Cable
Action Cable is configured to handle real-time updates through the `UserUpdatesChannel` ([app/channels/user_updates_channel.rb](app/channels/user_updates_channel.rb)). It broadcasts:
- New user creation
- Airtable sync status updates


## Deployment

### Prerequisites
- An EC2 instance running Ubuntu
- Docker installed on the server
- PostgreSQL database
- AWS S3 bucket configured

### How to deploy with Kamal

The application is deployed using Kamal 2.0. Deployment configuration is defined in [config/deploy.yml](config/deploy.yml).

1. Setup accesory first:
```
bin/kamal accessory boot db
```

2. Setup deploy app:
```
bin/kamal deploy
```

### Server Configuration
Can be found on config/deploy.yml
```
service: profile_api
  servers:
    web:
      x.xxx.xxx.xx
    job:
      hosts:
      x.xxx.xxx.xx
```

## Notable Feature Implementation

### User Data Synchronization with Airtable

When a user is created, the following process occurs:

1. User creation triggers an after_commit callback:

Found in app/models/user.rb
```
after_commit :schedule_airtable_sync, on: :create
```

2. The sync job is queued:

Found in app/jobs/external/airtable/sync_job.rb
```
class External::Airtable::SyncJob < ApplicationJob
  def perform(user_id)
    user = User.find(user_id)
    External::Airtable::UserRecord.create_from_user(user)
  end
end
```

3. User data is synchronized with Airtable:

Found in app/models/external/airtable/user_record.rb
```
def self.create_from_user(user)
  create(
    "First Name": user.first_name,
    "Last Name": user.last_name,
    "Email": user.email,
    "Date of Birth": user.date_of_birth.to_s,
    "File Uploaded": file_attachment
  )
end
```

### Real-time Updates

The application uses Action Cable to broadcast user-related events:

1. New User Creation:

Found in app/models/user.rb
```
after_create_commit :broadcast_new_user

def broadcast_new_user
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
```

2. Sync Status Updates:

found on app/models/user.rb
```
after_update_commit :broadcast_sync_status, if: :saved_change_to_synced_at?

def broadcast_sync_status
  ActionCable.server.broadcast("user_updates", {
      type: "sync_status_update",
      user: {
      id: id,
      synced_at: synced_at
    }
  })
end
```


Clients can subscribe to these updates through the UserUpdatesChannel:

Found on app/channels/user_updates_channel.rb
```
  class UserUpdatesChannel < ApplicationCable::Channel
    def subscribed
      stream_from "user_updates"
    end
  end
```

## Development Setup

1. Clone the repository
2. Install dependencies:

```
  bundle install
```

3. Setup database:

```
  bin/rails db:setup
```

4. Start the server:

```
  bin/dev
```

## Environment Variables

The following environment variables need to be set:
- `RAILS_MASTER_KEY`
- `PROFILE_API_DATABASE_PASSWORD`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AIRTABLE_API_KEY`
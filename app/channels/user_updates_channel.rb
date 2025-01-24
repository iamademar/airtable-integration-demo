class UserUpdatesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "user_updates"
  end

  def received(data)
    puts "================= RECEIVED DATA =================="
    puts "============ Received data in UserUpdatesChannel: #{data}"
    puts "================= RECEIVED DATA =================="
  end

  def unsubscribed
    puts "======= Client unsubscribed from UserUpdatesChannel"
  end
end

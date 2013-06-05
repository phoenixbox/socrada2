class GetProfile
  include Sidekiq::Worker
  sidekiq_options unique: true
  
  def perform(uid, friend_id)
    user = User.find_by_uid(uid)
    
    begin
      friend_node = $neo.get_node_index("users", "uid", friend_id).first
    rescue
      friend_node = nil
    end
        
    unless friend_node["data"]["screen_name"]
      begin
        friend = user.client.user(friend_id)
        $neo.set_node_properties(friend_node,
                           {"name"      => friend.name,
                            "screen_name"  => friend.screen_name,
                            "location"  => friend.location,
                            "image_url" => friend.profile_image_url,
                            "uid"       => friend.id,
                            "statuses_count"  => friend.statuses_count,
                            "followers_count" => friend.followers_count,
                            "friends_count"   => friend.friends_count
                            })        
    
      rescue Twitter::Error::TooManyRequests => error
        GetFollowers.perform_in( rand(15..60).minutes, uid, friend_id)
      end  
    end
  end
end


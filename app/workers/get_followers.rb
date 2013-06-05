class GetFollowers
  include Sidekiq::Worker
  sidekiq_options queue: "high"
  
  def perform(uid, cursor = "-1")
    user = User.find_by_uid(uid)
    commands = [] 
    friend_nodes =[]
    cursor ||= "-1"

    # Get the twitter users that follow me

    while cursor != 0 do
      friends = user.client.follower_ids({:cursor => cursor})
      
      begin
        friends.ids.each do |f|
          friend = user.client.user(f)
          commands << [:create_unique_node, "users", "uid", friend.id, 
                       {"name"      => friend.name,
                        "nickname"  => friend.screen_name,
                        "location"  => friend.location,
                        "image_url" => friend.profile_image_url,
                        "uid"       => friend.id,
                        "statuses_count"  => friend.statuses_count,
                        "followers_count" => friend.followers_count,
                        "friends_count"   => friend.friends_count
                        }]
        end
      
        batch_result = $neo.batch *commands
        batch_result.each do |b|  
          friend_nodes << {:uid => b["body"]["data"]["uid"], :node_id => b["body"]["self"].split("/").last}
        end
        
        cursor = friends.next_cursor
      rescue Twitter::Error::TooManyRequests => error
        GetFollowers.perform_in(16.minutes, uid, cursor)
      end  
        
        
    end

    
    # Add the twitter users I follow as my followers
    commands = [] 
     
    friend_nodes.each do |b|  
      commands << [:create_unique_relationship, "follows", "nodes",  "#{b[:uid]}-#{uid}", "follows", b[:node_id], user]
    end

    $neo.batch *commands
  end
end
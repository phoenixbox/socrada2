class GetFollowers
  include Sidekiq::Worker
  sidekiq_options queue: "high"
  
  def perform(uid)
    user = User.find_by_uid(uid)
    commands = [] 
    cursor = "-1"

    # Get the twitter users that follow me

    while cursor != 0 do
      friends = user.client.follower_ids({:cursor => cursor})
      cursor = friends.next_cursor

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
    end

    batch_result = $neo.batch *commands

    
    # Add the twitter users I follow as my followers
    commands = [] 
     
    batch_result.each do |b|  
      commands << [:create_unique_relationship, "follows", "nodes",  "#{b["body"]["data"]["uid"]}-#{uid}", "follows", b["body"]["self"].split("/").last, user]
    end

    $neo.batch *commands

end
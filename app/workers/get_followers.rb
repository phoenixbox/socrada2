class GetFollowers
  include Sidekiq::Worker
  sidekiq_options queue: "high"
  
  def perform(uid, cursor = "-1")
    user = User.find_by_uid(uid)
    commands = [] 
    friend_nodes =[]
    cursor ||= "-1"
    slice_count = 0
  
    while cursor != 0 do
      friends = user.client.follower_ids({:cursor => cursor})
      
      begin
        friends.ids.each_slice(100) do |slice|
          slice.each do |f|
            commands << [:create_unique_node, "users", "uid", "#{f}", {:uid => "#{f}"}]
            GetProfile.perform_in( (1 + (slice_count * 15) ).minutes, uid, "#{f}")
          end
          slice_count += 1
        end
      
        batch_result = $neo.batch_not_streaming *commands
        batch_result.each do |b|  
          friend_nodes << {:uid => b["body"]["data"]["uid"], :node_id => b["body"]["self"].split("/").last}
        end
        
        cursor = friends.next_cursor
      rescue Twitter::Error::TooManyRequests => error
        GetFollowers.perform_in(16.minutes, uid, cursor)
      end          
    end
    
    commands = [] 
     
    friend_nodes.each do |b|  
      commands << [:create_unique_relationship, "follows", "nodes",  "#{b[:uid]}-#{uid}", "follows", b[:node_id], user]
    end

    $neo.batch_not_streaming *commands
  end
end
class User < Neography::Node

  def self.find_by_uid(uid)
    begin
      user = $neo.get_node_index("users", "uid", uid)
    rescue
      user = nil
    end

    if user && user.first["data"]["token"]
      self.new(user.first)
    else
      nil
    end
  end
  
  def self.create_with_omniauth(auth)
    node = $neo.create_unique_node("users", "uid", auth.uid)
    $neo.set_node_properties(node, 
                              {"name"       => auth.info.name,
                                "nickname"  => auth.info.nickname,
                                "location"  => auth.info.location,
                                "image_url" => auth.info.image,
                                "uid"       => auth.uid,
#                                "statuses_count"  => auth.info.statuses_count,
#                                "followers_count" => auth.info.followers_count,
#                                "friends_count"   => auth.info.friends_count,
                                "token"     => auth.credentials.token, 
                                "secret"    => auth.credentials.secret})
    user = User.load(node)
    GetFollowers.perform_async(user.uid, "-1")
    user
  end
  
    def client
      @client ||= Twitter::Client.new(
        :oauth_token        => self.token,
        :oauth_token_secret => self.secret
       )
    end
      
end  
class UsersController < ApplicationController
  respond_to :html, :json

  def show
    "nothing to see yet"
  end
  
  def related
    cypher = "START me=node:users(uid={uid}) 
              MATCH me -- related
              WHERE has(related.screen_name)
              RETURN me.uid, COALESCE(me.screen_name?, me.uid) AS screen_name, 
                             COALESCE(me.image_url?,'/assets/twitter.png') AS me_image_url, 
                     related.uid, COALESCE(related.screen_name?, related.uid) AS related_screen_name, 
                                  COALESCE(related.image_url?, '/assets/twitter.png') AS related_image_url                 
              LIMIT 50"

    connections = $neo.execute_query(cypher, {:uid => params[:id].to_i })["data"]
    render json: connections.collect{|n| {"source" => n[0], "source_data" => {:screen_name => n[1], 
                                                                              :image_url => n[2]},
                                          "target" => n[3], "target_data" => {:screen_name => n[4], 
                                                                             :image_url => n[5]}} }.to_json    
    
  end
end
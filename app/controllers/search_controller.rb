class SearchController < ApplicationController
  respond_to :json

  # Note the action and route create to trigger the action
  def screen_names
    cypher = "START me=node:users({query}) 
              RETURN me.uid, me.screen_name
              ORDER BY me.screen_name
              LIMIT 15"
   render json: $neo.execute_query(cypher, {:query => "screen_name:*#{params[:term]}* OR name:*#{params[:term]}*" })["data"].map{|x| { label: x[1], value: x[0]}}.to_json
  end
  
  def paths
    uid = params[:q]
    cypher = "START me=node:users(uid={uid}) 
              MATCH me -- related
              RETURN me.uid, me.screen_name, me.image_url, 
                     related.uid, COALESCE(related.screen_name?, related.uid) AS related_screen_name, 
                                  COALESCE(related.image_url?, '/images/twitter.png') AS related_image_url"
    connections = $neo.execute_query(cypher, {:uid => uid.to_i })["data"] 
    render json: connections.collect{|n| {"source" => n[0], "source_data" => {:screen_name => n[1], 
                                                                              :image_url => n[2]},
                                          "target" => n[3], "target_data" => {:screen_name => n[4], 
                                                                             :image_url => n[5]}} }.to_json    

  end
  
end
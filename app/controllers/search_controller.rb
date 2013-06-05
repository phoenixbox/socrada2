class SearchController < ApplicationController
  respond_to :json

  def screen_names    
    cypher = "START me=node:users({query}) 
              RETURN ID(me), me.screen_name
              ORDER BY me.screen_name
              LIMIT 15"

   render json: $neo.execute_query(cypher, {:query => "screen_name:*#{params[:term]}* OR name:*#{params[:term]}*" })["data"].map{|x| { label: x[1], value: x[0]}}.to_json   

  end
end




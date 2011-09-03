class ApiController < ApplicationController
  def friends
    json = []
    # id, fb_id, name
    for friend in User.find_by_fb_id(params[:fb_id]).friends
      json << { 'id' => friend.id, 'name' => friend.name}
    end
    
    render :json => json
  end
end
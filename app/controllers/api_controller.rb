class ApiController < ApplicationController
  def friends
    json = []
    # id, fb_id, name
    for friend in User.find_by_fb_id(params[:fb_id]).friends
      json << { 'id' => friend.id, 'name' => friend.name}
    end
    
    render :json => json
  end
  
  def register
    if user = User.find_by_fb_id(params["fb_id"])
      user.fb_token = params["token"]
      user.email = params['email']
    else # Create a user with a stub password. 
      user = User.create(:email => params["email"], :password => Devise.friendly_token[0,20], :name => params['name'], :fb_id => params['fb_id'], :fb_token => params['token'])
    end
    
    user.update_friends
    user.save
    
    render :json => { :status => "ok" }
  end
end
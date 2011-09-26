class SharedsController < ApplicationController
  protect_from_forgery
  before_filter :authenticate_user!
  
  def friends
    json = []
    for friend in current_user.friends.where('name ILIKE ?', "%#{params[:q]}%")
      json << { 'id' => friend.id, 'name' => friend.name }
    end
    render :json => json
  end
  
  def index
  end
  
  def new
    @shared = Shared.new
  end
  
  def create
  end
  
  def show
  end
  
  def edit
  end
  
  def update
  end
  
  def destroy
  end
end

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :image_url
  
  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    p access_token
    
    image_url = access_token['user_info']['image']
    data = access_token['extra']['user_hash']
    p image_url
    p data['name']
    if user = User.find_by_email(data["email"])
      user
    else # Create a user with a stub password. 
      User.create(:email => data["email"], :password => Devise.friendly_token[0,20], :image_url => image_url, :name => data['name']) 
    end
  end
  
  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["user_hash"]
        user.email = data["email"]
      end
    end
  end
end

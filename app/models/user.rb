class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  has_many :friendships
  has_many :friends, :through => :friendships
  has_many :inverse_friendships, :class_name => "Friendship", :foreign_key => "friend_id"
  has_many :inverse_friends, :through => :inverse_friendships, :source => :user

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :image_url, :fb_token, :fb_id
  
  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    p access_token
    
    image_url = access_token['user_info']['image']
    data = access_token['extra']['user_hash']

    if user = User.find_by_fb_id(data["id"])
      user.fb_token = access_token['credentials']['token']
      user.email = data['email']
      user.update_friends
      user.save

      user
    else # Create a user with a stub password. 
      user = User.create(:email => data["email"], :password => Devise.friendly_token[0,20], :name => data['name'], :fb_id => data['id'], :fb_token => access_token['credentials']['token'])
      user.update_friends
      user.save
      user
    end
  end
  
  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["user_hash"]
        user.email = data["email"]
      end
    end
  end
  
  def update_friends
    user = FbGraph::User.me(self.fb_token)

    beginning = Time.now
    user = user.fetch
    puts "Fetching friends from Graph API took #{Time.now - beginning} seconds"
    
    for friend in user.friends
      u = User.find_by_fb_id(friend.identifier)
      if u
      else
        u = User.create(:email => "#{friend.identifier}@facebook.com", :password => Devise.friendly_token[0,20], :name => friend.name, :fb_id => friend.identifier)
      end
      
      unless Friendship.where(:user_id => self.id, :friend_id => u.id).exists?
        self.friendships.build(:friend_id => u.id)
      end
    end
  end
  
  def profile_pic_url
    "http://graph.facebook.com/#{self.fb_id}/picture?type=square"
  end
end

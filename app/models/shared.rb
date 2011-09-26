class Shared < ActiveRecord::Base
  has_many :transfers
  
  def sharers=(ids)
    p ids
  end
  
  def sharers
    ""
  end
end
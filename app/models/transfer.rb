class Transfer < ActiveRecord::Base
  belongs_to :creditor, :class_name => 'User'
  belongs_to :debtor, :class_name => 'User'
  belongs_to :creator, :class_name => 'User'
  
  validates :amount, :numericality => { :greater_than_or_equal_to => 0 }
  
  validate :creator_must_be_debtor_or_creditor
  
  def creator_must_be_debtor_or_creditor
    if debtor_id != creator_id and creditor_id != creator_id
      errors.add(:creator_id, "cannot create debts for others!")
    end
  end
end
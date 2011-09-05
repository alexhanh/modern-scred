class ApiController < ApplicationController
  before_filter :authenticate, :except => [:register]
  
  def authenticate
    # todo: key should be a true auth key and probably integrate with devise
    @current_user = User.find(params[:key])
    
    redirect_to failed_url if @current_user.nil?
  end
  
  def failed_url
    render :json => {:status => "auth_failed"}
  end
  
  def friends
    json = []
    for friend in @current_user.friends
      json << { 'id' => friend.id, 'name' => friend.name, 'fb_id' => friend.fb_id }
    end
    
    render :json => json
  end
  
  def register
    if params["email"].nil? || params["fb_id"].nil? || params["name"].nil? || params["token"].nil?
      render :json => {:status => "not ok", :message => "parameters missing"}
      return
    end
    
    if user = User.find_by_fb_id(params["fb_id"])
      user.fb_token = params["token"]
      user.email = params['email']
    else
      user = User.create(:email => params["email"], :password => Devise.friendly_token[0,20], :name => params['name'], :fb_id => params['fb_id'], :fb_token => params['token'])
    end
    
    user.update_friends
    user.save
    
    render :json => { :status => "ok", :key => user.id }
  end
  
  def transfers
    json = []
    for transfer in Transfer.select("DISTINCT(transfers.*)").where("transfers.creditor_id = ? OR transfers.debtor_id = ?", @current_user.id, @current_user.id)
      json << 
        {
          :id => transfer.id,
          :creator_id => transfer.creator_id,
          :debtor => { :id => transfer.debtor_id, :name => transfer.debtor.name },
          :creditor => { :id => transfer.creditor_id, :name => transfer.creditor.name },
          :amount => transfer.amount,
          :message => transfer.message
        }
    end
    render :json => json
  end
  
  def add_transfer
    transfer = Transfer.new()
    transfer.debtor_id = params[:debtor_id]
    transfer.creator_id = params[:creator_id]
    transfer.creditor_id = params[:creditor_id]
    transfer.amount = params[:amount]
    transfer.message = params[:message]
    transfer.creator = @current_user
    
    if transfer.save()
      render :json => {:status => 'ok' }
    else
      render :json => {:status => 'error', :msg => 'error while saving transfer' }
    end
  end
  
  def balance
    total = Transfer.where(:creditor_id => @current_user.id).sum("amount") - Transfer.where(:debtor_id => @current_user.id).sum("amount")
    
    # name ovat kayttajalle miinusta
    losses = Transfer.find_by_sql(["SELECT SUM(amount), creditor_id FROM transfers WHERE debtor_id = ? GROUP BY creditor_id", @current_user.id])
    
    # tuloa
    gains = Transfer.find_by_sql(["SELECT SUM(amount), debtor_id FROM transfers WHERE creditor_id = ? GROUP BY debtor_id", @current_user.id])
    
    balances = {}
    for f in losses
      # balances[f['creditor_id']] = -1*f['sum'].to_f
      friend = User.find(f['creditor_id'])
      balances[f['creditor_id']] = { :name => friend.name, :fb_id => friend.fb_id, :sum => -1*f['sum'].to_f }
      
      # balances << { :friend_id => f['creditor_id'], :sum => -1*f['sum'].to_f }
    end
    
    for f in gains
      if balances.has_key?(f['debtor_id'])
        balances[f['debtor_id']][:sum] += f['sum'].to_f
      else
        friend = User.find(f['debtor_id'])
        balances[f['debtor_id']] = { :name => friend.name, :fb_id => friend.fb_id, :sum => f['sum'].to_f }
      end
    end
    
    render :json => { :status => 'ok', :total => total, :balances => balances }
  end
end
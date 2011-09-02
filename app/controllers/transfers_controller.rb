class TransfersController < ApplicationController
  protect_from_forgery
  before_filter :authenticate_user!
  
  def index
    @transfers = Transfer.select("DISTINCT(transfers.*)").where("transfers.creditor_id = ? OR transfers.debtor_id = ?", current_user.id, current_user.id)
    
    @balance = Transfer.where(:creditor_id => current_user.id).sum("amount") - Transfer.where(:debtor_id => current_user.id).sum("amount")
  end
  
  def new
    @transfer = nil
    if params[:type] == "receive"
      @transfer = Transfer.new(:creditor => current_user)
    else
      @transfer = Transfer.new(:debtor => current_user)
    end
    
    render :action => params[:type]
  end
  
  def create
    @transfer = Transfer.new(params[:transfer])
    @transfer.creator = current_user
    if @transfer.save
      redirect_to transfers_url, :notice => "succesfully created"
    else
      redirect_to transfers_url, :notice => "something went wrong"
    end
  end
  
  def show
  end
  
  def edit
  end
  
  def update
  end
  
  def destroy
    transfer = Transfer.find(params[:id])
    unless transfer.creator_id == current_user.id
      redirect_to transfers_url, :notice => "you don't have a permission to remove this transaction"
      return
    end
    
    transfer.destroy
    redirect_to transfers_url, :notice => "succesfully removed"
  end
end

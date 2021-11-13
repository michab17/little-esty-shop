class MerchantDiscountsController < ApplicationController
  def index
    @merchant = Merchant.find(params[:merchant_id])
  end
  
  def new
    @merchant = Merchant.find(params[:merchant_id])
  end
  
  def create
    merchant = Merchant.find(params[:merchant_id])
    merchant.discounts.create!(discount_params)
    redirect_to merchant_discounts_path(merchant)
  end

  private

  def discount_params
    params.permit(:merchant_id, :percentage, :quantity)
  end
end
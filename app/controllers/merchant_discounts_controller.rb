class MerchantDiscountsController < ApplicationController
  def index
    @merchant = Merchant.find(params[:merchant_id])
  end
  
  def show
    @merchant = Merchant.find(params[:merchant_id])
  end
  
  def edit
    @merchant = Merchant.find(params[:merchant_id])
    @discount = Discount.find(params[:id])
  end
  
  def update
    merchant = Merchant.find(params[:merchant_id])
    discount = Discount.find(params[:id])
    discount = Discount.find(params[:id])
    discount.update(discount_params)
    redirect_to merchant_discount_path(merchant, discount)
  end
  
  def new
    @merchant = Merchant.find(params[:merchant_id])
  end
  
  def create
    merchant = Merchant.find(params[:merchant_id])
    if discount_params[:percentage].to_f >= 1
      redirect_to new_merchant_discount_path(merchant), notice: 'Perchantage must be entered as a decimal value less than one'
    else
      merchant.discounts.create!(discount_params)
      redirect_to merchant_discounts_path(merchant)
    end
  end

  def destroy
    merchant = Merchant.find(params[:merchant_id])
    discount = Discount.find(params[:id])
    discount.destroy
    redirect_to merchant_discounts_path(merchant)
  end

  private

  def discount_params
    params.permit(:merchant_id, :percentage, :quantity)
  end
end
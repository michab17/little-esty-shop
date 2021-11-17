class Invoice < ApplicationRecord
  belongs_to :customer
  has_many :transactions
  has_many :invoice_items

  enum status: [ "cancelled", "in progress", "completed" ]

  def self.pending_invoices
    joins(:invoice_items).where.not(invoice_items: {status: 'shipped'}).order(:created_at).uniq
  end
  
  def total_revenue
    invoice_items.sum("unit_price * quantity")
  end
  
  def merchants_total_revenue(merchant)
    invoice_items.joins(item: :merchant)
    .where("merchants.id = #{merchant.id}")
    .sum("invoice_items.unit_price * invoice_items.quantity")
  end
  
  def discounted_revenue_table
    invoice_items.joins(item: :merchant)
    .select("invoice_items.unit_price AS ii_unit_price,
      invoice_items.quantity AS ii_quantity,
      invoice_items.item_id")
    end
    
  def ii_discount_calculation(invoice_item)
    ((invoice_item.ii_unit_price - (invoice_item.ii_unit_price * (invoice_item
      .item.merchant.find_discount(invoice_item.item.merchant.quantity_array
      .find { |quantity| quantity <= invoice_item.ii_quantity })
      .percentage))) * invoice_item.ii_quantity)
  end

  def merchant_discount_calculation(merchant)
    ((merchant.ii_unit_price - (merchant.ii_unit_price * (merchant
      .find_discount(merchant.quantity_array
      .find { |quantity| quantity <= merchant.ii_quantity })
      .percentage))) * merchant.ii_quantity)
  end

  def nondiscounted_revenue(instance)
    (instance.ii_unit_price * instance.ii_quantity)
  end
  
  def discounted_revenue
    revenue = 0
    discounted_revenue_table.each do |ii|
      if ii.item.merchant.quantity_array.find { |quantity| quantity <= ii.ii_quantity } != nil
        revenue += ii_discount_calculation(ii)
      else 
        revenue += nondiscounted_revenue(ii)
      end
    end
    revenue
  end

  def merchants_discounted_revenue(merchant)
    revenue = 0
    Merchant.merchant_discount_table(merchant).each do |merchant|
      if merchant.quantity_array.find { |quantity| quantity <= merchant.ii_quantity } != nil
        revenue += merchant_discount_calculation(merchant)
      else 
        revenue += nondiscounted_revenue(merchant)
      end
    end
    revenue
  end
end
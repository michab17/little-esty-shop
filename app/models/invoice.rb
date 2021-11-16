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

  def discounted_revenue
    revenue = 0
    discounted_revenue_table.each do |ii|
      if ii.item.merchant.quantity_array.find { |quantity| quantity <= ii.ii_quantity } != nil
        revenue += ii_discount_calculation(ii)
      else 
        revenue += nondiscount_calculation(ii)
      end
    end
    revenue
  end

  def nondiscount_calculation(instance)
    (instance.ii_unit_price * instance.ii_quantity)
  end

  def ii_discount_calculation(instance)
    ((instance.ii_unit_price - (instance.ii_unit_price * (instance
      .item.merchant.find_discount(instance.item.merchant.quantity_array
      .find { |quantity| quantity <= instance.ii_quantity })
      .percentage))) * instance.ii_quantity)
  end

  def merchant_discount_calculation(instance)
    ((instance.ii_unit_price - (instance.ii_unit_price * (instance
      .find_discount(instance.quantity_array
      .find { |quantity| quantity <= instance.ii_quantity })
      .percentage))) * instance.ii_quantity)
  end

  def merchants_discounted_revenue(merchant)
    revenue = 0
    Merchant.merchant_discount_table(merchant).each do |merchant|
      if merchant.quantity_array.find { |quantity| quantity <= merchant.ii_quantity } != nil
        revenue += merchant_discount_calculation(merchant)
      else 
        revenue += nondiscount_calculation(merchant)
      end
    end
    revenue
  end
end

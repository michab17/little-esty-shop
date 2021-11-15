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

  def discounted_revenue
    test = invoice_items.joins(item: :merchant)
    revenue = 0
    test.each do |ii|
      if ii.item.merchant.quantity_array.find { |x| x <= ii.quantity } != nil
        revenue += ((ii.unit_price - (ii.unit_price * (ii.item.merchant.find_discount(ii.item.merchant.quantity_array.find { |x| x <= ii.quantity }).percentage))) * ii.quantity)
      else 
        revenue += (ii.unit_price * ii.quantity)
      end
    end
    revenue
  end

  def merchants_discounted_revenue(merchant)
    test = Merchant.joins(items: {invoice_items: :invoice})
            .where("merchants.id = #{merchant.id}")
            .select('invoice_items.quantity AS iiq, invoice_items.unit_price AS iiup, merchants.*')
    revenue = 0
    test.each do |merchant|
      if merchant.quantity_array.find { |x| x <= merchant.iiq } != nil
        revenue += ((merchant.iiup - (merchant.iiup * (merchant.find_discount(merchant.quantity_array.find { |x| x <= merchant.iiq }).percentage))) * merchant.iiq)
      else 
        revenue += (merchant.iiup * merchant.iiq)
      end
    end
    revenue
  end
end

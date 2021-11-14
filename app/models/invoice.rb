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

  #what if i get the total revenue of each invoice item and then
  #multiply that by the percentage, if quantity is enough
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
end

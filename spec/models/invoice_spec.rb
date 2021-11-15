require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe 'relationships' do
    it {should belong_to :customer}
    it {should have_many :transactions}
  end

  describe '::pending_invoices' do
    it 'returns an array of pending invoices' do
      merchant1 = Merchant.create!(name: 'Bob Burger')
      customer1 = Customer.create!(first_name: "Bob", last_name: "Dylan")
      invoice1 = Invoice.create!(customer_id: customer1.id, status: 'in progress')
      invoice2 = Invoice.create!(customer_id: customer1.id, status: 'completed')
      item1 = Item.create!(name: 'book', description: 'good book', unit_price: 12, merchant_id: merchant1.id)
      item2 = Item.create!(name: 'spatula', description: 'good spatula', unit_price: 8, merchant_id: merchant1.id)
      invoice_item1 = InvoiceItem.create!(item_id: item1.id, invoice_id: invoice1.id, quantity: 2, unit_price: 24, status: 'pending')
      invoice_item2 = InvoiceItem.create!(item_id: item2.id, invoice_id: invoice2.id, quantity: 2, unit_price: 16, status: 'shipped')


      expect(Invoice.pending_invoices).to eq([invoice1])
    end
  end

  describe '#total_revenue' do
    it 'can return the total revenue for an invoice' do
      merchant1 = Merchant.create!(name: 'Bob Burger')
      customer1 = Customer.create!(first_name: "Bob", last_name: "Dylan")
      invoice1 = Invoice.create!(customer_id: customer1.id, status: 'in progress')
      invoice2 = Invoice.create!(customer_id: customer1.id, status: 'completed')
      item1 = Item.create!(name: 'book', description: 'good book', unit_price: 12, merchant_id: merchant1.id)
      item2 = Item.create!(name: 'spatula', description: 'good spatula', unit_price: 8, merchant_id: merchant1.id)
      invoice_item1 = InvoiceItem.create!(item_id: item1.id, invoice_id: invoice1.id, quantity: 2, unit_price: 24, status: 'pending')
      invoice_item2 = InvoiceItem.create!(item_id: item2.id, invoice_id: invoice2.id, quantity: 2, unit_price: 16, status: 'shipped')

      expect(invoice1.total_revenue).to eq(48)
      expect(invoice2.total_revenue).to eq(32)
    end
  end

  describe '#merchants_total_revenue' do
    it 'returns the total revenue for a given merchant' do
      merchant1 = Merchant.create!(name: 'Bob Burger')
      merchant2 = Merchant.create!(name: 'Ansel Adams')
      customer1 = Customer.create!(first_name: "Bob", last_name: "Dylan")
      invoice = Invoice.create!(customer_id: customer1.id, status: 'in progress')
      item1 = Item.create!(name: 'book', description: 'good book', unit_price: 12, merchant_id: merchant1.id)
      item2 = Item.create!(name: 'spatula', description: 'good spatula', unit_price: 8, merchant_id: merchant1.id)
      item3 = Item.create!(name: 'item', description: 'item', unit_price: 50, merchant_id: merchant2.id)
      invoice_item1 = InvoiceItem.create!(item_id: item1.id, invoice_id: invoice.id, quantity: 2, unit_price: 24, status: 'pending')
      invoice_item2 = InvoiceItem.create!(item_id: item2.id, invoice_id: invoice.id, quantity: 2, unit_price: 16, status: 'shipped')
      invoice_item3 = InvoiceItem.create!(item_id: item3.id, invoice_id: invoice.id, quantity: 2, unit_price: 50, status: 'shipped')
      
      expect(invoice.merchants_total_revenue(merchant1)).to eq(80)
      expect(invoice.merchants_total_revenue(merchant2)).to eq(100)
    end
  end

  describe '#discounted_revenue' do
    it 'returns the total revenue including discounts' do
      merchant = Merchant.create!(name: 'Max Holloway')
      discount = merchant.discounts.create!(percentage: 0.20, quantity: 2)
      customer = Customer.create!(first_name: "Grandpa", last_name: "Steve")
      invoice = Invoice.create!(customer_id: customer.id, status: 'in progress')
      item1 = Item.create!(name: 'book', description: 'good book', unit_price: 12, merchant_id: merchant.id)
      item2 = Item.create!(name: 'spatula', description: 'good spatula', unit_price: 8, merchant_id: merchant.id)
      invoice_item1 = InvoiceItem.create!(item_id: item1.id, invoice_id: invoice.id, quantity: 2, unit_price: 100, status: 'pending')
      invoice_item2 = InvoiceItem.create!(item_id: item2.id, invoice_id: invoice.id, quantity: 1, unit_price: 20, status: 'shipped')

      expect(invoice.discounted_revenue).to eq(180.0)
    end

    it 'should not discount items if the quantity threshold is not met' do
      merchant = Merchant.create!(name: 'Max Holloway')
      discount = merchant.discounts.create!(percentage: 0.20, quantity: 3)
      customer = Customer.create!(first_name: "Grandpa", last_name: "Steve")
      invoice = Invoice.create!(customer_id: customer.id, status: 'in progress')
      item1 = Item.create!(name: 'book', description: 'good book', unit_price: 12, merchant_id: merchant.id)
      item2 = Item.create!(name: 'spatula', description: 'good spatula', unit_price: 8, merchant_id: merchant.id)
      invoice_item1 = InvoiceItem.create!(item_id: item1.id, invoice_id: invoice.id, quantity: 2, unit_price: 100, status: 'pending')
      invoice_item2 = InvoiceItem.create!(item_id: item2.id, invoice_id: invoice.id, quantity: 1, unit_price: 20, status: 'shipped')

      expect(invoice.discounted_revenue).to eq(invoice.total_revenue)
    end

    it 'should discount multiple items if the merchant has multiple discounts and the items meet the quantity threshold' do
      merchant = Merchant.create!(name: 'Max Holloway')
      discount1 = merchant.discounts.create!(percentage: 0.20, quantity: 3)
      discount2 = merchant.discounts.create!(percentage: 0.10, quantity: 2)
      customer = Customer.create!(first_name: "Grandpa", last_name: "Steve")
      invoice = Invoice.create!(customer_id: customer.id, status: 'in progress')
      item1 = Item.create!(name: 'book', description: 'good book', unit_price: 12, merchant_id: merchant.id)
      item2 = Item.create!(name: 'spatula', description: 'good spatula', unit_price: 8, merchant_id: merchant.id)
      invoice_item1 = InvoiceItem.create!(item_id: item1.id, invoice_id: invoice.id, quantity: 3, unit_price: 100, status: 'pending')
      invoice_item2 = InvoiceItem.create!(item_id: item2.id, invoice_id: invoice.id, quantity: 2, unit_price: 20, status: 'shipped')
      # invoice_item1 should be discounted 20%
      # invoice_item2 should be discounted 10%
      # invoice_item1 should be 240
      # invoice_item2 should be 36
      expect(invoice.discounted_revenue).to eq(276)
    end

    it 'should apply only the highest percentage discount' do
      merchant = Merchant.create!(name: 'Max Holloway')
      discount1 = merchant.discounts.create!(percentage: 0.20, quantity: 2)
      discount2 = merchant.discounts.create!(percentage: 0.10, quantity: 3)
      customer = Customer.create!(first_name: "Grandpa", last_name: "Steve")
      invoice = Invoice.create!(customer_id: customer.id, status: 'in progress')
      item1 = Item.create!(name: 'book', description: 'good book', unit_price: 12, merchant_id: merchant.id)
      item2 = Item.create!(name: 'spatula', description: 'good spatula', unit_price: 8, merchant_id: merchant.id)
      invoice_item1 = InvoiceItem.create!(item_id: item1.id, invoice_id: invoice.id, quantity: 3, unit_price: 100, status: 'pending')
      invoice_item2 = InvoiceItem.create!(item_id: item2.id, invoice_id: invoice.id, quantity: 2, unit_price: 20, status: 'shipped')
      # invoice_item1 should be discounted 20%
      # invoice_item2 should be discounted 20%
      # invoice_item1 should be 240
      # invoice_item2 should be 32
      expect(invoice.discounted_revenue).to eq(272)
    end

    it 'discounts from one merchant should not affect another merchants items' do
      merchant = Merchant.create!(name: 'Max Holloway')
      merchant2 = Merchant.create!(name: 'merchant')
      discount1 = merchant.discounts.create!(percentage: 0.20, quantity: 2)
      discount2 = merchant.discounts.create!(percentage: 0.10, quantity: 3)
      customer = Customer.create!(first_name: "Grandpa", last_name: "Steve")
      invoice = Invoice.create!(customer_id: customer.id, status: 'in progress')
      item1 = Item.create!(name: 'book', description: 'good book', unit_price: 12, merchant_id: merchant.id)
      item2 = Item.create!(name: 'spatula', description: 'good spatula', unit_price: 8, merchant_id: merchant.id)
      item3 = Item.create!(name: 'item', description: 'item', unit_price: 8, merchant_id: merchant2.id)
      invoice_item1 = InvoiceItem.create!(item_id: item1.id, invoice_id: invoice.id, quantity: 3, unit_price: 100, status: 'pending')
      invoice_item2 = InvoiceItem.create!(item_id: item2.id, invoice_id: invoice.id, quantity: 2, unit_price: 20, status: 'shipped')
      invoice_item3 = InvoiceItem.create!(item_id: item3.id, invoice_id: invoice.id, quantity: 1, unit_price: 20, status: 'shipped')
      # invoice_item1 should be discounted 20%
      # invoice_item2 should be discounted 20%
      # invoice_item3 should not be discounted
      # invoice_item1 should be 240
      # invoice_item2 should be 32
      # invoice_item3 should be 20
      expect(invoice.discounted_revenue).to eq(292)
    end
  end

  describe '#merchants_discounted_revenue' do
    it 'only returns a given merchants discounted revenue' do
      merchant = Merchant.create!(name: 'Max Holloway')
      merchant2 = Merchant.create!(name: 'merchant')
      discount1 = merchant.discounts.create!(percentage: 0.10, quantity: 2)
      discount2 = merchant.discounts.create!(percentage: 0.20, quantity: 3)
      customer = Customer.create!(first_name: "Grandpa", last_name: "Steve")
      invoice = Invoice.create!(customer_id: customer.id, status: 'in progress')
      item1 = Item.create!(name: 'book', description: 'good book', unit_price: 12, merchant_id: merchant.id)
      item2 = Item.create!(name: 'spatula', description: 'good spatula', unit_price: 8, merchant_id: merchant.id)
      item3 = Item.create!(name: 'item', description: 'item', unit_price: 8, merchant_id: merchant2.id)
      invoice_item1 = InvoiceItem.create!(item_id: item1.id, invoice_id: invoice.id, quantity: 3, unit_price: 100, status: 'pending')
      invoice_item2 = InvoiceItem.create!(item_id: item2.id, invoice_id: invoice.id, quantity: 2, unit_price: 20, status: 'shipped')
      invoice_item3 = InvoiceItem.create!(item_id: item3.id, invoice_id: invoice.id, quantity: 1, unit_price: 20, status: 'shipped')
      # invoice_item1 should be 240
      # invoice_item2 should be 36
      expect(invoice.merchants_discounted_revenue(merchant)).to eq(276)
    end

    it 'returns the standard revenue of no discounts can be used' do
      merchant = Merchant.create!(name: 'Max Holloway')
      merchant2 = Merchant.create!(name: 'merchant')
      discount1 = merchant.discounts.create!(percentage: 0.10, quantity: 20)
      discount2 = merchant.discounts.create!(percentage: 0.20, quantity: 30)
      customer = Customer.create!(first_name: "Grandpa", last_name: "Steve")
      invoice = Invoice.create!(customer_id: customer.id, status: 'in progress')
      item1 = Item.create!(name: 'book', description: 'good book', unit_price: 12, merchant_id: merchant.id)
      item2 = Item.create!(name: 'spatula', description: 'good spatula', unit_price: 8, merchant_id: merchant.id)
      item3 = Item.create!(name: 'item', description: 'item', unit_price: 8, merchant_id: merchant2.id)
      invoice_item1 = InvoiceItem.create!(item_id: item1.id, invoice_id: invoice.id, quantity: 3, unit_price: 100, status: 'pending')
      invoice_item2 = InvoiceItem.create!(item_id: item2.id, invoice_id: invoice.id, quantity: 2, unit_price: 20, status: 'shipped')
      invoice_item3 = InvoiceItem.create!(item_id: item3.id, invoice_id: invoice.id, quantity: 1, unit_price: 20, status: 'shipped')
      # invoice_item1 should be 240
      # invoice_item2 should be 36
      expect(invoice.merchants_discounted_revenue(merchant)).to eq(340)
    end
  end
end

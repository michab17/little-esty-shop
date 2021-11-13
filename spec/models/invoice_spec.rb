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

      expect(invoice.discounted_revenue).to eq('$1.80')
    end
  end
end

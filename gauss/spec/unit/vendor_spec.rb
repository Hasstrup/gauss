# frozen_string_literal: true

require 'gauss/vendor'
require 'gauss/messages'

RSpec.describe Gauss::Vendor do
  let(:products_path) { File.expand_path('spec/fixtures/files/products.csv') }
  let(:changes_path) { File.expand_path('spec/fixtures/files/changes.csv') }
  let(:vendor) { described_class.new(products_path: products_path, changes_path: changes_path) }

  describe '#fetch_product' do
    before { vendor.reload }
    context 'when the product exists & the quantity is right' do
      it 'returns the price for the product (which is a product of amount * quantity)' do
        message = vendor.fetch_product(name: 'KitKat', quantity: 3)
        aggregate_failures do
          expect(vendor.context.success).to eq(true)
          expect(message).to include('That would cost you £0.6')
        end
      end
    end

    context 'when product does not exist' do
      it 'returns a record not found message' do
        message = vendor.fetch_product(name: 'Non existent product', quantity: 1)
        aggregate_failures do
          expect(vendor.context.success).to eq(false)
          expect(message).to include("Sorry there's no record matching that input")
        end
      end
    end

    context 'when the quantity specified is greater than the quantity available' do
      it 'returns the corresponding error message' do
        message = vendor.fetch_product(name: 'KitKat', quantity: 10)
        aggregate_failures do
          expect(vendor.context.success).to eq(false)
          expect(message).to include('I only have 5 left')
        end
      end
    end
  end

  describe '#process_transaction' do
    let(:expected_changes) do
      [{ count: 4, amount: '2£' }, { count: 1, amount: '1£' }, { count: 2, amount: '20p' }]
    end
    before { vendor.reload }

    context 'with a product set' do
      it 'returns the change for the amount specified' do
        vendor.fetch_product(name: 'KitKat', quantity: 3)
        vendor.process_transaction(amount: '10.00')
        aggregate_failures do
          expect(vendor.context.success).to eq(true)
          expect(vendor.context.payload).to match_array(expected_changes)
        end
      end
    end

    context 'without a product set' do
      it 'sends a no product message' do
        message = vendor.process_transaction(amount: '10.00')
        aggregate_failures do
          expect(vendor.context.success).to eq(false)
          expect(message).to eq(Gauss::Messages::NO_PRODUCT)
        end
      end
    end
  end

  describe 'reload' do
    context 'with valid csvs' do
      it 'loads records to the store and returns a success message' do
        expect(vendor.reload).to eq(Gauss::Messages::LOAD_SUCCESS)
      end
    end

    context 'with errored csvs' do
      let(:error_path) { File.expand_path('spec/fixtures/files/errored_products.csv') }
      let(:vendor_2) { described_class.new(products_path: error_path, changes_path: changes_path) }

      it 'fails to upload' do
        expect(vendor_2.reload).to include('gauss::products failed, errors:')
      end
    end
  end

  describe '#inventory' do
    before { vendor.reload }
    it 'returns the current items in the store' do
      expect(vendor.inventory).not_to be_empty
    end
  end
end

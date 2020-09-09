# frozen_string_literal: true

require 'spec_helper'
require 'gauss/messages'
require 'gauss/service/transaction'
require 'gauss/context'
require 'gauss/product'
require 'gauss/vendor'

RSpec.describe Gauss::Service::Transaction do
  let(:context) { Gauss::Context.new }
  let(:record) { Gauss::Product.new(*{ name: 'KitKat', description: '', amount: '0.2' }) }
  let(:store) { Gauss::Store.new }
  let(:amount) { '10.0' }
  let(:quantity) { 3 }
  let(:service) do
    described_class.new(amount: amount,
                        store: store,
                        context: context,
                        quantity: quantity,
                        record: record)
  end

  let(:products) do
    [{ name: 'CocaCola', description: 'A drink', amount: 12.0, count: 10 },
     { name: 'KitKat', description: 'Chocolate', amount: 0.2, count: 2.0 },
     { name: 'Jameson', description: 'Some alcohol', amount: 5.0, count: 50 },
     { name: 'Dunhill', description: 'Nothing really', amount: 5.0, count: 10 }]
  end

  let(:changes) do
    [{ amount: '1p', count: 50 },
     { amount: '2p', count: 10 },
     { amount: '5p', count: 10 },
     { amount: '10p', count: 10 },
     { amount: '20p', count: 10 },
     { amount: '50p', count: 10 },
     { amount: '1£', count: 10 },
     { amount: '2£', count: 10 }]
  end

  before do
    store.load(key: Gauss::Product.store_key, entries: products)
    store.load(key: Gauss::Change.store_key, entries: changes)
  end

  describe '#perform' do
    context 'with valid input' do
      let(:expected_changes) do
        [{ count: 4, amount: '2£' }, { count: 1, amount: '1£' }, { count: 2, amount: '20p' }]
      end
      it 'returns the change for the amount specified' do
        service.perform
        aggregate_failures do
          expect(context.success).to eq(true)
          expect(context.payload).to match_array(expected_changes)
        end
      end

      context 'when changes have been calculated' do
        let(:expected_products_args) do
          { attribute: :name,
            changes: { amount: 0.2, count: -1.0, description: 'Chocolate', name: 'KitKat' },
            key: 'KitKat',
            store_key: 'gauss::products' }
        end

        let(:expected_changes_args) do
          { attribute: :amount,
            changes: { amount: '2£', count: 6 },
            key: '2£',
            store_key: 'gauss::changes' }
        end

        before { allow(store).to receive(:update) }

        it 'updates the count of the products' do
          service.perform
          aggregate_failures do
            expect(context.success).to eq(true)
            expect(store).to have_received(:update).with(expected_products_args)
          end
        end

        it 'updates the count of the changes' do
          service.perform
          aggregate_failures do
            expect(context.success).to eq(true)
            expect(store).to have_received(:update).with(expected_changes_args)
          end
        end
      end
    end

    context 'with invalid input' do
      context 'when amount is insufficient' do
        let(:amount) { '0.5' }

        it 'returns an insufficient funds message' do
          service.perform
          aggregate_failures do
            expect(context.success).to eq(false)
            expect(context.message).to eq(Gauss::Messages::INSUFFICIENT_FUNDS)
          end
        end
      end

      context 'when amount is too large (it cannot be changed)' do
        let(:amount) { '2000.00' }

        it 'returns an insufficient funds message' do
          service.perform
          aggregate_failures do
            expect(context.message).to eq(Gauss::Messages::NOT_CHANGEABLE)
            expect(context.success).to eq(false)
          end
        end
      end
    end
  end
end

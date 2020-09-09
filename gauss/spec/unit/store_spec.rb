# frozen_string_literal: true

require 'gauss/store'
require 'gauss/error'

RSpec.describe Gauss::Store do
  let(:key) { 'test_key' }
  let(:data) { [{ name: 'Test Product', description: 'Test Description' }] }

  describe '#load' do
    it 'loads the entries with the matching key' do
      store = described_class.new
      store.load(key: key, entries: data)
      expect(store.store.dig(key)).to eq(data)
    end
  end

  describe '#add' do
    let(:entry) { { name: 'Test Product 2' } }

    it 'adds the entry to the existing store' do
      store = described_class.new
      store.add(key: key, entry: entry)
      expect(store.store.dig(key)).to include(entry)
    end
  end

  describe '#fetch' do
    let(:store) { described_class.new }

    context 'when record exists' do
      before do
        store.load(key: key, entries: data)
      end

      it 'returns the right record' do
        record = store.fetch(key: 'Test Product', store_key: key, attribute: :name)
        expect(record.dig(:description)).to eq('Test Description')
      end
    end

    context 'when record does not exist' do
      it 'raises a RecordNotFound error' do
        expect do
          store.fetch(key: 'test', store_key: 'no_store_key', attribute: :name)
        end.to raise_error(Gauss::StoreError::RecordNotFound)
      end
    end
  end

  describe 'update' do
    let(:store) { described_class.new }

    context 'when record exists' do
      before do
        store.load(key: key, entries: data)
      end

      it 'updates the right record' do
        store.update(key: 'Test Product',
                     store_key: key,
                     attribute: :name,
                     changes: { description: 'New Description' })
        record = store.fetch(key: 'Test Product', store_key: key, attribute: :name)
        expect(record.dig(:description)).to eq('New Description')
      end
    end
  end
end

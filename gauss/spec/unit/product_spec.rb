# frozen_string_literal: true

require 'gauss/product'

RSpec.describe Gauss::Product do
  let(:product) { described_class.new(*attributes) }
  let(:default_attributes) { { name: 'Test Product', description: 'Test description', amount: 0.2, count: 10 } }
  describe 'validations' do
    let(:attributes) { default_attributes }

    it 'is valid with the right attributes' do
      expect(product).to be_valid
    end

    context 'when attributes are invalid' do
      context 'with mismatched types' do
        let(:attributes) { default_attributes.merge(amount: 'string') }

        it 'is invalid' do
          aggregate_failures do
            expect(product).not_to be_valid
            expect(product.errors.dig(:amount)).to include('must be of type: Float')
          end
        end
      end

      context 'with invalid ranges' do
        let(:below_min_attributes) { default_attributes.merge(count: 0) }
        let(:above_max_attributes) { default_attributes.merge(amount: 450_00) }
        it 'is invalid' do
          product_1 = described_class.new(*below_min_attributes)
          product_2 = described_class.new(*above_max_attributes)

          aggregate_failures do
            expect(product_1).not_to be_valid
            expect(product_2).not_to be_valid
            expect(product_1.errors.dig(:count)).to include('Must be greater than or equal to: 1')
            expect(product_2.errors.dig(:amount)).to include('Must be less than or equal to: 400.0')
          end
        end
      end
    end
  end

  describe 'humanize' do
    let(:attributes) { { name: 'Test Product', description: 'Test description', amount: 0.2, count: 10 } }

    it "returns a hash of it's fields" do
      expect(product.humanize).to eq(attributes)
    end
  end

  describe 'Class methods' do
    describe '.store_key' do
      let(:attributes) { { name: 'Test Product', description: 'Test description', amount: 0.2, count: 10 } }

      it 'is the name of the pluralized name of class' do
        expect(product.class.store_key).to eq('gauss::products')
      end
    end
  end
end

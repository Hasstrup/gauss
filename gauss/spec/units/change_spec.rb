# frozen_string_literal: true

require 'spec_helper'
require 'gauss/change'

RSpec.describe Gauss::Change do
  let(:target_change) { described_class.new(*attributes) }
  describe 'Validations' do
    let(:attributes) { { count: 10, amount: '2p' } }
    it 'is valid with the right attributes' do
      expect(target_change).to be_valid
    end

    context 'when attributes are invalid' do
      context 'when amount is nil or count is nil' do
        let(:attributes) { { amount: nil, count: nil } }

        it 'is invalid' do
          expect(target_change).not_to be_valid
        end
      end

      context 'when either attribute is of the wrong type' do
        let(:attributes) { { count: 'wrong_type', amount: 10 } }

        it 'is invalid' do
          expect(target_change).not_to be_valid
        end
      end

      context 'when the amount is not in the permitted amounts' do
        let(:attributes) { { count: 10, amount: '100p' } }

        it 'is invalid' do
          expect(target_change).not_to be_valid
        end
      end
    end
  end

  describe 'humanize' do
    let(:attributes) { { amount: '10p', count: 5 } }
    it "returns a hash of it's fields" do
      expect(target_change.humanize).to eq(attributes)
    end
  end

  describe 'Class methods' do
    describe '.store_key' do
      let(:attributes) { { amount: '10p', count: 5 } }
      it 'is the name of the pluralized name of class' do
        expect(target_change.class.store_key).to eq('gauss::changes')
      end
    end
  end
end

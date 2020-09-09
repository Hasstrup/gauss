# frozen_string_literal: true

require 'gauss/context'

RSpec.describe Gauss::Context do
  let(:gauss_context) { described_class.new }

  describe '#fail!' do
    it 'adds the error to the error logs and returns a message' do
      error = StandardError.new('This is a test message')
      message = gauss_context.fail!(error: error)
      aggregate_failures do
        expect(gauss_context.success).to eq(false)
        expect(gauss_context.errors).to include(error)
        expect(message).to eq('This is a test message')
      end
    end
  end

  describe '#succeed' do
    it 'returns the message sent, clears errors and sets success' do
      response = gauss_context.succeed(message: 'This is a test message')
      aggregate_failures do
        expect(gauss_context.success).to eq(true)
        expect(gauss_context.errors).to be_empty
        expect(response).to eq('This is a test message')
      end
    end
  end

  describe '#payload!' do
    it 'sets the payload correctly' do
      gauss_context.payload!(payload: 'Test payload')
      aggregate_failures do
        expect(gauss_context.errors).to be_empty
        expect(gauss_context.payload).to eq('Test payload')
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'
require 'gauss/context'

RSpec.describe Gauss::Context do
  let(:gauss_context) { described_class.new }

  describe '#fail!' do
    it 'adds the error to the error logs and returns a message' do
      error = StandardError.new('This is a test message')
      message = gauss_context.fail!(error: error)
      aggregate_failures do
        exoect(gauss_context.success).to eq(false)
        expect(gauss_context.errors).to include(error)
        expect(message).to eq('This is a test message')
      end
    end
  end
end

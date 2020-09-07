# frozen_string_literal: true

module Gauss
  # Gauss::Change represents the change object
  class Change < Gauss::Model
    attr_reader :amount, :count
    ALLOWED_CHANGES = %w[1p 2p 5p 10p 20p 50p £1 £2].freeze
    validates :count, presence: true, type: Number
    validates :amount, presence: true, type: String, in: ALLOWED_CHANGES
  end
end

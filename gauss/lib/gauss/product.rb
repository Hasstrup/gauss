# frozen_string_literal: true

module Gauss
  # Gauss::Product represents the product object
  class Product < Gauss::Model
    attr_reader :name, :amount
    validates :name, type: String, presence: true
    validates :description, type: String, presence: true
    validates :amount, type: Float, presence: true, min: 0, max: 400.00
  end
end

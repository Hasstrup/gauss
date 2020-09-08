# frozen_string_literal: true

module Gauss
  # Gauss::Product represents the product object
  class Product < Gauss::Model
    attributes :name, :description, :amount, :count
    validates :name, type: String, presence: true
    validates :description, type: String, presence: true
    validates :amount, type: Float, presence: true, min: 0, max: 400.00
    validates :count, type: Integer, presence: true, min: 0
  end
end

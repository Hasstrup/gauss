# frozen_string_literal: true

module Gauss
  class Product < Gauss::Model
    attr_accessor :name, :amount
    validates :name, type: String, presence: true
    validates :description, type: String, presence: true
    validates :amount, type: Float, presence: true, min: 0, max: 100
  end
end

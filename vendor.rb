# frozen_string_literal: true

require 'gauss'

products_path = File.expand_path('products.csv')
changes_path = File.expand_path('changes.csv')
Gauss::Interactor.run(products_path: products_path, changes_path: changes_path)

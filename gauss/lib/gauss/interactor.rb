# frozen_string_literal: true
require 'gauss/messages'

module Gauss
  # Gauss::Interactor -
  class Interactor
    attr_reader :vendor
    def initialize(products_path:, changes_path:)
      vendor = Gauss::Vendor.new(products_path: products_path,
                                 changes_path: changes_path)
    end

    def self.run(products_path:, changes_path:)
      new(products_path: products_path, changes_path: changes_path).run
    end

    def run
      puts Gauss::Messages::WELCOME
      cmd = gets.chomp
      execute_cmd(cmd: cmd) if is_valid_cmd?(cmd)
    end

    private

    def is_valid_cmd?
      true
    end

    def execute_cmd(cmd:); end
  end
end

# frozen_string_literal: true

require 'gauss/messages'
require 'gauss/vendor'

module Gauss
  # Gauss::Interactor -
  class Interactor
    attr_reader :vendor

    def initialize(products_path:, changes_path:)
      @vendor = Gauss::Vendor.new(products_path: products_path,
                                  changes_path: changes_path)
    end

    def self.run(products_path:, changes_path:)
      new(products_path: products_path, changes_path: changes_path).run
    end

    def run(initial: true)
      puts Gauss::Messages::WELCOME if initial
      cmd = gets.chomp
      if valid_cmd?(cmd: cmd)
        execute_cmd(cmd: cmd)
      else
        puts Gauss::Messages::INVALID_CMD
      end

      run(initial: false)
    end

    def fetch_product(cmd:)
      exe = cmd.dup
      exe.slice!('Give me').chomp
      name, quantity = exe.split(',').map(&:strip)
      vendor.fetch_product(name: name, quantity: quantity)
    end

    def process_transaction(cmd:)
      amount = cmd.dup
      amount.slice!('Take').chomp
      vendor.process_transaction(amount: amount)
    end

    private

    def valid_cmd?(cmd:)
      cmds = Gauss::Commands::REQUESTS.values.flatten
      cmds.include?(cmd) || cmds.any? { |cmnd| cmd.start_with?(cmnd) }
    end

    def execute_cmd(cmd:)
      target_cmd = Gauss::Commands::REQUESTS.values.find do |cmnd|
        cmd.start_with?(cmnd.first)
      end
      puts send(Gauss::Commands::REQUESTS.key(target_cmd), cmd: cmd)
    end

    def help(_)
      run(initial: true)
    end

    def method_missing(method, *args)
      return vendor.send(method, *args) if vendor.respond_to?(method)

      super
    end
  end
end

# frozen_string_literal: true

module Gauss
  # Gauss::Messages - save all the cmds for gauss
  module Commands
    REQUESTS = {
      reload: ['Load'],
      help: ['Help'],
      fetch_product: ['Give me'],
      inventory: ['What do you have?']
    }.freeze
  end
  module Messages
    WELCOME = <<-STR
      Hi I'm Gauss, and here's how I can help you

      Help guide:
        - CMD: 'What do you have?' - I'll show you all the items in stock/and their prices
        - CMD: 'Give me '{{ name of product, quantity }}' - I'll tell you the price and subsequently ask you for the amount of money
        - CMD: 'Take {{ amount of money (2p, 14p, £1.2) }}' - I'll try to get the item for you if enough money is provided else ---\__(o_o)__/--
        - CMD: 'Help': I'll share this again
        - CMD: 'Load': I'll reset the records and sync with what's in the csv
        - CMD: 'Gauss Thanks': Alright ciao!

      What would you like to do?
    STR
    INVALID_CMD = <<-STR
     **Sorry I dont understand that command**
    STR
    LOAD_SUCCESS = <<-STR
      **Successfully loaded products and changes**
    STR
    RECORD_NOT_FOUND = <<-STR
      **Sorry there's no product matching that name**
    STR
    NO_PRODUCT = <<-STR
      Can not proceed withoutt selectting a procutt
    STR
    INSUFFICIENT_FUNDS = <<-STR
      ** Insufficient funds **
    STR
    NOT_CHANGEABLE = <<-STR
     **I don't have that much change, enter a lower denomination**
    STR
  end
end

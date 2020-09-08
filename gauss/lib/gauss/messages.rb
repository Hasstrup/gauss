# frozen_string_literal: true

module Gauss
  # Gauss::Messages - save all the cmds for gauss
  module Commands
    REQUESTS = {
      reload: ['Reload'],
      help: ['Help'],
      fetch_product: ['Give me']
    }.freeze
  end
  module Messages
    WELCOME = <<-STR
      Hi I'm Gauss, and here's how I can help you

      Help guide:
        - CMD: 'what do you have?' - I'll show you all the items in stock/and their prices
        - CMD: 'Give me '{{ name of product }}' - I'll tell you the price and subsequently ask you for the amount of money
        - CMD: 'Take {{ amount of money (2p, 14p, £1.2) }}' - I'll try to get the item for you if enough money is provided else ---\__(o_o)__/--
        - CMD: 'Help': I'll share this again
        - CMD: 'Reload': I'll reset the records and sync with what's in the csv
        - CMD: 'Gauss Thanks': Alright ciao!

      What would you like to do?
    STR

    INVALID_CMD = <<-STR
    Sorry I dont understand that command
    STR

    LOAD_SUCCESS = <<-STR
      Successfully loaded products and changes
    STR
  end
end

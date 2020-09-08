# frozen_string_literal: true

# frozen_string_literal

module Gauss
  # Gauss::Messages - save all the cmds for gauss
  module Messages
    WELCOME = <<-STR
      Hi I'm Gauss,
      Before you saw this message, I had loaded the products and changes in the
      products.csv & changes.csv files at the root folder, feel free to make changes
      and send "reload" so I can see your latest changes. If

      Help guide:
        - CMD: 'what do you have?' - I'll show you all the items in stock/and their prices
        - CMD: 'Give me '{{ name of product }}' - I'll tell you the price and subsequently ask you for the amount of money
        - CMD: 'Take {{ amount of money (2p, 14p, £1.2) }}' - I'll try to get the item for you if enough money is provided else ---\__(o_o)__/--
        - CMD: 'Help': I'll share this again
        - CMD: 'Reload': I'll reset the records and sync with what's in the csv
        - CMD: 'Gauss Thanks': Alright ciao!

      What would you like to do?
    STR
  end
end

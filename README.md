### GAUSS

Gauss is a pretty cool vending machine that runs on your terminal that has the following features

* Loading products & changes (from the CSV files at the root layer)
* Getting a product 
* Taking in some money for the product
* Giving you your change/ If there be a need ✅

##### Getting Started

* Download the code
* You will be needing to have bundler installed
* run `bundle install`
* To fire up gauss run `bundle exec vendor.rb`
* Pass in instructions in the console and watch it happen!

#### Registered Instructions

NB: Please follow verbatim (for now :) )

* Help - `shows the help guide`
* Load - `loads the products and changes into the store`
* What do you have? - `Gives you the list of products & the changes`
* Give me {{ product_name, quantity }} -
`Fetches the product, and lets you know how much that would cost, should nicely let you know if he can't find it`
* Take {{ money ( e.g 1.2£, 5.0) }} -
`After requesting an item, use this command to slot in cash, and receive change`


#### Specs 
Specs are right now written in the gem and can be run by: 
`cd gauss && rspec`

#### Dependencies
* Ruby
* Bundler


Feel free to contact me (hasstrup.ezekiel@gmail.com) if you run into any problems

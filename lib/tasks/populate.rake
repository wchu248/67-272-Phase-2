namespace :db do
  desc "Erase and fill database"
  # creating a rake task within db namespace called 'populate'
  # executing 'rake db:populate' will cause this script to run
  task :populate => :environment do
    # Need two gems to make this work: faker & populator
    # Docs at: http://populator.rubyforge.org/
    require 'populator'
    # Docs at: http://faker.rubyforge.org/rdoc/
    require 'faker'
    
    # clear any old data in the db
    [Item, ItemPrice, Purchase].each(&:delete_all)

    Item.populate 50 do |item|
        # get some fake data using the Faker gem
      item.name = Faker::Name.first_name
      item.description = Faker::Lorem.sentence
      item.category = %w[pieces boards clocks supplies]
      item.color = %w[green purple red blue teal yellow green/white blue/black red/yellow purple/pink]
      item.weight = Faker::Number.between(1, 20)
      item.inventory_level = Faker::Number.between(10, 100)
      item.reorder_level = Faker::Number.between(10, 30)
      item.active = [true, false]

        # add some item prices for each item
        ItemPrice.populate 4 do |item_price|
          start_dates = [Date.today, 1.week.ago.to_date, 2.weeks.ago.to_date, 3.weeks.ago.to_date]
          end_dates = [nil, Date.today, 1.week.ago.to_date, 2.weeks.ago.to_date]
          item_price.item_id = item.id
          item_price.price = Faker::Number.decimal(2)
          date_index = rand(4)
          item_price.start_date = start_dates[date_index]
          item_price.end_date = end_dates[date_index]
        end

        Purchase.populate 1..3 do |purchase|
          purchase.item_id = item.id
          purchase.quantity = Faker::Number.between(-2, 10)
          purchase.date = Faker::Date.between(3.weeks.ago.to_date, Date.today)
        end

    end

  end

end
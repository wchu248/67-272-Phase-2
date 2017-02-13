FactoryGirl.define do
  
  factory :item do
    name "Wooden Chess Pieces"
    description "A nice set of chess pieces made out of finished wood."
    category "pieces"
    color "tan/beige"
    weight 4.3
    inventory_level 50
    reorder_level 20
    active true
  end
  
  factory :item_price do
    price 15.99
    start_date Date.today
    end_date nil
    association :item
  end
  
  factory :purchase do
    quantity 2
    date 2.months.ago.to_date
    association :item
  end

end
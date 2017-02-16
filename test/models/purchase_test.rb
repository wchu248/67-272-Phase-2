require 'test_helper'

class PurchaseTest < ActiveSupport::TestCase

  # Relationship macros...
  should belong_to(:item)

  # Validation macros...
  should validate_presence_of(:item_id)
  should validate_presence_of(:quantity)
  should validate_presence_of(:date)
  # ASK PROF H... WHAT EXACTLY IS A NEGATIVE QUANTITY PURCHASE and about 0 quantity purchases
  should validate_inclusion_of(:item_id).in_array(Item.active.map {|i| i.id})

  # Validating quantity...
  should allow_value(1).for(:quantity)
  should allow_value(10).for(:quantity)
  should allow_value(-1).for(:quantity)
  should allow_value(-10).for(:quantity)
  #should allow_value(0).for(:quantity)

  #should_not allow_value(0).for(:quantity)
  should_not allow_value(1.1).for(:quantity)
  should_not allow_value(10.00).for(:quantity)
  should_not allow_value(-3.10).for(:quantity)
  should_not allow_value("hello").for(:quantity)

  # Validating date...
  should allow_value(Date.today).for(:date)
  should allow_value(3.weeks.ago.to_date).for(:date)

  should_not allow_value(1.day.from_now.to_date).for(:date)
  should_not allow_value(-0.01).for(:date)
  should_not allow_value(5).for(:date)
  should_not allow_value("hello").for(:date)

end

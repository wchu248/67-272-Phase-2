require 'test_helper'

class ItemPriceTest < ActiveSupport::TestCase

  # Relationship macros...
  should belong_to(:item)

  # Validation macros...
  should validate_presence_of(:item_id)
  should validate_presence_of(:price)
  should validate_presence_of(:start_date)

  should validate_numericality_of(:price).is_greater_than_or_equal_to(0)
  should validate_inclusion_of(:item_id).in_array(Item.active.map {|i| i.id})

  # Validating price...
  should allow_value(7).for(:price)
  should allow_value(5.12).for(:price)
  should allow_value(0.01).for(:price)

  should_not allow_value(0).for(:price)
  should_not allow_value(-1).for(:price)
  should_not allow_value(-3.10).for(:price)
  should_not allow_value("hello").for(:price)

  # Validating start_date...
  should allow_value(Date.today).for(:start_date)
  should allow_value(3.weeks.ago.to_date).for(:start_date)
  should allow_value(0.01).for(:start_date)

  should_not allow_value(1.day.from_now.to_date).for(:start_date)
  should_not allow_value(5).for(:start_date)
  should_not allow_value("hello").for(:start_date)

end

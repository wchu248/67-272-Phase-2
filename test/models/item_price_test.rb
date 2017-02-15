require 'test_helper'

class ItemPriceTest < ActiveSupport::TestCase

  # Relationship macros...
  should belong_to(:item)

  # Validation macros...
  should validate_presence_of(:item_id)
  should validate_presence_of(:price)
  should validate_presence_of(:start_date)

  should validate_numericality_of(:price).is_greater_than_or_equal_to(0)

end

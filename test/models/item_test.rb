require 'test_helper'

class ItemTest < ActiveSupport::TestCase

  # Relationship macros...
  should have_many(:item_prices)
  should have_many(:purchases)

  # Validation macros...
  should validate_presence_of(:name)
  should validate_presence_of(:weight)
  should validate_presence_of(:reorder_level)
  should validate_presence_of(:inventory_level)
  
   

end

require 'test_helper'

class PurchaseTest < ActiveSupport::TestCase

  # Relationship macros...
  should belong_to(:item)

  # Validation macros...
  should validate_presence_of(:item_id)
  should validate_presence_of(:quantity)
  should validate_presence_of(:date)
  should validate_inclusion_of(:item_id).in_array(Item.active.map {|i| i.id})

  # Validating quantity...
  should allow_value(1).for(:quantity)
  should allow_value(10).for(:quantity)
  should allow_value(-1).for(:quantity)
  should allow_value(-10).for(:quantity)

  should_not allow_value(0).for(:quantity)
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

   # ---------------------------------
  # Testing other scopes/methods with a context
  context "With a proper context," do
    # create the objects I want with factories
    
    setup do 
      # call the create_context method here
      create_context
    end
    
    # and provide a teardown method as well
    teardown do
      # call the remove_context method here
      remove_context
    end
  
    # now run the tests:
    # test one of each factory (not really required, but not a bad idea)
    should "show that all factories are properly created" do
      assert_equal "Wooden Chess Pieces", @woodPiece.name
      assert_equal 10, @woodPiecePurchase1.quantity
      assert_equal 15.99, @woodPiecePrice3.price
      assert @woodPiece.active
    end

  end
end

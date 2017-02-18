require 'test_helper'

class PurchaseTest < ActiveSupport::TestCase

  # Relationship macros...
  should belong_to(:item)

  # Validation macros...
  should validate_presence_of(:item_id)
  should validate_presence_of(:quantity)
  should validate_presence_of(:date)

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
  should_not allow_value(nil).for(:quantity)

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
      assert_equal 5, @woodPiecePurchase1.quantity
      assert_equal 2, @woodPiecePurchase2.quantity
      assert_equal -5, @woodPiecePurchase3.quantity
      assert_equal 15.99, @woodPiecePrice3.price
      assert @woodPiece.active
    end

    # test the scope 'chronological'
    should "properly handle 'chronological' scope" do
      assert_equal 3, Purchase.chronological.size
      assert_equal [1.day.ago.to_date, 2.months.ago.to_date, 1.year.ago.to_date], Purchase.chronological.map{|i| i.date}
    end

    # test the scope 'loss'
    should "properly handle 'loss' scope" do
      assert_equal 1, Purchase.loss.size
      assert_equal [1.day.ago.to_date], Purchase.loss.map{|i| i.date}
    end

    # test the scope 'for_item'
    should "properly handle 'for_item' scope" do
      assert_equal 3, Purchase.for_item(@woodPiece).size
      assert_equal [5, 2, -5], Purchase.for_item(@woodPiece).map{|i| i.quantity}
      @testItemY = FactoryGirl.create(:item, name: "Should have no purchases")
      assert_equal 0, Purchase.for_item(@testItemY).size
      @testItemY.destroy
    end

    # test that inventory will update properly when a purchase is made
    should "show that inventory is updated properly when a purchase is made" do
      assert_equal 12, @woodPiece.inventory_level
      @testItemY = FactoryGirl.create(:item, name: "derp", inventory_level: 100)
      @testPurchaseY = FactoryGirl.build(:purchase, item: @testItemY)
      assert 102, @testItemY.inventory_level
      @testItemY.destroy
      @testPurchaseY.destroy
    end

    # test the custom validation 'exists_and_active_in_system'
    should "identify a non-active item as inactive" do
      # try to build an purchase for an inactive item
      @fakePurchase = FactoryGirl.build(:purchase, item: @leatherBag)
      deny @fakePurchase.valid?
      @fakePurchase.destroy
    end

  end
end

require 'test_helper'

class ItemPriceTest < ActiveSupport::TestCase
  
  # Relationship macros...
  should belong_to(:item)

  # Validation macros...
  should validate_presence_of(:item_id)
  should validate_presence_of(:price)
  should validate_presence_of(:start_date)

  should validate_numericality_of(:price).is_greater_than_or_equal_to(0)

  # Validating price...
  should allow_value(7).for(:price)
  should allow_value(5.12).for(:price)
  should allow_value(0).for(:price)

  should_not allow_value(-1).for(:price)
  should_not allow_value(-3.10).for(:price)
  should_not allow_value("hello").for(:price)

  # Validating start_date...
  should allow_value(Date.today).for(:start_date)
  should allow_value(3.weeks.ago.to_date).for(:start_date)

  should_not allow_value(1.day.from_now.to_date).for(:start_date)
  should_not allow_value(-0.01).for(:start_date)
  should_not allow_value(5).for(:start_date)
  should_not allow_value("hello").for(:start_date)

  # Validating end_date...
  should_not allow_value(4).for(:end_date)
  should_not allow_value(4.01).for(:end_date)
  should_not allow_value("hello").for(:end_date)

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
      assert_equal "Metal Chess Board", @metalBoard.name
      assert_equal 13.99, @woodPiecePrice1.price
      assert_equal 14.99, @woodPiecePrice2.price
      assert_equal 15.99, @woodPiecePrice3.price
      assert_equal 99.99, @metalBoardPrice1.price
      assert_equal 49.99, @metalBoardPrice2.price
      assert_equal 0.99, @metalBoardPrice3.price
      assert @metalBoard.active
      assert @woodPiece.active
    end

    # test the scope 'current'
    should "show that there all the current prices are returned" do
      assert_equal 2, ItemPrice.current.size
      assert_equal [0.99, 15.99], ItemPrice.current.map{|i| i.price}.sort
    end

    # test the scope 'for_date'
    should "properly handle 'for_date' scope" do
      assert_equal 2, ItemPrice.for_date(2.weeks.ago.to_date).size
      assert_equal [14.99, 99.99], ItemPrice.for_date(2.weeks.ago.to_date).map{|i| i.price}.sort
      assert_equal 1, ItemPrice.for_date(7.weeks.ago.to_date).size
      assert_equal [13.99], ItemPrice.for_date(7.weeks.ago.to_date).map{|i| i.price}.sort
      assert_equal 2, ItemPrice.for_date(Date.today).size
      assert_equal [0.99, 15.99], ItemPrice.for_date(Date.today).map{|i| i.price}.sort
    end

    # test the scope 'for_item'
    should "properly handle 'for_item' scope" do
      assert_equal 3, ItemPrice.for_item(@woodPiece.id).size
      assert_equal [13.99, 14.99, 15.99], ItemPrice.for_item(@woodPiece.id).map{|i| i.price}.sort
      assert_equal 3, ItemPrice.for_item(@metalBoard.id).size
      assert_equal [0.99, 49.99, 99.99], ItemPrice.for_item(@metalBoard.id).map{|i| i.price}.sort
    end

    # test the scope 'chronological'
    should "properly handle 'chronological' scope" do
      assert 6, ItemPrice.chronological.size
      assert_equal [15.99, 0.99, 49.99, 99.99, 14.99, 13.99], ItemPrice.chronological.map{|i| i.price}
    end

    # test the callback for setting previous end_date to the new start_date
    should "properly set previous end_date to new start_date" do
      @woodPiecePrice1.reload
      @woodPiecePrice2.reload
      @woodPiecePrice3.reload
      assert_equal 1.month.ago.to_date, @woodPiecePrice1.end_date
      assert_equal Date.today, @woodPiecePrice2.end_date
      assert_nil @woodPiecePrice3.end_date
    end

    # test that an end_date cannot be set before a start_date
    should "not allow an end_date to be set before a start_date" do
      @wackItem = FactoryGirl.create(:item, name: "hello")
      @itemPrice1 = FactoryGirl.build(:item_price, item: @wackItem, end_date: 3.weeks.ago.to_date)
      assert @wackItem.valid?
      deny @itemPrice1.valid?
      @wackItem.destroy
      @itemPrice1.destroy
    end

    # test the custom validation 'exists_and_active_in_system'
    should "identify a non-active item as inactive" do
      # try to build an item_price for an inactive item
      @fakePrice = FactoryGirl.build(:item_price, item: @leatherBag)
      deny @fakePrice.valid?
      @fakePrice.destroy
    end

  end
end
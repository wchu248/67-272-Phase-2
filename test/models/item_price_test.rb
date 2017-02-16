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
  context "Creating three items" do
    # create the objects I want with factories
    setup do 
      @woodPiece = FactoryGirl.create(:item, inventory_level: 10)
      @metalBoard = FactoryGirl.create(:item, name: "Metal Chess Board", category: "boards", color: "silver")
      @woodPiecePrice1 = FactoryGirl.create(:item_price, item: @woodPiece, price: 13.99, start_date: 2.months.ago.to_date)
      @woodPiecePrice2 = FactoryGirl.create(:item_price, item: @woodPiece, price: 14.99, start_date: 1.month.ago.to_date)
      @woodPiecePrice3 = FactoryGirl.create(:item_price, item: @woodPiece)
      @metalBoardPrice1 = FactoryGirl.create(:item_price, item: @metalBoard, price: 99.99, start_date: 3.weeks.ago.to_date)
      @metalBoardPrice2 = FactoryGirl.create(:item_price, item: @metalBoard, price: 49.99, start_date: 2.days.ago.to_date)
      @metalBoardPrice3 = FactoryGirl.create(:item_price, item: @metalBoard, price: 0.99)
    end
    
    # and provide a teardown method as well
    teardown do
      @woodPiecePrice3.destroy
      @woodPiecePrice2.destroy
      @woodPiecePrice1.destroy
      @metalBoardPrice3.destroy
      @metalBoardPrice2.destroy
      @metalBoardPrice1.destroy
      @metalBoard.destroy
      @woodPiece.destroy
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
    # how does the order work when two prices are changed at the same time?
    end

  end

end
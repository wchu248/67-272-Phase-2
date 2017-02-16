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

  should validate_uniqueness_of(:name).case_insensitive
  should validate_numericality_of(:weight).is_greater_than(0)
  should validate_inclusion_of(:category).in_array(%w[pieces boards clocks supplies])

  # Validating category...
  should allow_value('pieces').for(:category)
  should allow_value('boards').for(:category)
  should allow_value('clocks').for(:category)
  should allow_value('supplies').for(:category)

  should_not allow_value('bags').for(:category)
  should_not allow_value('clock').for(:category)
  should_not allow_value(0).for(:category)

  # Validating weight...
  should allow_value(7).for(:weight)
  should allow_value(5.12).for(:weight)

  should_not allow_value(0).for(:weight)
  should_not allow_value(-4.20).for(:weight)
  should_not allow_value("hello").for(:weight)

  # Validating inventory_level...
  should allow_value(0).for(:inventory_level)
  should allow_value(5).for(:inventory_level)
  should allow_value(100).for(:inventory_level)

  should_not allow_value(-1).for(:inventory_level)
  should_not allow_value(10.5).for(:inventory_level)
  should_not allow_value("not allowed").for(:inventory_level)

  # Validating reorder_level...
  should allow_value(0).for(:reorder_level)
  should allow_value(5).for(:reorder_level)
  should allow_value(100).for(:reorder_level)

  should_not allow_value(-1).for(:reorder_level)
  should_not allow_value(10.5).for(:reorder_level)
  should_not allow_value("not allowed").for(:reorder_level)

  # ---------------------------------
  # Testing other scopes/methods with a context
  context "Creating three items" do
    # create the objects I want with factories
    setup do 
      @woodPiece = FactoryGirl.create(:item, inventory_level: 10)
      @metalBoard = FactoryGirl.create(:item, name: "Metal Chess Board", category: "boards", color: "silver")
      @leatherBag = FactoryGirl.create(:item, name: "Leather Bag", category: "supplies", inventory_level: 20, active: false)
      @metalPieces = FactoryGirl.create(:item, name: "Metal Chess Pieces", color: "silver/black")
      @woodPiecePrice1 = FactoryGirl.create(:item_price, item: @woodPiece, price: 13.99, start_date: 2.months.ago.to_date)
      @woodPiecePrice2 = FactoryGirl.create(:item_price, item: @woodPiece, price: 14.99, start_date: 1.month.ago.to_date)
      @woodPiecePrice3 = FactoryGirl.create(:item_price, item: @woodPiece)
    end
    
    # and provide a teardown method as well
    teardown do
      @woodPiecePrice3.destroy
      @woodPiecePrice2.destroy
      @woodPiecePrice1.destroy
      @metalPieces.destroy
      @leatherBag.destroy
      @metalBoard.destroy
      @woodPiece.destroy
    end
  
    # now run the tests:
    # test one of each factory (not really required, but not a bad idea)
    should "show that all factories are properly created" do
      assert_equal "Wooden Chess Pieces", @woodPiece.name
      assert_equal "Metal Chess Board", @metalBoard.name
      assert_equal "Leather Bag", @leatherBag.name
      assert_equal "Metal Chess Pieces", @metalPieces.name
      assert @woodPiece.active
      assert @metalBoard.active
      assert @metalPieces.active
      deny @leatherBag.active
    end

    # test the scope 'active'
    should "shows that there are three active items" do
      assert_equal 3, Item.active.size
      assert_equal ["Metal Chess Board", "Metal Chess Pieces", "Wooden Chess Pieces"], Item.active.map{|o| o.name}.sort
    end

    # test the scope 'inactive'
    should "shows that there is one inactive item" do
      assert_equal 1, Item.inactive.size
      assert_equal ["Leather Bag"], Item.inactive.map{|o| o.name}.sort
    end
        
    # test the scope 'alphabetical'
    should "shows that there are four items in in alphabetical order" do
      assert_equal ["Leather Bag", "Metal Chess Board", "Metal Chess Pieces", "Wooden Chess Pieces"], Item.alphabetical.map{|o| o.name}
    end
    
    # test the scope 'need_reorder'
    should "shows that there are two items that need reordering" do
      assert_equal 2, Item.need_reorder.size
      assert_equal ["Leather Bag", "Wooden Chess Pieces"], Item.need_reorder.map{|o| o.name}.sort
    end

    # test the scope 'for_category' works
    should "shows that the 'pieces' category contains the correct items" do
      assert_equal 2, Item.for_category("pieces").size
      assert_equal ["Metal Chess Pieces", "Wooden Chess Pieces"], Item.for_category("pieces").map{|o| o.name}.sort
    end
    
    # test the scope 'for_color' works
    should "properly handle color scope" do
      assert_equal 2, Item.for_color("silver").size
      assert_equal ["Metal Chess Board", "Metal Chess Pieces"], Item.for_color("silver").map{|o| o.name}.sort
      assert_equal 2, Item.for_color("tan").size
      assert_equal ["Leather Bag", "Wooden Chess Pieces"], Item.for_color("tan").map{|o| o.name}.sort
      assert_equal 2, Item.for_color("beige").size
      assert_equal ["Leather Bag", "Wooden Chess Pieces"], Item.for_color("beige").map{|o| o.name}.sort
      assert_equal 1, Item.for_color("black").size
      assert_equal ["Metal Chess Pieces"], Item.for_color("black").map{|o| o.name}.sort
    end
    
    # test the method 'current_price' works
    should "return correct current price" do
      assert_equal 15.99, @woodPiece.current_price
      assert_not_equal nil, @woodPiece.current_price
    end

    # test the method 'price_on_date' works
    should "return correct price on input date" do
      assert_equal 15.99, @woodPiece.price_on_date(Date.today)
      assert_equal 14.99, @woodPiece.price_on_date(2.weeks.ago.to_date)
      assert_equal 13.99, @woodPiece.price_on_date(6.weeks.ago.to_date)
      assert_nil @woodPiece.price_on_date(6.months.ago.to_date)
    end

    # test the method 'reorder?' works
    should "shows that there are two items that need to be reordered" do
      assert_equal true, @woodPiece.reorder?
      assert_equal true, @leatherBag.reorder?
      assert_equal false, @metalBoard.reorder?
      assert_equal false, @metalPieces.reorder?
    end

    should "not allow the duplicate names in the database, regardless of case" do
      testItem1 = FactoryGirl.create(:item, name: 'Glass Chess Pieces')
      testItem2 = FactoryGirl.build(:item, name: 'glass Chess Pieces')
      assert testItem1.valid?
      deny testItem2.valid?
    end

  end
end


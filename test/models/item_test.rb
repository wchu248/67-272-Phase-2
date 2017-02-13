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

  # Validating weight...
  should allow_value(7).for(:weight)
  should allow_value(5.12).for(:weight)

  should_not allow_value(0).for(:weight)
  should_not allow_value(-4.20).for(:weight)

  # Validating inventory_level...
  should allow_value(0).for(:inventory_level)
  should allow_value(5).for(:inventory_level)
  should allow_value(100).for(:inventory_level)

  should_not allow_value(-1).for(:inventory_level)
  should_not allow_value(10.5).for(:inventory_level)

  # Validating reorder_level...
  should allow_value(0).for(:reorder_level)
  should allow_value(5).for(:reorder_level)
  should allow_value(100).for(:reorder_level)

  should_not allow_value(-1).for(:reorder_level)
  should_not allow_value(10.5).for(:reorder_level)

  # ---------------------------------
  # Testing other methods with a context
  context "Creating three owners" do
    # create the objects I want with factories
    setup do 
      @alex = FactoryGirl.create(:owner)
      @rachel = FactoryGirl.create(:owner, first_name: "Rachel", active: false)
      @mark = FactoryGirl.create(:owner, first_name: "Mark", phone: "412-268-8211")
    end
    
    # and provide a teardown method as well
    teardown do
      @rachel.destroy
      @mark.destroy
      @alex.destroy
    end
  
    # now run the tests:
    # test one of each factory (not really required, but not a bad idea)
    should "show that all factories are properly created" do
      assert_equal "Alex", @alex.first_name
      assert_equal "Mark", @mark.first_name
      assert_equal "Rachel", @rachel.first_name
      assert @alex.active
      assert @mark.active
      deny @rachel.active
    end
    
    # test the scope 'alphabetical'
    should "shows that there are three owners in in alphabetical order" do
      assert_equal ["Alex", "Mark", "Rachel"], Owner.alphabetical.map{|o| o.first_name}
    end
    
    # test the scope 'active'
    should "shows that there are two active owners" do
      assert_equal 2, Owner.active.size
      # assert_equal ["Alex", "Mark"], Owner.active.alphabetical. map{|o| o.first_name}
      assert_equal ["Alex", "Mark"], Owner.active.map{|o| o.first_name}.sort

    end
    
    # test the scope 'search'
    should "shows that search for owner by either (part of) last or first name works" do
      assert_equal 3, Owner.search("Hei").size
      assert_equal 1, Owner.search("Mark").size
    end
    
    # test the method 'name' works
    should "shows that name method works" do
      assert_equal "Heimann, Alex", @alex.name
    end
    
    # test the method 'proper_name' works
    should "shows that proper_name method works" do
      assert_equal "Alex Heimann", @alex.proper_name
    end
    
    # test the callback is working 'reformat_phone'
    should "shows that Mark's phone is stripped of non-digits" do
      assert_equal "4122688211", @mark.phone
    end
  end
end


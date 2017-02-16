require 'simplecov'
SimpleCov.start 'rails'
SimpleCov.formatter = SimpleCov::Formatter::Console
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/rails'
require 'minitest/reporters'
require 'minitest_extensions'
require 'factory_girl_rails'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # fixtures :all

  # Add the infamous deny method...
  def deny(condition, msg="")
    # a simple transformation to increase readability IMO
    assert !condition, msg
  end

    # ----------------------------------------------------
  # CREATE_ & REMOVE_CONTEXT HELPER METHODS NOT DEFAULT METHODS IN RAILS 
  def create_context
    # Create four items
    @woodPiece = FactoryGirl.create(:item, inventory_level: 10)
    @metalBoard = FactoryGirl.create(:item, name: "Metal Chess Board", category: "boards", color: "silver")
    @leatherBag = FactoryGirl.create(:item, name: "Leather Bag", category: "supplies", inventory_level: 20, active: false)
    @metalPieces = FactoryGirl.create(:item, name: "Metal Chess Pieces", color: "silver/black")

    # Create 3 prices for some items
    @woodPiecePrice1 = FactoryGirl.create(:item_price, item: @woodPiece, price: 13.99, start_date: 2.months.ago.to_date)
    @woodPiecePrice2 = FactoryGirl.create(:item_price, item: @woodPiece, price: 14.99, start_date: 1.month.ago.to_date)
    @woodPiecePrice3 = FactoryGirl.create(:item_price, item: @woodPiece)
    @metalBoardPrice1 = FactoryGirl.create(:item_price, item: @metalBoard, price: 99.99, start_date: 3.weeks.ago.to_date)   
    @metalBoardPrice2 = FactoryGirl.create(:item_price, item: @metalBoard, price: 49.99, start_date: 2.days.ago.to_date) 
    @metalBoardPrice3 = FactoryGirl.create(:item_price, item: @metalBoard, price: 0.99)

    # Create a purchse for an item
    @woodPiecePurchase1 = FactoryGirl.create(:purchase, item: @woodPiece, quantity: 10)
  end
  
  def remove_context
    @woodPiecePurchase1.destroy
    @metalBoardPrice3.destroy
    @metalBoardPrice2.destroy
    @metalBoardPrice1.destroy
    @woodPiecePrice3.destroy
    @woodPiecePrice2.destroy
    @woodPiecePrice1.destroy
    @metalPieces.destroy
    @leatherBag.destroy
    @metalBoard.destroy
    @woodPiece.destroy
  end

  # Spruce up minitest results...
  Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new]

end
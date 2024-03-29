class Item < ActiveRecord::Base
    
    # Relationships
    # -----------------------------
    has_many :item_prices, dependent: :destroy
    has_many :purchases

    # Scopes
    # -----------------------------
    # gets all the active items
    scope :active, -> { where(active: true) }
    # gets all the inactive items
    scope :inactive, -> { where(active: false) }
    # orders results alphabetically
    scope :alphabetical, -> { order('name') }
    # gets all the items where reorder_level >= inventory_level
    scope :need_reorder, -> { where('reorder_level >= inventory_level') }
    # gets all the items in a particular category
    scope :for_category, ->(category) { where('category = ?', category) }
    # gets all the items that match a particular color
    scope :for_color, ->(color) { where('color LIKE ?', "%" + color + "%") }

    # Validations
    # -----------------------------
    # make sure required fields are present
    validates_presence_of :name, :weight, :reorder_level, :inventory_level
    # weight must be positive
    validates_numericality_of :weight, greater_than: 0
    # each name must be unique, regardless of case
    validates :name, uniqueness: { case_sensitive: false }
    # the category of the item must be one of 4 available categories
    validates_inclusion_of :category, in: %w[pieces boards clocks supplies], message: 'is not an option'
    # reorder_level and inventory_level must be zero or greater
    validates_numericality_of :reorder_level, only_integer: true, greater_than_or_equal_to: 0
    validates_numericality_of :inventory_level, only_integer: true, greater_than_or_equal_to: 0

    # Methods
    # -----------------------------
    def current_price
        item_obj = self.item_prices.current.first
        return nil if item_obj.nil?
        item_obj.price
    end

    def price_on_date(date)
        item_obj = self.item_prices.for_date(date).first
        return nil if item_obj.nil?
        item_obj.price
    end

    def reorder?
        self.reorder_level >= self.inventory_level
    end
    
end
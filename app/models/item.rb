class Item < ActiveRecord::Base
    
    # Relationships

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
    scope :for_color, ->(color) { where('color LIKE ?', "#{color}%") }

    # Methods
    # -----------------------------
    # gets the current price of the item; nil if price has not been set
    def current_price
    end

    def price_on_date
    end

    def reorder
    end

    # Validations
end
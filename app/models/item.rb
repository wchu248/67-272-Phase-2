class Item < ActiveRecord::Base
    
    # Relationships
    # -----------------------------
    has_many :item_prices
    # belongs_to :item_price (don't know if I actually need this, check with other people)
    belongs_to :purchase

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
        # get an array of all the store's item prices
        possible_item_prices = ItemPrice.for_item(self.id)
        unless possible_item_prices.include?(self.id)
            return nil
        end
        # get an array of prices for the item (self)
        all_prices = possible_item_prices.find_by_id(self.id)
        @curr_price = all_prices.find(|i| i.end_date == NULL)
        return @curr_price.price
    end

    def price_on_date(date)
        # checks that the parameter is of Date type
        if (value.is_a?(Date))
            # get an array of the item's prices
            possible_item_prices = ItemPrice.for_item(self.id).for_date(date)
            possible_item_prices.each do |x|
                unless x.end_date == NULL 
                    return x.price if date.between(x.start_date, x.end_date)
                end
            end
            return nil
        end
        else
            errors.add(:item_price, "is not a date value")
        end
    end

    def reorder?
        self.reorder_level >= self.inventory_level
    end

    # Validations
    # -----------------------------
    # make sure required fields are present
    validates_presence_of :name, :weight
    # make sure the active field is a boolean
    validates :active, inclusion: { in: [true, false] }
    # each name must be unique, regardless of case
    validates :name, uniqueness: { case_sensitive: false }
    # the category of the item must be one of 4 options
    validates_inclusion_of :category, in: %w[pieces boards clocks supplies], message: "is not an option", allow_blank: true
    # reorder_level and inventory_level must be zero or greater
    validates_presence_of :reorder_level
    validates_numericality_of :reorder_level, only_integer: true, greater_than_or_equal_to: 0
    validates_presence_of :inventory_level
    validates_numericality_of :inventory_level, only_integer: true, greater_than_or_equal_to: 0
end
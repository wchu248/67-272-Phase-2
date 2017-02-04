class ItemPrice < ActiveRecord::Base

    # Relationships
    # -----------------------------
    belongs_to :item

    # Scopes
    # -----------------------------
    # gets only current prices
    scope :current, -> { where(end_date: nil) }
    # returns the prices for a specified date
    scope :for_date, ->(date) { where('start_date <= ? AND (end_date > ? OR end_date IS NULL)', date, date) }
    # returns the prices for a specificed item
    scope :for_item, ->(item_id) { where('item_id = ?', item_id) }
    # orders results chronologically with most recent price changes at top of the list
    scope :chronological, -> { order('start_date DESC') }

    # Validations
    # -----------------------------
    # make sure required fields are present
    validates_presence_of :item_id, :price, :start_date
    # make sure the price is a valid price
    validates_numericality_of :price, greater_than_or_equal_to: 0
    # make sure item_ids are for items which exist and are active in system
    validates_inclusion_of :item_id, in: lambda { Item.active }
    # make sure start_date is set in present or past, not in future
    validates_date :start_date, on_or_before: lambda { Date.current }
    # make sure end_date to be the same date or some date after start_date
    validates_date :end_date, on_or_after: :start_date, allow_blank: true

    # Callbacks
    # -----------------------------
    # when new item price created, previous item price's end date set to start date of new price change
    before_create :set_end_date_to_start_date
    
    # Methods
    # -----------------------------
    def set_end_date_to_start_date 
        previous = ItemPrice.current.for_item(self.item_id)
        unless previous.nil?
            previous.update_attribute(:end_date, self.start_date) 
        end
    end

end
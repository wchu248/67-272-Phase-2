class ItemPrice < ActiveRecord::Base

    # Relationships
    # -----------------------------
    belongs_to :item

    # Scopes
    # -----------------------------
    # gets only current prices
    scope :current, -> { where(end_date: NULL) }
    # returns the prices for a specified date
    scope :for_date, ->(date) { where('start_date < ? AND end_date > ?', date, date) }
    # returns the prices for a specificed item
    scope :for_item, ->(item_id) { where('item_id = ?', item_id) }
    # orders results chronologically with most recent price changes at top of the list
    scope :chronological, lambda { order('start_date DESC') }

    # Validations
    # -----------------------------
    # make sure required fields are present
    validates_presence_of :item_id, :price, :start_date
    # make sure item_ids are for items which exist and are active in system
    validates_inclusion_of :item_id, in: Item.active
    # make sure start_date is set in present or past, not in future
    validate :start_date_cannot_be_in_future
    # make sure end_date to be the same date or some date after start_date
    validate :end_date_valid, allow_nil: true

    # Callbacks
    # -----------------------------
    # when new item price created, previous item price's end date set to start date of new price change
    before_create :set_end_date_to_start_date
    before_destroy :is_never_destroyable
    
    # Methods
    # -----------------------------
    def set_end_date_to_start_date 
        previous = ItemPrice.current.for_item(self.item_id)
        unless previous.nil?
            previous.update_attribute(:end_date, self.start_date) 
        end
    end

    # Use private methods to execute the custom validations
    # -----------------------------
    private
    def start_date_cannot_be_in_future
        self.start_date > Date.today
    end

    def end_date_valid
        self.start_date <= self.end_date 
    end

end
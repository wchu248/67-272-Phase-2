class Purchase < ActiveRecord::Base

    # Relationships
    # -----------------------------
    belongs_to :item

    # Scopes
    # -----------------------------
    # orders results chronologically with most recent purchases at top of the list
    scope :chronological, -> { order('date DESC') }
    # returns all purchases that have negative quantities
    scope :loss, -> { where('quantity < 0') }
    # returns all purchases for a specified item
    scope :for_item, ->(item_id) { where('item_id = ?', item_id) }

    # Validations
    # -----------------------------
    # make sure required fields are present
    validates_presence_of :item_id, :quantity, :date
    # make sure item_ids are for items which exist and are active in system
    validates_inclusion_of :item_id, in: Item.active.map {|i| i.id} 
    # make sure the quantity is an integer
    validates_numericality_of :quantity, only_integer: true
    # make sure date is set in present or past, not in future
    validate :date_cannot_be_in_future

    # Callbacks
    # -----------------------------
    # when new purchase is added, inventory level automatically adjusts 
    after_create :update_inventory
    
    # Methods
    # -----------------------------
    def update_inventory
        purchased_item = Item.find(self.item_id)
        curr_inv_level = purchase_item.inventory_level
        purchased_item.update_attribute(:inventory_level, curr_inv_level + self.quantity) 
    end

    # Use private methods to execute the custom validations
	# -----------------------------
	private
	def date_cannot_be_in_future
        unless self.date.nil? || self.nil?
	        self.date <= Date.today
        end
	end
end
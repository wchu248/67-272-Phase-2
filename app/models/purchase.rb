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
    # make sure item_ids are for items which exist and are active in system
    validates_inclusion_of :item_id, in: Item.active
    # make sure date is set in present or past, not in future
    validates_date :date, on_or_before: lambda { Date.current }

    # Callbacks
    # -----------------------------
    # when new purchase is added, inventory level automatically adjusts 
    after_create :update_inventory
    
    # Methods
    # -----------------------------
    def update_inventory
        purchased_item = Item.find(self.item_id)
        curr_inv_level = purchase_item.inventory_level
        item.update_attribute(:inventory_level, curr_inv_level + self.quantity) 
    end

end
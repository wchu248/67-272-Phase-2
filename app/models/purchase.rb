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
    # make sure the quantity is an integer
    validates_numericality_of :quantity, only_integer: true, other_than: 0
    # make sure date is set in present or past, not in future
    validates_date :date, on_or_before: -> { Date.current }
    # make sure item_ids are for items which exist and are active in system
    validate :exists_and_active_in_system

    # Callbacks
    # -----------------------------
    # when new purchase is added, inventory level automatically adjusts 
    after_create :update_inventory
    
    # Methods
    # -----------------------------
    def update_inventory
        purchased_item = Item.find(self.item_id)
        curr_inv_level = purchased_item.inventory_level
        item.update_attribute(:inventory_level, curr_inv_level + self.quantity) 
    end

    private
    def exists_and_active_in_system
        all_item_ids = Item.active.all.map{|o| o.id}
        unless all_item_ids.include?(self.item_id)
            errors.add(:item, "is not an active item in the system")
            return false
        end
        return true
    end

end
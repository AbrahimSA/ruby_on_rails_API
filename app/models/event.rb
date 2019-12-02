class Event < ApplicationRecord
    self.primary_key = "id"
    self.inheritance_column = nil
     belongs_to :actor#, optional: true
     belongs_to :repo #, optional: true
end

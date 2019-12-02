class Actor < ApplicationRecord
    self.primary_key = "id"
 
    # has_many :events, class_name: "Event", foreign_key: "actor_id"
  has_many :events
    # has_many :repo, through: :event

end
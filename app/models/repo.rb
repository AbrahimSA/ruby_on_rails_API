class Repo < ApplicationRecord
    self.primary_key = "id"
#    has_many :events, class_name: "Event", foreign_key: "repo_id"
    has_many :events
end
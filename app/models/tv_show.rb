class TvShow < ActiveRecord::Base
  belongs_to :user
  has_many :episodes
  validates :title, presence: true,
                    uniqueness: { case_sensitive: false }
  validates :description, length: { maximum: 120 }
end

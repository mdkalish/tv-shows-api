class Episode < ActiveRecord::Base
  belongs_to :tv_show
  validates :tv_show, :title, :episode, presence: true
  validates_uniqueness_of :title, :scope => [:tv_show_id]
end

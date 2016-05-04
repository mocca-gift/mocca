class Gift < ActiveRecord::Base
    validates :name,
      presence: true,
      uniqueness: true
    validates :url,
      presence: true,
      uniqueness: true
    validates :img,
      presence: true
end

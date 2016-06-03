class Gift < ActiveRecord::Base
    validates :name,
      presence: true,
      uniqueness: true
    validates :url,
      presence: true,
      uniqueness: true
    validates :img,
      presence: true
    validates :company_name,
      presence: true
    validates :price,
      presence: true,
      greater_than_or_equal_to:1,
      less_than_or_equal_to:5
end

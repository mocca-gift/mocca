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
      presence: true
end

class Product < ApplicationRecord
  belongs_to :product_category

  enum status: { unpublished: 0, published: 1 }
end

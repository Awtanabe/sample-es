json.extract! product, :id, :name, :price, :status, :product_category, :references, :created_at, :updated_at
json.url product_url(product, format: :json)

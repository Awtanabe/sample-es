module ProductSearchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model

    # ①index名
    index_name "es_product_#{Rails.env}"

    # 検索対象
    # product
    # product_category
    # ②マッピング情報
    settings do
      mappings dynamic: 'false' do
        indexes :id,                   type: 'integer'
        indexes :name,                 type: 'text', analyzer: 'kuromoji'
        indexes :created_at,           type: 'date'
        indexes :product_category,        type: 'text', analyzer: 'kuromoji'
      end
    end

    def as_indexed_json(*)
      self.as_json(include: { product_category: { only: :created_at}})
      attributes
        .symbolize_keys
        .slice(:id, :name, :created_at)
        .merge(product_category: product_category_name)
    end
  end

  def product_category_name
    product_category.name
  end

  class_methods do
    # ④indexを作成するメソッド
    def create_index!
      client = __elasticsearch__.client
      # すでにindexを作成済みの場合は削除する

      client.indices.delete index: self.index_name rescue nil
      # indexを作成する

      client.indices.create(index: self.index_name,
                            body: {
                                settings: self.settings.to_hash,
                                mappings: self.mappings.to_hash
                            })
    end

    def delete_index!
      client = __elasticsearch__.client
      client.indices.delete index: self.index_name rescue nil
    end

    def es_search(query)
      __elasticsearch__.search({
        query: {
          multi_match: {
            fields: %w(name product_category),
            type: 'cross_fields',
            query: query,
            operator: 'and'
          }
        }
      })
    end
  end
end
module MangaSearchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model

    # ①index名
    index_name "es_manga_#{Rails.env}"

    # ②マッピング情報
    settings do
      mappings dynamic: 'false' do
        indexes :id,                   type: 'integer'
        indexes :publisher,            type: 'keyword'
        indexes :author,               type: 'keyword'
        indexes :category,             type: 'text', analyzer: 'kuromoji'
        indexes :c_date,               type: 'date'
        indexes :title,                type: 'text', analyzer: 'kuromoji'
        indexes :description,          type: 'text', analyzer: 'kuromoji'
        indexes :created_at,           type: 'date'
        indexes :updated_at,           type: 'date', format: 'YYYY-MM-dd kk:mm:ss'
      end
    end

    # ③mappingの定義に合わせてindexするドキュメントの情報を生成する
    def as_indexed_json(*)
      self.as_json(include: { category: { only: :created_at}})
      attributes
        .symbolize_keys
        .slice(:id, :title, :description, :created_at)
        .merge(publisher: publisher_name, author: author_name, category: category_name, c_date: category_date)
    end
  end

  def publisher_name
    publisher.name
  end

  def author_name
    author.name
  end

  def category_name
    category.name
  end

  def category_date
    category.created_at
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

    def es_search(query)
      __elasticsearch__.search({
        query: {
          multi_match: {
            fields: %w(id publisher author category title description c_date),
            type: 'cross_fields',
            query: query,
            operator: 'and'
          }
        }
      })
    end
  end
end
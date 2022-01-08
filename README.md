# README

## es概要

- index: esのDB
- document: データの単位

- 呼び方の違い

- RDB vs ES
  - データベース:インデックス
  - テーブル:マッピングタイプ
  - カラム（列）:フィールド
  - レコード(行):ドキュメント

- Analysis：言語処理や正規化などのフィールドの値の加工について

## 手順

- seed
- create index: index作成
  -  Manga.__elasticsearch__.create_index!
  - インデックス有無確認
    - curl 'localhost:9200/_cat/indices?v'
- import: indexが無いとできない
  - Manga.__elasticsearch__.import

## 実装

- gem入れる
- MangaSearchable作成
  - concernsに入れる
  - 設定するモノ
  - index名
  - マッピング: 検索対象を決める
    - include Elasticsearch::Modelで検索つないでいるのだろう
    - as_indexed_jsonで渡す
  - class_methods: モジュールのメソッド
  - __elasticsearch__.xxxで色々できるみたい
    - __elasticsearch__.searchとか

- Manがでinclude

## 実装してみる

```pluntuml

PrudoctCategory
  name: string



```


## es

https://github.com/elastic/elasticsearch-rails/blob/master/elasticsearch-model/README.md


## es ドキュメント

https://www.elastic.co/guide/en/elasticsearch/reference/6.8/getting-started.html


curl -X GET "localhost:9200/bank/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": { "match_all": {} },
  "sort": [
    { "account_number": "asc" }
  ],
  "from": 10,
  "size": 10
}
'

- インデックスの確認

curl -XGET 'localhost:9200/_cat/indices?v'

### 基本検索

※全てのレコードを持ってくる

```
curl -X GET "localhost:9200/es_manga_development/_search?pretty" -H 'Content-Type: application/json' -d '
{
  "query": { "match_all": {} }
}'
```

※ソートする

```
curl -X GET "localhost:9200/es_manga_development/_search?pretty" -H 'Content-Type: application/json' -d '
{
  "query": { "match_all": {} },
  "sort": [
    {"created_at": {
      "order": "asc"
    }}
  ]
}'
```


- 検索

```
curl -X GET "localhost:9200/es_manga_development/_search?pretty" -H 'Content-Type: application/json' -d '
{
  "query": { "match_all": {} },
  "sort": [
    {"c_date": {
      "order": "desc"
    }}
  ]
}'
```





- マッピング

```
➜  sample_es git:(master) ✗ curl -XGET 'localhost:9200/es_manga_development/_mapping?pretty'
{
  "es_manga_development" : {
    "mappings" : {
      "_doc" : {
        "dynamic" : "false",
        "properties" : { ## priperties キー
          "author" : {
            "type" : "keyword"
          },
          "category" : {
            "type" : "text",
            "analyzer" : "kuromoji"
          },
          "description" : {
            "type" : "text",
            "analyzer" : "kuromoji"
          },
          "id" : {
            "type" : "integer"
          },
          "publisher" : {
            "type" : "keyword"
          },
          "title" : {
            "type" : "text",
            "analyzer" : "kuromoji"
          }
        }
      }
    }
  }
}
```

- インデックスを更新

モデル.create_index!
Manga.__elasticsearch__.import データ入れる


curl -X GET "localhost:9200/es_manga_development/_search?pretty" -H 'Content-Type: application/json' -d '
{
  "query": { "match": {"category_name": "歴史"} },
  "sort": [
    {"created_at": {
      "order": "asc"
    }}
  ]
}'
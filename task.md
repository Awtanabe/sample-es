## 実装

- [x] モデル作成 product, product_category
- [x] カテゴリ  collection
- [x]enum
  - enum-help
  - ja.ymlに記載

- enum ja yml
  -     <%= form.select :status, Product.statuses.map { |k, v| [t("product.status.#{k}"), v] }%>

- es モジュール作成
- 
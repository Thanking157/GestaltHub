# GestaltHub v0.1 Feature Database 規格

## 這份文件是做什麼的？

Feature Database 是 GestaltHub 的「功能知識庫」。它記錄某個 feature 是什麼、在哪些環境被觀察到、可信度如何，以及目前允許做什麼。

它不是把其他專案的資料整包搬過來，而是 GestaltHub 自己維護、可以追溯來源的資料契約。

## 每筆 Feature 要記錄什麼？

- id：GestaltHub 內部固定識別碼
- key：平台 key 或抽象 key family
- displayName、summary：給 UI 顯示的名稱與說明
- valueType：boolean、integer、string、array、dictionary 或 opaque
- allowedValues 或驗證限制（若已知）
- 支援的平台、OS 與 build 範圍
- 裝置限制條件
- compatibilityPolicy：supported、conditional、unsupported 或 unknown
- riskLevel：informational、low、medium、high 或 critical
- writePolicy：readOnly、plannedOnly、backendDependent 或 unavailable
- provenance：資料來源、參考連結、日期與可信度
- 備註，以及是否需要 Expert Mode

## 可信度

每筆資料的可信度分為：

- observed：在指定裝置/build 實際觀察到
- documented：有公開官方文件支持
- inferred：由多筆觀察推論
- unknown：目前證據不足

UI 必須顯示來源與可信度。低可信度資料不能被呈現成保證。

## 儲存與版本

v0.1 使用內建 seed dataset 加上本機 schema version。格式要能支援：

- 增加欄位的 migration
- 停用資料但保留舊 History
- 未來匯入 hash 驗證過的資料集
- 保留原始來源與可信度

建議路徑：

- Resources/FeatureDatabase/seed.json
- Resources/FeatureDatabase/schema.json

seed 只能放 GestaltHub 自己撰寫的資料與引用，不放第三方程式碼或 UI。

## 查詢需求

至少支援：

- 依 id 或 key 查詢
- 依平台、裝置、OS/build 篩選
- 文字搜尋
- 取得 provenance
- 回傳包含資料庫版本的快照，讓 History 能重現當時的判斷

## 範例資料

    {
      "id": "example.feature",
      "key": "ExampleKey",
      "displayName": "範例功能",
      "summary": "僅供格式展示。",
      "valueType": "boolean",
      "platformScope": ["iOS", "iPadOS"],
      "compatibilityPolicy": "unknown",
      "riskLevel": "informational",
      "writePolicy": "readOnly",
      "provenance": {
        "sourceType": "originalObservation",
        "reference": "replace-with-a-real-reference",
        "confidence": "unknown"
      }
    }

這只是格式範例，不代表任何真實平台功能。

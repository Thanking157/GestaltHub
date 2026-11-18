# GestaltHub v0.1 開發路線圖

## 第一階段：打地基

- 完成架構與安全範圍文件
- 建立 SwiftUI App shell
- 建立 Domain models 與 protocols
- 建立唯讀 Device Detector
- 建立記憶體版 Feature Repository 與 Compatibility Engine
- 建立基本 History、Backup/Restore 介面

## 第二階段：可使用的唯讀版本

- 加入 Feature Database schema 與 seed records
- 完成功能瀏覽器
- 顯示相容性結果與理由
- 完成修改計畫與明確確認畫面
- 匯出診斷報告
- 補齊單元測試與 UI fixture

## 第三階段：backend 邊界

- 加入 backend capability discovery
- 以 no-op/唯讀 backend 作為預設
- 完成帶完整性驗證的 Backup/Restore coordinator
- 只有在目標環境、授權模型與 rollback 都寫清楚並經過審查後，才考慮獨立啟用其他 backend

每個階段都應該是小而容易 review 的 commit。完成前兩階段不代表 App 已具備寫入能力。

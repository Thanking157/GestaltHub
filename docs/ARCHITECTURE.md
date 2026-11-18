# GestaltHub v0.1 架構規格

## 這份文件是做什麼的？

這是 GestaltHub 的總設計圖：先定義 App 有哪些層、資料怎麼流動、哪些元件可以互相呼叫，以及哪些事情 v0.1 明確不做。未來寫 Swift/SwiftUI 時，程式碼應該對照這份文件，而不是各自發展。

## 專案目標

GestaltHub 是一個 iOS/iPadOS App，用來：

- 讀取裝置、系統版本與 build 資訊
- 查詢 Feature Database
- 判斷某功能在目前環境的相容性
- 產生可檢查、可回復的修改計畫
- 管理 Backup/Restore 與操作 History
- 提供 Expert Editor
- 透過抽象化的 Write Backend 對接未來可能存在的寫入機制

v0.1 必須在唯讀模式下也能正常使用。

## v0.1 不做的事情

- 不提供 exploit chain、sandbox escape、權限提升或簽章繞過
- 不提供靜默、遠端或不可逆的修改
- 不直接複製其他 GPL/AGPL 專案的程式碼、UI 或資料庫內容
- 不把「目前沒有資料」誤判成「支援」

## 分層

| 層 | 負責內容 |
| --- | --- |
| App | SwiftUI 導航、畫面狀態與確認流程 |
| Features | 裝置檢視、功能瀏覽、修改規劃、備份、歷史、Expert Editor |
| Domain | Feature、相容性結果、修改計畫、備份與歷史事件 |
| Services | 偵測、資料庫查詢、相容性判斷、規劃與備份協調 |
| Backends | 唯讀 backend，以及未來可替換的 Write Backend |
| Persistence | 本機檔案/資料庫、版本與 migration |

UI 不可以直接呼叫 Write Backend；所有修改都必須先經過 Domain 與 Service 層。

## 主要流程

1. Detector 建立不可變的 DeviceContext。
2. Feature Repository 取得 FeatureDefinition 快照。
3. Compatibility Engine 根據裝置環境進行判斷。
4. Modification Planner 產生包含前置條件、風險、備份與回復方式的計畫。
5. 使用者檢查並明確確認。
6. Backup Coordinator 建立並驗證備份。
7. Write Backend 回報能力；若不能寫入，必須回傳清楚的唯讀/不支援結果。
8. History 記錄請求、結果、backend 與備份參照。

## 必須遵守的安全規則

- 永遠保留唯讀分析能力。
- 沒有使用者確認，不得發生修改。
- 計畫要說明目標、原值（若已知）、新值、前置條件、風險與回復方式。
- unknown 不得被當成 supported。
- 寫入前必須驗證備份完整性。
- 成功、失敗、拒絕的操作都要寫入 History。
- 預設 backend 永遠是唯讀。

## 測試方向

Domain 使用固定 fixture 做單元測試；Service 使用 fake backend；UI 測試覆蓋計畫確認、不支援裝置、備份失敗與 restore 確認。任何未來的寫入 backend 都必須經過獨立 review、feature flag 與 integration test。

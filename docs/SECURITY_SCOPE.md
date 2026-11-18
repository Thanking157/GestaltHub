# GestaltHub v0.1 安全範圍

## 這份文件是做什麼的？

它把「我們可以研究與實作到哪裡」寫清楚，避免專案在開發過程中不小心從功能工具變成繞過平台安全機制的工具。

GestaltHub 可以讀取裝置資訊，也可以設計未來的使用者確認流程；但 v0.1 的預設行為必須是唯讀。

## 允許

- 唯讀裝置偵測與本機分析
- 高層次的 backend 能力與失敗情境建模
- Backup、Restore 規劃與完整性驗證
- 本機 History 與可稽核紀錄
- 使用者可見的警告與 Expert 確認
- 使用 fixture、fake backend 做防禦性測試

## 不提供

- exploit code 或 exploit chain
- sandbox escape、權限提升、entitlement/signing bypass
- 繞過平台安全機制或規避偵測的操作步驟
- 靜默、遠端或不可逆修改
- 直接複製第三方 GPL/AGPL 專案的實作、UI 或資料

未來若加入任何寫入 backend，必須先寫明授權前提、支援環境、限制、rollback 與錯誤處理，並經過獨立審查。預設 backend 維持唯讀。

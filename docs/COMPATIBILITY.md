# GestaltHub v0.1 Compatibility Engine 規格

## 這份文件是做什麼的？

Compatibility Engine 是「判斷目前環境能不能用某功能」的核心規則層。它不負責寫入，也不直接替使用者做決定；它要做的是給出可解釋的結果與理由。

## 回傳結果

每次判斷包含：

- status：supported、conditional、unsupported、unknown 或 blocked
- reasons：影響結果的可讀理由
- matchedRules：命中的規則 ID
- confidence：這個結論的可信度
- requiredActions：需要偵測、備份、Expert 確認或不需額外動作
- evaluation 時間與資料庫版本

unknown 是正式結果，不是錯誤。缺少資料不能推論成支援。

## 輸入

- Detector 產生的不可變 DeviceContext
- Feature Database 的 FeatureDefinition 快照
- 使用者提出的新值（若有）
- App policy 版本
- Backend capability report

DeviceContext 可包含產品/model、OS、build、硬體家族、明確可取得的地區資訊，以及目前是否為唯讀環境。敏感識別資訊應盡量減少，預設留在本機。

## 規則順序

1. 輸入無效或不完整 → blocked
2. 平台或 OS 明確排除 → unsupported
3. 裝置或 build 明確排除 → unsupported
4. 有可靠支援規則且值有效 → supported
5. 有前置條件或需要 Expert 確認 → conditional
6. 沒有足夠可靠規則 → unknown

若多條規則衝突，以限制較嚴格的結果為主，但要保留所有相關理由。

## 重要限制

Compatibility Engine 的結果只是建議，不代表一定存在可用的寫入 backend，也不代表平台一定接受該值。真正執行前，Planner 必須重新檢查相容性與 backend 能力。

## 測試矩陣

要測試 iPhone/iPad、OS 上下界、未知 build、錯誤型別與範圍、裝置排除、唯讀 backend、缺少 provenance、衝突規則，以及相同輸入是否得到穩定結果。

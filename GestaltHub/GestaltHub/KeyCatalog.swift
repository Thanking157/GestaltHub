/*
 * GestaltHub
 *
 * Copyright (C) 2026 thanking157
 *
 * Original code and integration by thanking157.
 */
import Foundation

enum KeyCatalog {
    // Keys and semantics below are carried from the supplied Erosion and GestaltX sources.
    static let all: [GestaltKey] = [
        .init("YlEtTtHlNesRBMal1CqRaA", "動態島", "", category: .display, risk: .caution),
        .init("gestalthub.artworkSubtype", "動態島類型", "", category: .display, kind: .choice, risk: .caution),
        .init("2OOJf1VhaM7NxfRok3HbWQ", "永遠顯示", "", category: .display, risk: .caution, groupedKeys: ["2OOJf1VhaM7NxfRok3HbWQ", "j8/Omm6s1lsmTDFsXjsBfA"]),
        .init("ykpu7qyhqFweVMKtxNylWA", "AOD 色彩", "調整永遠顯示的色彩／vibrancy 能力。", category: .display, os: "iOS 16.2+"),
        .init("7brdL5xrEUWnlF9C0kdg5A", "高亮度 AOD", "", category: .display),
        .init("aoJSd/MXk7M40NgXTM6x+g", "AOD Flipbook", "", category: .display),
        .init("qqrspu7CpuPdZwSDxNY+Fg", "AOD Flipbook 數量", "", category: .display, kind: .integer, values: ["0", "1", "2", "3"]),
        .init("UIParallaxCapability", "壁紙視差", "", category: .display, groupedKeys: ["UIParallaxCapability"]),
        .init("a1r7npIrhXsZ7SmKRKC1eA", "HDR 照片顯示", "", category: .display),
        .init("6IejgN+1Fmu5/QrZFOIeNw", "PWM", "", category: .display, risk: .experimental),
        .init("CoWnN4xo783YGn4wLrUatA", "DisplayPort", "", category: .display, risk: .experimental),
        .init("SAGvsp6O6kAQ4fEfDJpC4Q", "Liquid Glass 低耗電渲染", "", category: .display),
        .init("h9jDsbgj7xIVeIQ8S3/X3Q", "產品型號", "", category: .device, kind: .choice, risk: .experimental, values: ["iPhone16,1", "iPhone16,2", "iPhone17,3", "iPhone17,4", "iPhone17,1", "iPhone17,2", "iPhone17,5", "iPhone18,3", "iPhone18,1", "iPhone18,2", "iPhone18,4", "iPhone18,5", "iPhone19,2", "iPhone19,3", "iPhone19,4", "iPhone19,7", "iPad14,3", "iPad14,4", "iPad16,3", "iPad16,4"]),
        .init("gestalthub.artworkName", "機型名稱", "自訂「關於本機」中顯示的手機名稱文字", category: .device, kind: .string, risk: .caution),
        .init("oYicEKzVTz4/CxxE05pEgQ", "硬體型號", "修改主機板工程代號 Board ID", category: .device, kind: .string, risk: .caution),
        .init("5pYKlGnYYBzGvAlIU8RjEQ", "CPU", "偽裝處理器晶片代號以繞過功能限制", category: .device, kind: .string, risk: .caution),
        .init("97JDvERpVwO+GHtthIh7hA", "型號編號", "", category: .device, kind: .string, risk: .caution),
        .init("+3Uf0Pm5F8Xy7Onyvko0vA", "裝置類別", "", category: .device, kind: .string),
        .init("yhHcB0iH0d1XzPO/CFd3ow", "Apple Pencil", "設定 Apple Pencil 支援能力。配件與硬體相容性仍由系統判定。", category: .ipad),
        .init("qeaj75wk3HF4DwQ8qbIi7g", "Stage Manager", "設定增強多工／Stage Manager 能力。Erosion 將其用於 iPadOS 能力組合。", category: .ipad, risk: .caution),
        .init("gestalthub.ipadosMode", "iPadOS Mode", "", category: .ipad, risk: .experimental, groupedKeys: ["uKc7FPnEO++lVhHWHFlGbQ", "mG0AnH/Vy1veoqoLRAIgTA", "UCG5MkVahJxG1YULbbd5Bg", "ZYqko/XM5zD3XBfN5RmaXA", "nVh/gwNpy7Jv1NOk00CMrw", "qeaj75wk3HF4DwQ8qbIi7g"]),
        .init("uKc7FPnEO++lVhHWHFlGbQ", "iPad UI", "iPad 裝置類型能力旗標；應搭配多工相關旗標使用。", category: .ipad, risk: .experimental),
        .init("mG0AnH/Vy1veoqoLRAIgTA", "浮動 App 多工", "Medusa Floating Live App 能力。", category: .ipad, risk: .experimental),
        .init("UCG5MkVahJxG1YULbbd5Bg", "多工覆蓋 App", "Medusa Overlay App 能力。", category: .ipad, risk: .experimental),
        .init("ZYqko/XM5zD3XBfN5RmaXA", "釘選 App 多工", "Medusa Pinned App 能力。", category: .ipad, risk: .experimental),
        .init("nVh/gwNpy7Jv1NOk00CMrw", "子母畫面多工", "Medusa Picture in Picture 能力。", category: .ipad, risk: .experimental),
        .init("9MZ5AdH43csAUajl/dU+IQ", "iPad App 相容性", "", category: .ipad, kind: .array),
        .init("A62OafQ85EJAiiqKn4agtg", "Apple Intelligence", "", category: .intelligence, risk: .experimental),
        .init("K/R1GfGfCkXvEhaPS2Vrng", "裝置端 Siri", "", category: .intelligence, kind: .string),
        .init("a3n5T9sFtlyQ74NEp9ESxg", "Siri AI 模式", "", category: .intelligence, kind: .choice, values: ["0", "1", "2"]),
        .init("rb2tKZxlj0Gm2tBmUQSLqQ", "音訊智慧", "", category: .intelligence),
        .init("M1n2sAqf33NAOgZRGxQYBA", "即時翻譯", "", category: .intelligence),
        .init("XNCjqOupLM/S8fNyxRNQTA", "照片清除", "", category: .intelligence),
        .init("YgYIIViDt1kgzyIsIV61vA", "手寫合成", "", category: .intelligence),
        .init("TusANsf9Lfe3P/9fIXXSrQ", "永遠聆聽「嘿 Siri」", "", category: .intelligence),
        .init("h63QSdBCiT/z0WU6rdQv6Q", "地區", "", category: .region, kind: .choice, values: ["美國", "香港", "日本", "台灣", "英國", "加拿大"]),
        .init("zHeENZu+wbg7PUprwNwBWg", "地區資訊", "", category: .region, kind: .string, risk: .caution),
        .init("yK+xavymRGZ3xWc1tb8XDg", "系統地區資訊", "", category: .region, kind: .string, risk: .caution),
        .init("CwvKxM2cEogD3p+HYgaW0Q", "相機控制", "Camera Button 能力與圖形效能等級一起設定。", category: .camera, os: "iOS 18+", risk: .caution, groupedKeys: ["CwvKxM2cEogD3p+HYgaW0Q", "oOV1jhJbdV3AddkcCg0AEA"]),
        .init("QHxt+hGLaBPbQJbXiUJX3w", "開機提示音", "設定啟動提示音支援。", category: .audio),
        .init("aVL5GE3tx0LSCI/ErfrJGA", "Audio Mix", "", category: .audio),
        .init("/EVOCjM/Nmb2roP5ebtEFA", "FaceTime 空間音訊", "", category: .audio),
        .init("37NVydb//GP/GrhuTN+exg", "80% 充電上限", "設定 80% 充電上限能力。充電硬體與系統版本仍會限制實際功能。", category: .system, os: "iOS 17+"),
        .init("HCzWusHQwZDea6nNhaKndw", "碰撞偵測", "設定 Collision SOS 能力。不可取代實際硬體與安全功能。", category: .system, risk: .caution),
        .init("cT44WE1EohiwRzhsZ8xEsw", "動作按鈕", "設定鈴聲／動作按鈕能力。", category: .system, os: "iOS 17+", risk: .caution),
        .init("yZf3GTRMGTuwSV/lD7Cagw", "點一下喚醒", "設定 Tap to Wake 能力。", category: .system),
        .init("EqrsVvjcYDdxHBiQmGhAWw", "內部安裝", "可解鎖部分原生 App 的隱藏除錯選項", category: .advanced, risk: .experimental),
        .init("LBJfwOEzExRxzlAnSuI7eg", "內部組建", "向系統宣告為 Apple 內部編譯版韌體開啟後極易造成系統不穩定", category: .advanced, risk: .experimental),
        .init("Oji6HRoPi7rH7HPdWVakuw", "內部設定", "嘗試顯示系統「設定」中的隱藏工程調整面板", category: .advanced, risk: .experimental),
        .init("XYlJKKkj2hztRP1NWWnhlw", "SRD UI", "模擬 Apple 資安研究專用機的系統介面標示", category: .advanced, risk: .experimental),
        .init("re6Zb+zwFKJNlkQTUeT+/w", "Unique Device ID", "設備的唯一系統識別碼修改可能導致側載 App 驗證異常", category: .advanced, kind: .string, risk: .caution),
        .init("VasUgeSzVyHdB27g2XpN0g", "序號", "修改「關於本機」顯示的設備出廠序號隨意更改可能影響 iMessage 與 Apple 服務", category: .advanced, kind: .string, risk: .caution),
        .init("TF31PAB6aO8KAbPyNKSxKA", "Unique Chip ID", "設備出廠燒錄的唯一硬體 ID（僅供識別與測試用途，修改無法解鎖新功能）", category: .advanced, kind: .string, risk: .caution),
        .init("oOV1jhJbdV3AddkcCg0AEA", "圖形效能等級", "設定 Metal 圖形處理器世代等級，輸入整數（如 7、8、9）以偽裝 GPU 算力", category: .advanced, kind: .unknown)

    ]
}

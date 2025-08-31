-- Aim Script Konfigürasyon Dosyası
-- Bu dosyayı düzenleyerek ayarları değiştirebilirsiniz

return {
    -- Target Aim Ayarları
    TargetAim = {
        Enabled = true,                    -- Target Aim'i etkinleştir
        Key = "T",                        -- Açma/kapama tuşu (T)
        FOV = 120,                        -- Görüş alanı (piksel)
        Priority = "Closest",             -- Hedef önceliği: "Closest", "LowestHealth", "HighestThreat"
        VisibilityCheck = true,           -- Duvar kontrolü
        SmoothAiming = true,              -- Yumuşak nişan alma
        SmoothSpeed = 0.6,                -- Yumuşaklık hızı (0.1-1.0)
        AutoFire = false                  -- Otomatik ateş
    },
    
    -- AimLock Ayarları
    AimLock = {
        Enabled = true,                   -- AimLock'u etkinleştir
        Key = "L",                       -- Açma/kapama tuşu (L)
        FOV = 90,                        -- Kilit FOV'u (Target Aim'den küçük olmalı)
        StickyLock = true,               -- Yapışkan kilit
        AutoSwitch = true,               -- Otomatik hedef değiştirme
        LockTime = 3.0,                  -- Kilit süresi (saniye)
        SmoothTransition = true,         -- Yumuşak geçiş
        TransitionSpeed = 0.4,           -- Geçiş hızı
        RequireLineOfSight = true        -- Görüş hattı gereksinimi
    },
    
    -- Genel Ayarlar
    General = {
        ShowFOV = true,                  -- FOV çemberini göster
        FOVColor = Color3.fromRGB(255, 255, 255),  -- FOV çember rengi
        TargetColor = Color3.fromRGB(255, 0, 0),   -- Hedef işaret rengi
        TeamCheck = true,                -- Takım kontrolü
        WallCheck = true,                -- Duvar kontrolü
        PredictMovement = false,         -- Hareket tahmini
        PredictionStrength = 0.2         -- Tahmin gücü
    },
    
    -- Performans Ayarları
    Performance = {
        UpdateRate = 60,                 -- Güncelleme hızı (FPS)
        MaxTargets = 10,                 -- Maksimum hedef sayısı
        OptimizeForLowEnd = false        -- Düşük sistem optimizasyonu
    }
}
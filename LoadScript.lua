-- LOADER SCRIPT - Orijinal obfuscated script yerine kullanın
-- Bu script Target Aim ve AimLock çakışma sorununu çözer

print("🚀 Aim Script Loader başlatılıyor...")

-- Gerekli dosyaları kontrol et
local function FileExists(path)
    local success, result = pcall(function()
        return readfile and readfile(path)
    end)
    return success and result ~= nil
end

-- Ana scripti yükle
local function LoadMainScript()
    local success, result = pcall(function()
        if FileExists("FixedAimScript.lua") then
            return loadfile("FixedAimScript.lua")()
        else
            -- Eğer dosya yoksa, doğrudan kodu çalıştır
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/your-repo/FixedAimScript.lua"))()
        end
    end)
    
    if success then
        print("✅ Aim Script başarıyla yüklendi!")
        return result
    else
        warn("❌ Script yüklenemedi: " .. tostring(result))
        return nil
    end
end

-- Hızlı düzeltme - Doğrudan çalıştır
local AimScript = LoadMainScript()

if AimScript then
    print("=================================")
    print("🎯 AIM SCRIPT HAZIR!")
    print("=================================")
    print("📌 NASIL KULLANILIR:")
    print("   T = Target Aim Aç/Kapat")
    print("   L = AimLock Aç/Kapat")
    print("   /aim debug = Debug bilgisi")
    print("   /aim reset = Script'i yeniden başlat")
    print("=================================")
    print("🔧 DÜZELTMELER:")
    print("   ✅ Target Aim ile AimLock çakışması çözüldü")
    print("   ✅ Her iki özellik artık birlikte çalışabilir")
    print("   ✅ AimLock öncelikli sistem")
    print("   ✅ Gelişmiş hedef seçimi")
    print("=================================")
else
    print("❌ Script yüklenemedi. Lütfen dosyaları kontrol edin.")
end
# 🎯 Düzeltilmiş Aim Script - Kullanım Kılavuzu

## 🔧 Sorun ve Çözüm

**Sorun:** Target Aim aktifken AimLock çalışmıyordu.

**Çözüm:** Script yeniden yazıldı ve öncelik sistemi eklendi:
- AimLock aktifken Target Aim mouse kontrolünü bırakır
- Her iki özellik birlikte çalışabilir
- Çakışma tamamen çözüldü

## 📁 Dosyalar

1. **`EdxzGenerator`** - Orijinal obfuscated script (sorunlu)
2. **`FixedAimScript.lua`** - Düzeltilmiş ana script
3. **`AimConfig.lua`** - Ayar dosyası
4. **`LoadScript.lua`** - Hızlı yükleme scripti

## 🚀 Kurulum

### Yöntem 1: Hızlı Yükleme
```lua
loadfile("LoadScript.lua")()
```

### Yöntem 2: Manuel Yükleme
```lua
loadfile("FixedAimScript.lua")()
```

## ⌨️ Kontroller

| Tuş | Fonksiyon |
|-----|-----------|
| **T** | Target Aim Aç/Kapat |
| **L** | AimLock Aç/Kapat |

## 💬 Chat Komutları

| Komut | Açıklama |
|-------|----------|
| `/aim debug` | Debug bilgilerini göster |
| `/aim reset` | Script'i yeniden başlat |

## ⚙️ Ayarlar (AimConfig.lua)

### Target Aim Ayarları
```lua
TargetAim = {
    FOV = 120,              -- Görüş alanı
    Priority = "Closest",   -- Hedef önceliği
    SmoothSpeed = 0.6,      -- Yumuşaklık hızı
    SmoothAiming = true     -- Yumuşak nişan alma
}
```

### AimLock Ayarları
```lua
AimLock = {
    FOV = 90,               -- Kilit FOV'u (Target Aim'den küçük)
    LockTime = 3.0,         -- Kilit süresi
    StickyLock = true,      -- Yapışkan kilit
    TransitionSpeed = 0.4   -- Geçiş hızı
}
```

## 🎮 Nasıl Çalışır?

### 1. Normal Kullanım
- **Target Aim (T):** Sürekli en yakın hedefe nişan alır
- **AimLock (L):** Bir hedefe kilitlenir ve belirli süre tutar

### 2. Birlikte Kullanım (DÜZELTME)
- Her iki özellik de aynı anda aktif olabilir
- **AimLock öncelikli:** AimLock aktifken mouse kontrolünü alır
- **Target Aim ikincil:** AimLock yokken devreye girer
- **Çakışma yok:** Artık birbirini engellemezler

### 3. Öncelik Sistemi
```
AimLock AÇIK + Target Aim AÇIK = AimLock kontrol eder
AimLock KAPALI + Target Aim AÇIK = Target Aim kontrol eder
Her ikisi KAPALI = Manuel kontrol
```

## 🔍 Debug ve Sorun Giderme

### Debug Bilgileri
Chat'te `/aim debug` yazarak şu bilgileri görebilirsiniz:
- Target Aim durumu
- AimLock durumu
- Mevcut hedef
- Kilitli hedef

### Yaygın Sorunlar

**1. Mouse hareket etmiyor**
- Executor'ınızın `mousemoverel` ve `mousemoveabs` fonksiyonlarını desteklediğinden emin olun
- Script başlatıldığında uyarı mesajı kontrol edin

**2. Hedef bulunamıyor**
- FOV ayarlarını artırın
- Duvar kontrolünü kapatın (`WallCheck = false`)
- Takım kontrolünü kapatın (`TeamCheck = false`)

**3. Script çalışmıyor**
- `/aim reset` komutu ile yeniden başlatın
- Console'da hata mesajlarını kontrol edin

## 📊 Performans İpuçları

1. **FOV değerlerini optimize edin:**
   - Target Aim FOV: 100-150
   - AimLock FOV: 80-120

2. **Yumuşaklık ayarları:**
   - Hızlı sistem: 0.7-1.0
   - Yavaş sistem: 0.3-0.5

3. **Duvar kontrolü:**
   - Performans için kapatabilirsiniz
   - Gerçekçilik için açık tutun

## 🆘 Destek

Script ile ilgili sorunlar için:
- Discord: discord.gg/gQEH2uZxUk
- Debug komutlarını kullanın
- Console çıktılarını kontrol edin

---

**Not:** Bu script orijinal obfuscated scriptin düzeltilmiş versiyonudur. Target Aim ve AimLock artık birlikte sorunsuz çalışır.
-- DÜZELTILMIŞ AIM SCRIPT
-- Target Aim ve AimLock çakışma sorunu çözüldü
-- Discord: discord.gg/gQEH2uZxUk

-- Konfigürasyon dosyasını yükle
local Config = loadfile("AimConfig.lua")() or {}

-- Varsayılan ayarlar
local DefaultConfig = {
    TargetAim = {
        Enabled = true,
        Key = Enum.KeyCode.T,
        FOV = 120,
        Priority = "Closest",
        SmoothAiming = true,
        SmoothSpeed = 0.6
    },
    AimLock = {
        Enabled = true,
        Key = Enum.KeyCode.L,
        FOV = 90,
        StickyLock = true,
        LockTime = 3.0,
        SmoothTransition = true,
        TransitionSpeed = 0.4
    },
    General = {
        ShowFOV = true,
        TeamCheck = true,
        WallCheck = true
    }
}

-- Konfigürasyonu birleştir
for category, settings in pairs(DefaultConfig) do
    if not Config[category] then Config[category] = {} end
    for key, value in pairs(settings) do
        if Config[category][key] == nil then
            Config[category][key] = value
        end
    end
end

-- Servisler
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Değişkenler
local State = {
    TargetAim = {
        Active = false,
        CurrentTarget = nil,
        LastUpdate = 0
    },
    AimLock = {
        Active = false,
        LockedTarget = nil,
        LockStartTime = 0,
        LastUpdate = 0
    },
    UI = {
        FOVCircle = nil,
        TargetIndicator = nil
    },
    Connections = {}
}

-- Yardımcı Fonksiyonlar
local function CreateDrawing(type, properties)
    local drawing = Drawing.new(type)
    for prop, value in pairs(properties) do
        drawing[prop] = value
    end
    return drawing
end

local function InitializeUI()
    -- FOV Çemberi
    if State.UI.FOVCircle then State.UI.FOVCircle:Remove() end
    State.UI.FOVCircle = CreateDrawing("Circle", {
        Thickness = 2,
        NumSides = 50,
        Radius = Config.TargetAim.FOV,
        Color = Color3.fromRGB(255, 255, 255),
        Transparency = 0.7,
        Visible = false,
        Filled = false
    })
    
    -- Hedef Göstergesi
    if State.UI.TargetIndicator then State.UI.TargetIndicator:Remove() end
    State.UI.TargetIndicator = CreateDrawing("Circle", {
        Thickness = 3,
        NumSides = 20,
        Radius = 5,
        Color = Color3.fromRGB(255, 0, 0),
        Transparency = 1,
        Visible = false,
        Filled = true
    })
end

local function UpdateUI()
    local camera = Workspace.CurrentCamera
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    
    -- FOV Çemberini güncelle
    if State.UI.FOVCircle then
        State.UI.FOVCircle.Position = screenCenter
        
        if State.AimLock.Active then
            State.UI.FOVCircle.Radius = Config.AimLock.FOV
            State.UI.FOVCircle.Color = Color3.fromRGB(255, 100, 100)
        else
            State.UI.FOVCircle.Radius = Config.TargetAim.FOV
            State.UI.FOVCircle.Color = Color3.fromRGB(255, 255, 255)
        end
        
        State.UI.FOVCircle.Visible = Config.General.ShowFOV and (State.TargetAim.Active or State.AimLock.Active)
    end
    
    -- Hedef göstergesini güncelle
    if State.UI.TargetIndicator then
        local target = State.AimLock.LockedTarget or State.TargetAim.CurrentTarget
        if target and target.Player.Character and target.Player.Character:FindFirstChild("Head") then
            local screenPos, onScreen = camera:WorldToScreenPoint(target.Player.Character.Head.Position)
            if onScreen then
                State.UI.TargetIndicator.Position = Vector2.new(screenPos.X, screenPos.Y)
                State.UI.TargetIndicator.Visible = true
                State.UI.TargetIndicator.Color = State.AimLock.Active and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
            else
                State.UI.TargetIndicator.Visible = false
            end
        else
            State.UI.TargetIndicator.Visible = false
        end
    end
end

local function GetValidTargets(fov)
    local targets = {}
    local camera = Workspace.CurrentCamera
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChild("Humanoid")
            local head = character:FindFirstChild("Head")
            
            if humanoid and humanoid.Health > 0 and head then
                -- Takım kontrolü
                if Config.General.TeamCheck and player.Team == LocalPlayer.Team and player.Team ~= nil then
                    continue
                end
                
                local screenPos, onScreen = camera:WorldToScreenPoint(head.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    
                    if distance <= fov then
                        -- Duvar kontrolü
                        if Config.General.WallCheck then
                            local localHead = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
                            if localHead then
                                local ray = Workspace:Raycast(localHead.Position, (head.Position - localHead.Position).Unit * 1000)
                                if ray and not ray.Instance:IsDescendantOf(character) then
                                    continue
                                end
                            end
                        end
                        
                        table.insert(targets, {
                            Player = player,
                            Distance = distance,
                            ScreenPosition = Vector2.new(screenPos.X, screenPos.Y),
                            Health = humanoid.Health,
                            MaxHealth = humanoid.MaxHealth,
                            Character = character
                        })
                    end
                end
            end
        end
    end
    
    return targets
end

local function SelectBestTarget(targets, priority)
    if #targets == 0 then return nil end
    
    if priority == "Closest" then
        table.sort(targets, function(a, b) return a.Distance < b.Distance end)
    elseif priority == "LowestHealth" then
        table.sort(targets, function(a, b) return a.Health < b.Health end)
    elseif priority == "HighestThreat" then
        table.sort(targets, function(a, b) 
            local aThreat = (a.MaxHealth - a.Health) / math.max(a.Distance, 1)
            local bThreat = (b.MaxHealth - b.Health) / math.max(b.Distance, 1)
            return aThreat > bThreat 
        end)
    end
    
    return targets[1]
end

local function SmoothMouseMove(targetPos, speed)
    local currentPos = Vector2.new(Mouse.X, Mouse.Y)
    local delta = targetPos - currentPos
    
    if delta.Magnitude > 1 then
        local moveAmount = delta * speed
        if mousemoverel then
            mousemoverel(moveAmount.X, moveAmount.Y)
        end
    end
end

-- Ana Sistem Fonksiyonları
local function UpdateTargetAim()
    if not State.TargetAim.Active then return end
    
    local currentTime = tick()
    if currentTime - State.TargetAim.LastUpdate < (1/60) then return end -- 60 FPS limit
    State.TargetAim.LastUpdate = currentTime
    
    local targets = GetValidTargets(Config.TargetAim.FOV)
    local target = SelectBestTarget(targets, Config.TargetAim.Priority)
    
    State.TargetAim.CurrentTarget = target
    
    -- ÖNEMLI: AimLock aktifse Target Aim mouse kontrolünü bırak
    if target and not State.AimLock.Active then
        if Config.TargetAim.SmoothAiming then
            SmoothMouseMove(target.ScreenPosition, Config.TargetAim.SmoothSpeed)
        elseif mousemoveabs then
            mousemoveabs(target.ScreenPosition.X, target.ScreenPosition.Y)
        end
    end
end

local function UpdateAimLock()
    if not State.AimLock.Active then return end
    
    local currentTime = tick()
    if currentTime - State.AimLock.LastUpdate < (1/60) then return end -- 60 FPS limit
    State.AimLock.LastUpdate = currentTime
    
    -- Mevcut kilidi kontrol et
    if State.AimLock.LockedTarget then
        local target = State.AimLock.LockedTarget
        local timeSinceLock = currentTime - State.AimLock.LockStartTime
        
        -- Hedef hala geçerli mi kontrol et
        if target.Character and target.Character.Parent and target.Character:FindFirstChild("Head") then
            local humanoid = target.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local camera = Workspace.CurrentCamera
                local screenPos, onScreen = camera:WorldToScreenPoint(target.Character.Head.Position)
                
                if onScreen then
                    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    
                    -- FOV içinde ve süre dolmamışsa kilidi sürdür
                    if distance <= Config.AimLock.FOV and timeSinceLock < Config.AimLock.LockTime then
                        target.ScreenPosition = Vector2.new(screenPos.X, screenPos.Y)
                        
                        if Config.AimLock.SmoothTransition then
                            SmoothMouseMove(target.ScreenPosition, Config.AimLock.TransitionSpeed)
                        elseif mousemoveabs then
                            mousemoveabs(target.ScreenPosition.X, target.ScreenPosition.Y)
                        end
                        return
                    end
                end
            end
        end
        
        -- Kilidi kaldır
        State.AimLock.LockedTarget = nil
        print("AimLock: Hedef kilidi kaldırıldı")
    end
    
    -- Yeni hedef ara
    local targets = GetValidTargets(Config.AimLock.FOV)
    local target = SelectBestTarget(targets, "Closest")
    
    if target then
        State.AimLock.LockedTarget = target
        State.AimLock.LockStartTime = currentTime
        print("AimLock: Yeni hedef kilitlendi - " .. target.Player.Name)
        
        if Config.AimLock.SmoothTransition then
            SmoothMouseMove(target.ScreenPosition, Config.AimLock.TransitionSpeed)
        elseif mousemoveabs then
            mousemoveabs(target.ScreenPosition.X, target.ScreenPosition.Y)
        end
    end
end

-- Ana Güncelleme Döngüsü
local function MainUpdate()
    UpdateUI()
    
    -- ÇAKIŞMA ÇÖZÜMÜ: AimLock öncelikli, Target Aim ikincil
    if State.AimLock.Active then
        UpdateAimLock()
        -- AimLock aktifken Target Aim sadece hedef bulma için çalışır
        if State.TargetAim.Active then
            local targets = GetValidTargets(Config.TargetAim.FOV)
            State.TargetAim.CurrentTarget = SelectBestTarget(targets, Config.TargetAim.Priority)
        end
    elseif State.TargetAim.Active then
        UpdateTargetAim()
    end
end

-- Giriş İşleyicileri
local function OnKeyPressed(input, gameProcessed)
    if gameProcessed then return end
    
    local keyName = input.KeyCode.Name:upper()
    
    -- Target Aim toggle
    if keyName == Config.TargetAim.Key:upper() then
        State.TargetAim.Active = not State.TargetAim.Active
        print("🎯 Target Aim: " .. (State.TargetAim.Active and "AÇIK" or "KAPALI"))
        
        if not State.TargetAim.Active then
            State.TargetAim.CurrentTarget = nil
        end
    end
    
    -- AimLock toggle
    if keyName == Config.AimLock.Key:upper() then
        State.AimLock.Active = not State.AimLock.Active
        print("🔒 AimLock: " .. (State.AimLock.Active and "AÇIK" or "KAPALI"))
        
        if State.AimLock.Active then
            State.AimLock.LockStartTime = tick()
        else
            State.AimLock.LockedTarget = nil
        end
    end
end

-- Mouse işlevlerini kontrol et
local function CheckMouseFunctions()
    local hasMouseMove = false
    
    if mousemoverel and mousemoveabs then
        hasMouseMove = true
    elseif mouse1click and mouse1press and mouse1release then
        -- Bazı executor'lar için alternatif
        hasMouseMove = true
    end
    
    if not hasMouseMove then
        warn("⚠️ Mouse hareket fonksiyonları bulunamadı!")
        warn("Executor'ınızın mousemoverel ve mousemoveabs fonksiyonlarını desteklediğinden emin olun.")
    end
    
    return hasMouseMove
end

-- Başlatma
local function Initialize()
    print("=================================")
    print("🎮 DÜZELTILMIŞ AIM SCRIPT")
    print("=================================")
    print("📋 Özellikler:")
    print("   • Target Aim: " .. Config.TargetAim.Key .. " tuşu")
    print("   • AimLock: " .. Config.AimLock.Key .. " tuşu")
    print("   • FOV Gösterimi: " .. (Config.General.ShowFOV and "Aktif" or "Pasif"))
    print("   • Takım Kontrolü: " .. (Config.General.TeamCheck and "Aktif" or "Pasif"))
    print("   • Duvar Kontrolü: " .. (Config.General.WallCheck and "Aktif" or "Pasif"))
    print("=================================")
    print("🔧 DÜZELTMELER:")
    print("   ✅ Target Aim + AimLock çakışması çözüldü")
    print("   ✅ Öncelik sistemi eklendi (AimLock > Target Aim)")
    print("   ✅ Gelişmiş hedef seçimi")
    print("   ✅ Performans optimizasyonu")
    print("=================================")
    
    -- Mouse fonksiyonlarını kontrol et
    if not CheckMouseFunctions() then
        return false
    end
    
    -- UI'yi başlat
    InitializeUI()
    
    -- Bağlantıları kur
    State.Connections.Input = UserInputService.InputBegan:Connect(OnKeyPressed)
    State.Connections.Update = RunService.Heartbeat:Connect(MainUpdate)
    
    print("✅ Script başarıyla yüklendi!")
    print("💡 İpucu: AimLock aktifken Target Aim mouse kontrolünü bırakır")
    
    return true
end

-- Temizlik
local function Cleanup()
    print("🧹 Script temizleniyor...")
    
    -- Bağlantıları kes
    for name, connection in pairs(State.Connections) do
        if connection then
            connection:Disconnect()
        end
    end
    State.Connections = {}
    
    -- UI'yi temizle
    if State.UI.FOVCircle then
        State.UI.FOVCircle:Remove()
        State.UI.FOVCircle = nil
    end
    
    if State.UI.TargetIndicator then
        State.UI.TargetIndicator:Remove()
        State.UI.TargetIndicator = nil
    end
    
    -- Durumu sıfırla
    State.TargetAim.Active = false
    State.AimLock.Active = false
    State.TargetAim.CurrentTarget = nil
    State.AimLock.LockedTarget = nil
    
    print("✅ Temizlik tamamlandı")
end

-- Hata yakalama ile başlat
local success, error = pcall(Initialize)
if not success then
    warn("❌ Script başlatılamadı: " .. tostring(error))
else
    -- Oyuncu ayrıldığında temizle
    Players.PlayerRemoving:Connect(function(player)
        if player == LocalPlayer then
            Cleanup()
        end
    end)
    
    -- Script durdurulduğunda temizle
    game:BindToClose(Cleanup)
end

-- Debug komutları (chat'te kullanılabilir)
local function OnChatted(message)
    local msg = message:lower()
    
    if msg == "/aim debug" then
        print("=== AIM SCRIPT DEBUG ===")
        print("Target Aim: " .. tostring(State.TargetAim.Active))
        print("AimLock: " .. tostring(State.AimLock.Active))
        print("Current Target: " .. (State.TargetAim.CurrentTarget and State.TargetAim.CurrentTarget.Player.Name or "None"))
        print("Locked Target: " .. (State.AimLock.LockedTarget and State.AimLock.LockedTarget.Player.Name or "None"))
        print("========================")
    elseif msg == "/aim reset" then
        Cleanup()
        wait(1)
        Initialize()
        print("🔄 Script yeniden başlatıldı")
    end
end

if LocalPlayer.Chatted then
    LocalPlayer.Chatted:Connect(OnChatted)
end

return {
    Config = Config,
    State = State,
    Cleanup = Cleanup,
    Initialize = Initialize
}
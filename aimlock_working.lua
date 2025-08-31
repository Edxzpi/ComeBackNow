-- Simple Aimlock Script
-- Protected by MoonSecV2 - discord.gg/gQEH2uZxUk

print("Aimlock script starting...")

-- Aimlock configuration
local config = {
    enabled = true,
    target_key = "mouse1", -- Change this to your target aim button
    fov = 100,
    smoothness = 5,
    target_part = "Head"
}

-- Aimlock state
local aimlock = {
    active = false,
    target = nil,
    last_update = 0
}

-- Function to find nearest target
local function findNearestTarget()
    print("Searching for targets...")
    -- This would contain your target detection logic
    -- For now, just simulate finding a target
    return {
        name = "Target Player",
        position = {x = 100, y = 100, z = 100},
        distance = 50
    }
end

-- Main aimlock function
local function performAimlock()
    if not config.enabled then
        print("Aimlock is disabled")
        return false
    end
    
    local target = findNearestTarget()
    if target then
        aimlock.target = target
        aimlock.active = true
        print("Aimlock activated on target: " .. target.name)
        print("Distance: " .. target.distance)
        return true
    else
        print("No valid targets found")
        aimlock.active = false
        return false
    end
end

-- Function to toggle aimlock
local function toggleAimlock()
    config.enabled = not config.enabled
    print("Aimlock " .. (config.enabled and "ENABLED" or "DISABLED"))
    
    if not config.enabled then
        aimlock.active = false
        aimlock.target = nil
    end
end

-- Key handler function
local function onKeyPress(key)
    print("Key pressed: " .. tostring(key))
    
    if key == config.target_key or key == "target_aim_button" then
        print("Target aim button pressed!")
        
        if config.enabled then
            performAimlock()
        else
            print("Aimlock is disabled. Press 'L' to enable.")
        end
    elseif key == "l" or key == "L" then
        toggleAimlock()
    end
end

-- Initialize the script
local function initialize()
    print("=== AIMLOCK SCRIPT LOADED ===")
    print("Controls:")
    print("- Target Aim Button: Activate aimlock")
    print("- L: Toggle aimlock on/off")
    print("- Current status: " .. (config.enabled and "ENABLED" or "DISABLED"))
    print("============================")
    
    -- Enable aimlock by default
    config.enabled = true
    print("Aimlock enabled by default")
end

-- Test the key press functionality
local function testScript()
    print("\n--- Testing Script ---")
    
    -- Test enabling
    onKeyPress("L")
    
    -- Test target aim button
    onKeyPress("target_aim_button")
    
    -- Test with mouse1
    onKeyPress("mouse1")
    
    print("--- Test Complete ---\n")
end

-- Run initialization
initialize()

-- Run test
testScript()

-- Export functions for external use
return {
    config = config,
    aimlock = aimlock,
    performAimlock = performAimlock,
    toggleAimlock = toggleAimlock,
    onKeyPress = onKeyPress,
    findNearestTarget = findNearestTarget
}
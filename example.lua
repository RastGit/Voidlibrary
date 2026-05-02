--[[
    Voidlibrary — EXAMPLE SCRIPT
    ══════════════════════════════════════════════════════════════
    GitHub: https://github.com/RastGit/Voidlibrary
    ══════════════════════════════════════════════════════════════
--]]

-- Load library
local Voidlibrary = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/RastGit/Voidlibrary/main/Library.lua"
))()

-- Create window
local Window = Voidlibrary:CreateWindow({
    Name         = "Home",
    PlayerName   = game.Players.LocalPlayer.Name,
    WelcomeText  = "Good morning,",
    Subtitle     = "Roblox member for 8 months",
    -- Icon = "rbxassetid://YOUR_ICON_ID", -- opcjonalnie
})

-- ══════════════════════════════════════════════════════════════
-- TAB 1: COMBAT
-- ══════════════════════════════════════════════════════════════
local CombatTab = Window:AddTab({
    Name = "Combat",
    Icon = "rbxasset://textures/ui/GuiImagePlaceholder.png",
})

local AimbotSection = CombatTab:AddSection("Aimbot")

AimbotSection:AddToggle({
    Name        = "Enable Aimbot",
    Description = "Auto aim at players",
    Default     = false,
    Flag        = "Aimbot",
    Callback    = function(state)
        print("Aimbot:", state)
    end,
})

AimbotSection:AddSlider({
    Name     = "FOV",
    Min      = 10,
    Max      = 360,
    Default  = 90,
    Suffix   = "°",
    Flag     = "AimbotFOV",
    Callback = function(v)
        print("FOV:", v)
    end,
})

-- ══════════════════════════════════════════════════════════════
-- TAB 2: PLAYER
-- ══════════════════════════════════════════════════════════════
local PlayerTab = Window:AddTab({
    Name = "Player",
    Icon = "rbxasset://textures/ui/GuiImagePlaceholder.png",
})

local MoveSection = PlayerTab:AddSection("Movement")

MoveSection:AddSlider({
    Name     = "WalkSpeed",
    Min      = 16,
    Max      = 500,
    Default  = 16,
    Flag     = "WalkSpeed",
    Callback = function(v)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char.Humanoid.WalkSpeed = v
        end
    end,
})

MoveSection:AddButton({
    Name        = "Reset Character",
    Description = "Respawn your character",
    Callback    = function()
        game.Players.LocalPlayer:LoadCharacter()
    end,
})

-- ══════════════════════════════════════════════════════════════
-- TAB 3: SETTINGS
-- ══════════════════════════════════════════════════════════════
local SettingsTab = Window:AddTab({
    Name = "Settings",
    Icon = "rbxasset://textures/ui/GuiImagePlaceholder.png",
})

local InfoSection = SettingsTab:AddSection("Info")

InfoSection:AddLabel("Voidlibrary v1.0.0")
InfoSection:AddLabel("Author: RatRoblox_404")

InfoSection:AddButton({
    Name     = "Destroy UI",
    Callback = function()
        Voidlibrary:Destroy()
    end,
})

print("[Voidlibrary] Loaded successfully!")

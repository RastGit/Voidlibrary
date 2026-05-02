# Voidlibrary

> **Modern Roblox UI Library** — Style inspired by Roblox's native interface (2024+)

[![Version](https://img.shields.io/badge/version-1.0.0-55AAFF?style=flat-square)](https://github.com/RastGit/Voidlibrary)
[![Platform](https://img.shields.io/badge/platform-PC%20%2B%20Mobile-brightgreen?style=flat-square)](https://github.com/RastGit/Voidlibrary)
[![Author](https://img.shields.io/badge/author-RatRoblox__404-white?style=flat-square)](https://github.com/RastGit/Voidlibrary)

Zaawansowana biblioteka UI do Roblox w stylu natywnego interfejsu Roblox.  
Ciemne panele, zaokrąglone rogi, avatar gracza, bottom navigation — wszystko wzorowane na oficjalnym UI Roblox.

**✅ Wsparcie PC + Mobile**

---

## 🚀 Szybki start

```lua
local Voidlibrary = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/RastGit/Voidlibrary/main/Library.lua"
))()

local Window = Voidlibrary:CreateWindow({
    Name        = "Home",
    PlayerName  = game.Players.LocalPlayer.Name,
    WelcomeText = "Good morning,",
    Subtitle    = "Roblox member for 8 months",
})

local Tab = Window:AddTab({ Name = "Main" })
local Section = Tab:AddSection("Features")

Section:AddToggle({
    Name     = "My Feature",
    Default  = false,
    Callback = function(state)
        print("State:", state)
    end,
})
```

---

## 📁 Struktura

```
Voidlibrary/
├── Library.lua    ← Główna biblioteka
├── Example.lua    ← Przykładowy skrypt
└── README.md      ← Dokumentacja
```

---

## 📖 API

### `Voidlibrary:CreateWindow(config)`

Tworzy główne okno.

| Parametr | Typ | Opis | Domyślnie |
|---|---|---|---|
| `Name` | string | Nazwa okna (np. "Home") | `"Home"` |
| `PlayerName` | string | Nazwa gracza | `LocalPlayer.Name` |
| `WelcomeText` | string | Tekst powitania | `"Good morning,"` |
| `Subtitle` | string | Podtytuł (np. status) | `""` |
| `Icon` | string | URL/rbxassetid avatara | auto (headshot) |

```lua
local Window = Voidlibrary:CreateWindow({
    Name        = "Home",
    PlayerName  = "RatRoblox_404",
    WelcomeText = "Good afternoon,",
    Subtitle    = "Premium member",
})
```

---

### `Window:AddTab(config)`

Dodaje zakładkę (tab) w bottom navigation.

| Parametr | Typ | Opis |
|---|---|---|
| `Name` | string | Nazwa zakładki |
| `Icon` | string | rbxassetid ikony |

```lua
local MyTab = Window:AddTab({
    Name = "Combat",
    Icon = "rbxasset://textures/ui/GuiImagePlaceholder.png",
})
```

---

### `Tab:AddSection(name)`

Dodaje sekcję.

```lua
local Section = MyTab:AddSection("Settings")
```

---

## 🎨 Elementy UI

### Toggle

```lua
Section:AddToggle({
    Name        = "Aimbot",
    Description = "Auto aim at enemies",
    Default     = false,
    Flag        = "AimbotEnabled",
    Callback    = function(state)
        print("Aimbot:", state)
    end,
})
```

### Slider

```lua
Section:AddSlider({
    Name     = "WalkSpeed",
    Min      = 16,
    Max      = 500,
    Default  = 16,
    Suffix   = " sp",
    Flag     = "WalkSpeed",
    Callback = function(value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end,
})
```

### Button

```lua
Section:AddButton({
    Name        = "Reset",
    Description = "Respawn character",
    Callback    = function()
        game.Players.LocalPlayer:LoadCharacter()
    end,
})
```

### Label

```lua
Section:AddLabel("Version: 1.0.0")
```

---

## 🏴 System Flag

```lua
-- Każdy element z Flag zapisuje wartość w Voidlibrary.Flags
print(Voidlibrary.Flags["AimbotEnabled"])  -- true/false
print(Voidlibrary.Flags["WalkSpeed"])      -- 100

-- Loop check
game:GetService("RunService").Heartbeat:Connect(function()
    if Voidlibrary.Flags["Noclip"] then
        -- kod noclip
    end
end)
```

---

## 📱 Mobile Support

Biblioteka automatycznie dostosowuje rozmiar i layout na urządzeniach mobilnych:
- Większe buttony (łatwiejsze touch)
- Responsywny layout
- Brak draggable na mobile (auto-centered)

---

## 🗑️ Zniszczenie UI

```lua
Voidlibrary:Destroy()  -- usuwa wszystkie okna
```

---

## ℹ️ Info

- **Autor:** RatRoblox_404 / Novoline
- **Wersja:** 1.0.0
- **Styl:** Roblox Native Interface (2024+)
- **Repo:** https://github.com/RastGit/Voidlibrary

---

*"Simple, modern, Roblox-styled."*

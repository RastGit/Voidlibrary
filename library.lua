-- // Voidlibrary v1.0
-- // USED BY ERROR404 TEAM
-- // https://github.com/RastGit/Voidlibrary

--> Wait for game to fully load first (critical!)
if not game:IsLoaded() then
    game.Loaded:Wait()
end

--> Services
local Players        = game:GetService("Players")
local TweenService   = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService     = game:GetService("RunService")
local CoreGui        = game:GetService("CoreGui")

--> Local player (safe wait)
local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    Players.PlayerAdded:Wait()
    LocalPlayer = Players.LocalPlayer
end

--> Detect mobile
local function IsMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

-- ============================================================
--  HELPER: Create Instance
-- ============================================================
local function Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "Parent" then
            obj[k] = v
        end
    end
    if props.Parent then
        obj.Parent = props.Parent
    end
    return obj
end

-- ============================================================
--  HELPER: Tween
-- ============================================================
local function Tween(obj, goal, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), goal):Play()
end

-- ============================================================
--  HELPER: Draggable (PC only)
-- ============================================================
local function MakeDraggable(topbar, window)
    if IsMobile() then return end
    local dragging = false
    local dragStart, startPos

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos  = window.Position
        end
    end)

    topbar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            window.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ============================================================
--  THEME  (dark, matches screenshots)
-- ============================================================
local Theme = {
    Bg          = Color3.fromRGB(18, 20, 25),      -- main background
    Panel       = Color3.fromRGB(26, 28, 35),      -- cards / sections
    PanelAlt    = Color3.fromRGB(32, 35, 44),      -- row hover / darker panel
    Border      = Color3.fromRGB(45, 50, 63),      -- subtle borders
    Accent      = Color3.fromRGB(82, 168, 255),    -- blue highlight (like screenshots)
    AccentDim   = Color3.fromRGB(45, 100, 180),    -- darker accent
    White       = Color3.fromRGB(240, 242, 248),   -- primary text
    Gray        = Color3.fromRGB(148, 153, 172),   -- secondary text
    Muted       = Color3.fromRGB(80,  85,  102),   -- muted text / icons
    Success     = Color3.fromRGB(72,  199, 116),
    Danger      = Color3.fromRGB(255, 85,  85),
    Warning     = Color3.fromRGB(255, 176, 55),
    ToggleOn    = Color3.fromRGB(82, 168, 255),
    ToggleOff   = Color3.fromRGB(50,  55,  68),
    Knob        = Color3.fromRGB(240, 242, 248),
}

-- ============================================================
--  LIBRARY TABLE
-- ============================================================
local Voidlibrary = {}
Voidlibrary.Flags = {}

-- ============================================================
--  NOTIFICATIONS  (real UI, bottom-right)
-- ============================================================
local NotifGui, NotifHolder

local function EnsureNotifGui()
    if NotifGui and NotifGui.Parent then return end

    NotifGui = Instance.new("ScreenGui")
    NotifGui.Name = "VoidNotifs"
    NotifGui.ResetOnSpawn = false
    NotifGui.DisplayOrder = 9999
    NotifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    NotifGui.IgnoreGuiInset = true

    local ok = pcall(function() NotifGui.Parent = CoreGui end)
    if not ok then NotifGui.Parent = LocalPlayer.PlayerGui end

    NotifHolder = Create("Frame", {
        Parent = NotifGui,
        Size   = UDim2.new(0, 300, 1, 0),
        Position = UDim2.new(1, -310, 0, 0),
        BackgroundTransparency = 1,
    })
    Create("UIListLayout", {
        Parent = NotifHolder,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 8),
    })
    Create("UIPadding", {
        Parent = NotifHolder,
        PaddingBottom = UDim.new(0, 20),
    })
end

function Voidlibrary:Notify(cfg)
    EnsureNotifGui()
    cfg = cfg or {}
    local title    = cfg.Title or "Voidlibrary"
    local content  = cfg.Content or cfg.Description or ""
    local duration = cfg.Duration or 4
    local ntype    = cfg.Type or "Default"

    local colors = {
        Default = Theme.Accent,
        Success = Theme.Success,
        Warning = Theme.Warning,
        Error   = Theme.Danger,
    }
    local barColor = colors[ntype] or Theme.Accent

    -- Card
    local card = Create("Frame", {
        Parent = NotifHolder,
        Size   = UDim2.new(1, 0, 0, content ~= "" and 72 or 52),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        BackgroundTransparency = 1, -- fade in
    })
    Create("UICorner",  { CornerRadius = UDim.new(0, 10), Parent = card })
    Create("UIStroke",  { Color = Theme.Border, Thickness = 1, Parent = card })

    -- Left accent bar
    Create("Frame", {
        Parent = card,
        Size   = UDim2.new(0, 3, 1, -12),
        Position = UDim2.new(0, 0, 0, 6),
        BackgroundColor3 = barColor,
        BorderSizePixel = 0,
    })

    Create("TextLabel", {
        Parent = card,
        Text   = title,
        Font   = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Theme.White,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Size   = UDim2.new(1, -22, 0, 18),
        Position = UDim2.new(0, 14, 0, content ~= "" and 10 or 17),
    })

    if content ~= "" then
        Create("TextLabel", {
            Parent = card,
            Text   = content,
            Font   = Enum.Font.Gotham,
            TextSize = 11,
            TextColor3 = Theme.Gray,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            BackgroundTransparency = 1,
            Size   = UDim2.new(1, -22, 0, 28),
            Position = UDim2.new(0, 14, 0, 30),
        })
    end

    -- Progress bar
    local progBg = Create("Frame", {
        Parent = card,
        Size   = UDim2.new(1, -14, 0, 2),
        Position = UDim2.new(0, 14, 1, -8),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = progBg })
    local progFill = Create("Frame", {
        Parent = progBg,
        Size   = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = barColor,
        BorderSizePixel = 0,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = progFill })

    -- Animate in
    Tween(card, { BackgroundTransparency = 0 }, 0.3)
    Tween(progFill, { Size = UDim2.new(0, 0, 1, 0) }, duration, Enum.EasingStyle.Linear, Enum.EasingDirection.None)

    task.delay(duration, function()
        Tween(card, { BackgroundTransparency = 1 }, 0.3)
        task.wait(0.35)
        card:Destroy()
    end)
end

-- ============================================================
--  CREATE WINDOW
-- ============================================================
function Voidlibrary:CreateWindow(cfg)
    cfg = cfg or {}

    -- Config
    local windowTitle   = cfg.Name or "Home"
    local playerName    = cfg.PlayerName or LocalPlayer.DisplayName or LocalPlayer.Name
    local welcomeText   = cfg.WelcomeText or "Good morning,"
    local memberText    = cfg.MemberText or ""   -- e.g. "Roblox member for 8 months"
    local avatarId      = cfg.Avatar   -- optional rbxassetid://... string

    -- Size
    local winW, winH = 640, 460
    if IsMobile() then winW, winH = 360, 540 end
    if cfg.Size then
        winW = cfg.Size.X.Offset ~= 0 and cfg.Size.X.Offset or winW
        winH = cfg.Size.Y.Offset ~= 0 and cfg.Size.Y.Offset or winH
    end

    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Voidlibrary"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 1000
    ScreenGui.IgnoreGuiInset = true

    local ok = pcall(function() ScreenGui.Parent = CoreGui end)
    if not ok then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Root window frame
    local Win = Create("Frame", {
        Parent = ScreenGui,
        Size   = UDim2.new(0, winW, 0, winH),
        Position = UDim2.new(0.5, -winW/2, 0.5, -winH/2),
        BackgroundColor3 = Theme.Bg,
        BorderSizePixel = 0,
        ClipsDescendants = false,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 14), Parent = Win })
    Create("UIStroke",  { Color = Theme.Border, Thickness = 1, Parent = Win })

    -- ──────────────────────────────────────────────────────────
    --  HEADER  (dark panel, avatar, name — like screenshot 3)
    -- ──────────────────────────────────────────────────────────
    local headerH = 110
    local Header = Create("Frame", {
        Parent = Win,
        Size   = UDim2.new(1, 0, 0, headerH),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        ZIndex = 2,
        ClipsDescendants = true,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 14), Parent = Header })
    -- square out bottom corners
    Create("Frame", {
        Parent = Header,
        Size   = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 1, -14),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        ZIndex = 3,
    })
    -- bottom divider line
    Create("Frame", {
        Parent = Header,
        Size   = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        ZIndex = 4,
    })

    -- Window title top-left
    Create("TextLabel", {
        Parent = Header,
        Text   = windowTitle,
        Font   = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = Theme.White,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Size   = UDim2.new(0.6, 0, 0, 22),
        Position = UDim2.new(0, 18, 0, 14),
        ZIndex = 4,
    })

    -- Welcome text
    Create("TextLabel", {
        Parent = Header,
        Text   = welcomeText,
        Font   = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Theme.Gray,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Size   = UDim2.new(0.6, 0, 0, 16),
        Position = UDim2.new(0, 18, 0, 46),
        ZIndex = 4,
    })

    -- Player name (big, bold)
    Create("TextLabel", {
        Parent = Header,
        Text   = playerName,
        Font   = Enum.Font.GothamBold,
        TextSize = 20,
        TextColor3 = Theme.White,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Size   = UDim2.new(0.7, 0, 0, 26),
        Position = UDim2.new(0, 18, 0, 62),
        ZIndex = 4,
    })

    -- Member text (small, muted, like "Roblox member for 8 months")
    if memberText ~= "" then
        Create("TextLabel", {
            Parent = Header,
            Text   = memberText,
            Font   = Enum.Font.Gotham,
            TextSize = 10,
            TextColor3 = Theme.Muted,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Size   = UDim2.new(0.7, 0, 0, 14),
            Position = UDim2.new(0, 18, 0, 90),
            ZIndex = 4,
        })
    end

    -- Avatar circle (right side of header)
    local avatarFrame = Create("Frame", {
        Parent = Header,
        Size   = UDim2.new(0, 68, 0, 68),
        Position = UDim2.new(1, -88, 0.5, -34),
        BackgroundColor3 = Theme.PanelAlt,
        BorderSizePixel = 0,
        ZIndex = 4,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = avatarFrame })
    Create("UIStroke",  { Color = Theme.Accent, Thickness = 2, Parent = avatarFrame })

    local avatarImg = Create("ImageLabel", {
        Parent = avatarFrame,
        Size   = UDim2.new(1, -4, 1, -4),
        Position = UDim2.new(0, 2, 0, 2),
        BackgroundTransparency = 1,
        Image  = avatarId or ("rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"),
        ZIndex = 5,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = avatarImg })

    -- Draggable by header
    MakeDraggable(Header, Win)

    -- ──────────────────────────────────────────────────────────
    --  BOTTOM NAV BAR  (icon tabs — like screenshots)
    -- ──────────────────────────────────────────────────────────
    local navH = 56
    local NavBar = Create("Frame", {
        Parent = Win,
        Size   = UDim2.new(1, 0, 0, navH),
        Position = UDim2.new(0, 0, 1, -navH),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        ZIndex = 5,
        ClipsDescendants = true,
    })
    Create("UICorner",  { CornerRadius = UDim.new(0, 14), Parent = NavBar })
    -- square top corners
    Create("Frame", {
        Parent = NavBar,
        Size   = UDim2.new(1, 0, 0, 14),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        ZIndex = 6,
    })
    -- top divider
    Create("Frame", {
        Parent = NavBar,
        Size   = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        ZIndex = 7,
    })

    local NavLayout = Create("UIListLayout", {
        Parent = NavBar,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 0),
    })

    -- ──────────────────────────────────────────────────────────
    --  CONTENT AREA  (scrollable, between header and nav)
    -- ──────────────────────────────────────────────────────────
    local Content = Create("ScrollingFrame", {
        Parent = Win,
        Size   = UDim2.new(1, 0, 1, -(headerH + navH + 1)),
        Position = UDim2.new(0, 0, 0, headerH + 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ZIndex = 2,
    })
    Create("UIPadding", {
        Parent = Content,
        PaddingTop    = UDim.new(0, 14),
        PaddingLeft   = UDim.new(0, 14),
        PaddingRight  = UDim.new(0, 14),
        PaddingBottom = UDim.new(0, 14),
    })
    local ContentLayout = Create("UIListLayout", {
        Parent = Content,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
    })

    -- ──────────────────────────────────────────────────────────
    --  WINDOW OBJECT
    -- ──────────────────────────────────────────────────────────
    local WindowObj   = {}
    WindowObj._tabs   = {}
    WindowObj._active = nil
    WindowObj._gui    = ScreenGui

    -- ──────────────────────────────────────────────────────────
    --  ADD TAB
    -- ──────────────────────────────────────────────────────────
    function WindowObj:AddTab(tabCfg)
        tabCfg = tabCfg or {}
        local tabName = tabCfg.Name or ("Tab " .. (#self._tabs + 1))
        local tabIcon = tabCfg.Icon -- rbxassetid:// string or rbxasset:// for builtin

        -- Nav button (equal width split)
        local navBtn = Create("TextButton", {
            Parent = NavBar,
            Size   = UDim2.new(1 / math.max(1, 8), 0, 1, -10), -- max 8 tabs
            BackgroundTransparency = 1,
            Text   = "",
            ZIndex = 8,
        })

        -- Icon
        local iconLbl
        if tabIcon then
            iconLbl = Create("ImageLabel", {
                Parent = navBtn,
                Size   = UDim2.new(0, 22, 0, 22),
                Position = UDim2.new(0.5, -11, 0, 5),
                BackgroundTransparency = 1,
                Image  = tabIcon,
                ImageColor3 = Theme.Muted,
                ZIndex = 9,
            })
        else
            iconLbl = Create("TextLabel", {
                Parent = navBtn,
                Text   = tabName:sub(1, 1):upper(),
                Font   = Enum.Font.GothamBold,
                TextSize = 14,
                TextColor3 = Theme.Muted,
                BackgroundTransparency = 1,
                Size   = UDim2.new(1, 0, 0, 22),
                Position = UDim2.new(0, 0, 0, 5),
                ZIndex = 9,
            })
        end

        -- Active dot
        local dot = Create("Frame", {
            Parent = navBtn,
            Size   = UDim2.new(0, 5, 0, 5),
            Position = UDim2.new(0.5, -2.5, 1, -8),
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            ZIndex = 9,
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = dot })

        -- Tab content container
        local tabFrame = Create("Frame", {
            Parent = Content,
            Size   = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Visible = false,
        })
        Create("UIListLayout", {
            Parent = tabFrame,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
        })

        local TabObj    = {}
        TabObj._frame   = tabFrame
        TabObj._btn     = navBtn
        TabObj._icon    = iconLbl
        TabObj._dot     = dot
        TabObj._count   = 0

        local function SetActive()
            -- deactivate all
            for _, t in ipairs(self._tabs) do
                t._frame.Visible = false
                if t._icon:IsA("ImageLabel") then
                    Tween(t._icon, { ImageColor3 = Theme.Muted }, 0.15)
                else
                    Tween(t._icon, { TextColor3 = Theme.Muted }, 0.15)
                end
                Tween(t._dot, { BackgroundTransparency = 1 }, 0.15)
            end
            -- activate this
            tabFrame.Visible = true
            if iconLbl:IsA("ImageLabel") then
                Tween(iconLbl, { ImageColor3 = Theme.Accent }, 0.15)
            else
                Tween(iconLbl, { TextColor3 = Theme.Accent }, 0.15)
            end
            Tween(dot, { BackgroundTransparency = 0 }, 0.15)
            self._active = TabObj
        end

        navBtn.MouseButton1Click:Connect(SetActive)

        table.insert(self._tabs, TabObj)
        -- Resize all nav buttons
        local count = #self._tabs
        for _, t in ipairs(self._tabs) do
            t._btn.Size = UDim2.new(1 / count, 0, 1, -10)
        end

        if count == 1 then SetActive() end -- auto-select first

        -- ────────────────────────────────────────────────────
        --  ADD SECTION
        -- ────────────────────────────────────────────────────
        function TabObj:AddSection(secName)
            secName = secName or "Section"
            TabObj._count += 1

            local secWrap = Create("Frame", {
                Parent = tabFrame,
                Size   = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                LayoutOrder = TabObj._count,
            })

            -- Section label
            Create("TextLabel", {
                Parent = secWrap,
                Text   = secName:upper(),
                Font   = Enum.Font.GothamBold,
                TextSize = 10,
                TextColor3 = Theme.Muted,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Size   = UDim2.new(1, 0, 0, 24),
                Position = UDim2.new(0, 2, 0, 0),
            })

            -- Card container
            local Card = Create("Frame", {
                Parent = secWrap,
                Size   = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 26),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Theme.Panel,
                BorderSizePixel = 0,
                ClipsDescendants = true,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = Card })
            Create("UIStroke",  { Color = Theme.Border, Thickness = 1, Parent = Card })

            local cardLayout = Create("UIListLayout", {
                Parent = Card,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 0),
            })

            Card:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                secWrap.Size = UDim2.new(1, 0, 0, Card.AbsoluteSize.Y + 30)
            end)

            local SectionObj  = {}
            SectionObj._card  = Card
            SectionObj._count = 0

            -- ────────────────────────────────────────────────
            --  ROW HELPER
            -- ────────────────────────────────────────────────
            local function MakeRow(h)
                SectionObj._count += 1
                local row = Create("Frame", {
                    Parent = Card,
                    Size   = UDim2.new(1, 0, 0, h or 50),
                    BackgroundTransparency = 1,
                    LayoutOrder = SectionObj._count,
                })
                Create("UIPadding", {
                    Parent = row,
                    PaddingLeft  = UDim.new(0, 16),
                    PaddingRight = UDim.new(0, 16),
                })
                -- separator (not for first row)
                if SectionObj._count > 1 then
                    Create("Frame", {
                        Parent = row,
                        Size   = UDim2.new(1, -32, 0, 1),
                        Position = UDim2.new(0, 16, 0, 0),
                        BackgroundColor3 = Theme.Border,
                        BorderSizePixel = 0,
                    })
                end
                return row
            end

            local function NameLabel(parent, txt, y, h)
                return Create("TextLabel", {
                    Parent = parent,
                    Text   = txt,
                    Font   = Enum.Font.GothamSemibold,
                    TextSize = 13,
                    TextColor3 = Theme.White,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Size   = UDim2.new(0.65, 0, 0, h or 18),
                    Position = UDim2.new(0, 0, 0, y or 16),
                })
            end

            local function DescLabel(parent, txt, y)
                Create("TextLabel", {
                    Parent = parent,
                    Text   = txt,
                    Font   = Enum.Font.Gotham,
                    TextSize = 10,
                    TextColor3 = Theme.Muted,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Size   = UDim2.new(0.65, 0, 0, 13),
                    Position = UDim2.new(0, 0, 0, y or 30),
                })
            end

            -- ────────────────────────────────────────────────
            --  TOGGLE
            -- ────────────────────────────────────────────────
            function SectionObj:AddToggle(c)
                c = c or {}
                local name     = c.Name or "Toggle"
                local desc     = c.Description
                local default  = c.Default == true
                local flag     = c.Flag
                local callback = c.Callback or function() end

                local row = MakeRow(desc and 62 or 50)
                NameLabel(row, name, desc and 10 or 16)
                if desc then DescLabel(row, desc, 28) end

                local toggled = default

                local track = Create("Frame", {
                    Parent = row,
                    Size   = UDim2.new(0, 46, 0, 25),
                    Position = UDim2.new(1, -46, 0.5, -12),
                    BackgroundColor3 = toggled and Theme.ToggleOn or Theme.ToggleOff,
                    BorderSizePixel = 0,
                })
                Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })

                local knob = Create("Frame", {
                    Parent = track,
                    Size   = UDim2.new(0, 19, 0, 19),
                    Position = toggled and UDim2.new(1,-22,0.5,-9) or UDim2.new(0,3,0.5,-9),
                    BackgroundColor3 = Theme.Knob,
                    BorderSizePixel = 0,
                })
                Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })

                local function Apply(state, noCallback)
                    toggled = state
                    Tween(track, { BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff }, 0.18)
                    Tween(knob,  { Position = state and UDim2.new(1,-22,0.5,-9) or UDim2.new(0,3,0.5,-9) }, 0.18)
                    if flag then Voidlibrary.Flags[flag] = state end
                    if not noCallback then task.spawn(callback, state) end
                end

                Apply(default, true)

                local hitbox = Create("TextButton", {
                    Parent = row,
                    Size   = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text   = "",
                    ZIndex = row.ZIndex + 5,
                })
                hitbox.MouseButton1Click:Connect(function() Apply(not toggled) end)

                local api = {}
                function api:Set(v) Apply(v) end
                function api:Get() return toggled end
                return api
            end

            -- ────────────────────────────────────────────────
            --  BUTTON
            -- ────────────────────────────────────────────────
            function SectionObj:AddButton(c)
                c = c or {}
                local name     = c.Name or "Button"
                local desc     = c.Description
                local callback = c.Callback or function() end

                local row = MakeRow(desc and 62 or 50)
                NameLabel(row, name, desc and 10 or 16)
                if desc then DescLabel(row, desc, 28) end

                local btn = Create("TextButton", {
                    Parent = row,
                    Size   = UDim2.new(0, 72, 0, 30),
                    Position = UDim2.new(1, -72, 0.5, -15),
                    BackgroundColor3 = Theme.PanelAlt,
                    Text   = "RUN →",
                    Font   = Enum.Font.GothamBold,
                    TextSize = 11,
                    TextColor3 = Theme.Accent,
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    ZIndex = row.ZIndex + 3,
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = btn })
                Create("UIStroke",  { Color = Theme.Border, Thickness = 1, Parent = btn })

                btn.MouseButton1Click:Connect(function()
                    Tween(btn, { BackgroundColor3 = Theme.AccentDim }, 0.1)
                    task.delay(0.12, function() Tween(btn, { BackgroundColor3 = Theme.PanelAlt }, 0.15) end)
                    task.spawn(callback)
                end)
                btn.MouseEnter:Connect(function() Tween(btn, { BackgroundColor3 = Theme.Border }, 0.1) end)
                btn.MouseLeave:Connect(function() Tween(btn, { BackgroundColor3 = Theme.PanelAlt }, 0.1) end)
            end

            -- ────────────────────────────────────────────────
            --  SLIDER
            -- ────────────────────────────────────────────────
            function SectionObj:AddSlider(c)
                c = c or {}
                local name     = c.Name or "Slider"
                local desc     = c.Description
                local min      = c.Min or 0
                local max      = c.Max or 100
                local default  = math.clamp(c.Default or min, min, max)
                local suffix   = c.Suffix or ""
                local flag     = c.Flag
                local callback = c.Callback or function() end

                local row = MakeRow(desc and 76 or 64)
                NameLabel(row, name, desc and 8 or 12)
                if desc then DescLabel(row, desc, 26) end

                local valLabel = Create("TextLabel", {
                    Parent = row,
                    Text   = tostring(default) .. suffix,
                    Font   = Enum.Font.GothamBold,
                    TextSize = 12,
                    TextColor3 = Theme.Accent,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    BackgroundTransparency = 1,
                    Size   = UDim2.new(1, 0, 0, 18),
                    Position = UDim2.new(0, 0, 0, desc and 8 or 12),
                })

                local sliderBg = Create("Frame", {
                    Parent = row,
                    Size   = UDim2.new(1, 0, 0, 6),
                    Position = UDim2.new(0, 0, 1, -18),
                    BackgroundColor3 = Theme.PanelAlt,
                    BorderSizePixel = 0,
                })
                Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = sliderBg })
                Create("UIStroke",  { Color = Theme.Border, Thickness = 1, Parent = sliderBg })

                local initRel = (default - min) / math.max(max - min, 0.001)

                local fill = Create("Frame", {
                    Parent = sliderBg,
                    Size   = UDim2.new(initRel, 0, 1, 0),
                    BackgroundColor3 = Theme.Accent,
                    BorderSizePixel = 0,
                })
                Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })

                local thumb = Create("Frame", {
                    Parent = sliderBg,
                    Size   = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new(initRel, -7, 0.5, -7),
                    BackgroundColor3 = Theme.Knob,
                    BorderSizePixel = 0,
                })
                Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = thumb })
                Create("UIStroke",  { Color = Theme.Accent, Thickness = 1.5, Parent = thumb })

                local value   = default
                local holding = false

                local function SetValue(pos)
                    local rel = math.clamp(
                        (pos - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X,
                        0, 1
                    )
                    value = math.round(min + (max - min) * rel)
                    fill.Size     = UDim2.new(rel, 0, 1, 0)
                    thumb.Position = UDim2.new(rel, -7, 0.5, -7)
                    valLabel.Text = tostring(value) .. suffix
                    if flag then Voidlibrary.Flags[flag] = value end
                    task.spawn(callback, value)
                end

                sliderBg.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1
                    or inp.UserInputType == Enum.UserInputType.Touch then
                        holding = true
                        SetValue(inp.Position.X)
                    end
                end)
                UserInputService.InputChanged:Connect(function(inp)
                    if holding and (inp.UserInputType == Enum.UserInputType.MouseMovement
                    or inp.UserInputType == Enum.UserInputType.Touch) then
                        SetValue(inp.Position.X)
                    end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1
                    or inp.UserInputType == Enum.UserInputType.Touch then
                        holding = false
                    end
                end)

                local api = {}
                function api:Set(v)
                    v = math.clamp(v, min, max)
                    local rel = (v - min) / math.max(max - min, 0.001)
                    value = v
                    fill.Size      = UDim2.new(rel, 0, 1, 0)
                    thumb.Position = UDim2.new(rel, -7, 0.5, -7)
                    valLabel.Text  = tostring(v) .. suffix
                    if flag then Voidlibrary.Flags[flag] = v end
                end
                function api:Get() return value end
                return api
            end

            -- ────────────────────────────────────────────────
            --  TEXTBOX
            -- ────────────────────────────────────────────────
            function SectionObj:AddTextbox(c)
                c = c or {}
                local name     = c.Name or "Textbox"
                local desc     = c.Description
                local placeholder = c.Placeholder or "Type here..."
                local default  = c.Default or ""
                local flag     = c.Flag
                local callback = c.Callback or function() end

                local row = MakeRow(desc and 80 or 68)
                NameLabel(row, name, 8)
                if desc then DescLabel(row, desc, 24) end

                local boxBg = Create("Frame", {
                    Parent = row,
                    Size   = UDim2.new(1, 0, 0, 28),
                    Position = UDim2.new(0, 0, 1, -34),
                    BackgroundColor3 = Theme.PanelAlt,
                    BorderSizePixel = 0,
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 7), Parent = boxBg })
                local stroke = Create("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = boxBg })

                local box = Create("TextBox", {
                    Parent = boxBg,
                    Size   = UDim2.new(1, -16, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    Text   = default,
                    PlaceholderText = placeholder,
                    Font   = Enum.Font.Gotham,
                    TextSize = 12,
                    TextColor3 = Theme.White,
                    PlaceholderColor3 = Theme.Muted,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false,
                })

                box.Focused:Connect(function()     Tween(stroke, { Color = Theme.Accent }, 0.15) end)
                box.FocusLost:Connect(function(enter)
                    Tween(stroke, { Color = Theme.Border }, 0.15)
                    if flag then Voidlibrary.Flags[flag] = box.Text end
                    task.spawn(callback, box.Text, enter)
                end)

                local api = {}
                function api:Set(v) box.Text = tostring(v) end
                function api:Get() return box.Text end
                return api
            end

            -- ────────────────────────────────────────────────
            --  DROPDOWN
            -- ────────────────────────────────────────────────
            function SectionObj:AddDropdown(c)
                c = c or {}
                local name     = c.Name or "Dropdown"
                local desc     = c.Description
                local options  = c.Options or {}
                local default  = c.Default or options[1]
                local flag     = c.Flag
                local callback = c.Callback or function() end

                local row = MakeRow(desc and 76 or 64)
                NameLabel(row, name, 8)
                if desc then DescLabel(row, desc, 24) end

                local ddBtn = Create("TextButton", {
                    Parent = row,
                    Size   = UDim2.new(1, 0, 0, 28),
                    Position = UDim2.new(0, 0, 1, -34),
                    BackgroundColor3 = Theme.PanelAlt,
                    Text   = "",
                    AutoButtonColor = false,
                    BorderSizePixel = 0,
                    ZIndex = row.ZIndex + 3,
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 7), Parent = ddBtn })
                local ddStroke = Create("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = ddBtn })

                local selLabel = Create("TextLabel", {
                    Parent = ddBtn,
                    Text   = tostring(default or "Select..."),
                    Font   = Enum.Font.Gotham,
                    TextSize = 12,
                    TextColor3 = default and Theme.White or Theme.Muted,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Size   = UDim2.new(1, -28, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    ZIndex = ddBtn.ZIndex + 1,
                })
                Create("TextLabel", {
                    Parent = ddBtn,
                    Text   = "▾",
                    Font   = Enum.Font.GothamBold,
                    TextSize = 12,
                    TextColor3 = Theme.Muted,
                    BackgroundTransparency = 1,
                    Size   = UDim2.new(0, 20, 1, 0),
                    Position = UDim2.new(1, -22, 0, 0),
                    ZIndex = ddBtn.ZIndex + 1,
                })

                local selected = default
                local isOpen   = false

                -- Dropdown list (parented to Win so it floats above everything)
                local dropList = Create("Frame", {
                    Parent = Win,
                    BackgroundColor3 = Theme.Panel,
                    BorderSizePixel = 0,
                    Visible = false,
                    Size   = UDim2.new(0, 100, 0, 0), -- sized dynamically
                    ZIndex = 50,
                    ClipsDescendants = true,
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = dropList })
                Create("UIStroke",  { Color = Theme.Border, Thickness = 1, Parent = dropList })
                Create("UIListLayout", {
                    Parent = dropList,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 2),
                })
                Create("UIPadding", {
                    Parent = dropList,
                    PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4),
                    PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4),
                })

                local function BuildList()
                    for _, ch in ipairs(dropList:GetChildren()) do
                        if ch:IsA("TextButton") then ch:Destroy() end
                    end
                    for i, opt in ipairs(options) do
                        local item = Create("TextButton", {
                            Parent = dropList,
                            Size   = UDim2.new(1, 0, 0, 28),
                            BackgroundColor3 = opt == selected and Theme.AccentDim or Theme.PanelAlt,
                            BackgroundTransparency = opt == selected and 0 or 0.4,
                            Text   = tostring(opt),
                            Font   = Enum.Font.Gotham,
                            TextSize = 12,
                            TextColor3 = opt == selected and Theme.White or Theme.Gray,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            AutoButtonColor = false,
                            BorderSizePixel = 0,
                            ZIndex = 51,
                            LayoutOrder = i,
                        })
                        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = item })
                        Create("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = item })
                        item.MouseButton1Click:Connect(function()
                            selected = opt
                            selLabel.Text = tostring(opt)
                            selLabel.TextColor3 = Theme.White
                            if flag then Voidlibrary.Flags[flag] = opt end
                            task.spawn(callback, opt)
                            isOpen = false
                            Tween(dropList, { Size = UDim2.new(dropList.Size.X.Scale, dropList.Size.X.Offset, 0, 0) }, 0.2)
                            task.delay(0.2, function() dropList.Visible = false end)
                            Tween(ddStroke, { Color = Theme.Border }, 0.15)
                        end)
                    end
                end

                ddBtn.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    if isOpen then
                        BuildList()
                        -- Position: below the ddBtn relative to Win
                        local absBtn = ddBtn.AbsolutePosition
                        local absWin = Win.AbsolutePosition
                        local bx = absBtn.X - absWin.X
                        local by = absBtn.Y - absWin.Y + 30
                        local bw = ddBtn.AbsoluteSize.X
                        local listH = math.min(#options * 32 + 8, 160)
                        dropList.Position = UDim2.new(0, bx, 0, by)
                        dropList.Size = UDim2.new(0, bw, 0, 0)
                        dropList.Visible = true
                        Tween(dropList, { Size = UDim2.new(0, bw, 0, listH) }, 0.22)
                        Tween(ddStroke, { Color = Theme.Accent }, 0.15)
                    else
                        Tween(dropList, { Size = UDim2.new(0, dropList.Size.X.Offset, 0, 0) }, 0.18)
                        task.delay(0.2, function() dropList.Visible = false end)
                        Tween(ddStroke, { Color = Theme.Border }, 0.15)
                    end
                end)

                local api = {}
                function api:Set(v) selected = v; selLabel.Text = tostring(v) end
                function api:Get() return selected end
                function api:Refresh(newOpts) options = newOpts end
                return api
            end

            -- ────────────────────────────────────────────────
            --  KEYBIND
            -- ────────────────────────────────────────────────
            function SectionObj:AddKeybind(c)
                c = c or {}
                local name     = c.Name or "Keybind"
                local default  = c.Default or Enum.KeyCode.Unknown
                local flag     = c.Flag
                local callback = c.Callback or function() end

                local row = MakeRow(50)
                NameLabel(row, name, 16)

                local current   = default
                local listening = false

                local keyBtn = Create("TextButton", {
                    Parent = row,
                    Size   = UDim2.new(0, 80, 0, 28),
                    Position = UDim2.new(1, -80, 0.5, -14),
                    BackgroundColor3 = Theme.PanelAlt,
                    Text   = default == Enum.KeyCode.Unknown and "NONE" or default.Name:upper(),
                    Font   = Enum.Font.GothamBold,
                    TextSize = 10,
                    TextColor3 = Theme.Accent,
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    ZIndex = row.ZIndex + 3,
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 7), Parent = keyBtn })
                local ks = Create("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = keyBtn })

                keyBtn.MouseButton1Click:Connect(function()
                    listening = true
                    keyBtn.Text = "..."
                    Tween(ks, { Color = Theme.Accent }, 0.15)
                end)

                UserInputService.InputBegan:Connect(function(inp, gp)
                    if listening and not gp and inp.UserInputType == Enum.UserInputType.Keyboard then
                        listening = false
                        current = inp.KeyCode
                        keyBtn.Text = inp.KeyCode.Name:upper()
                        Tween(ks, { Color = Theme.Border }, 0.15)
                        if flag then Voidlibrary.Flags[flag] = inp.KeyCode end
                    end
                    if not listening and inp.UserInputType == Enum.UserInputType.Keyboard then
                        if inp.KeyCode == current then task.spawn(callback, current) end
                    end
                end)

                local api = {}
                function api:Get() return current end
                return api
            end

            -- ────────────────────────────────────────────────
            --  COLORPICKER
            -- ────────────────────────────────────────────────
            function SectionObj:AddColorpicker(c)
                c = c or {}
                local name     = c.Name or "Color"
                local default  = c.Default or Color3.fromRGB(255, 255, 255)
                local flag     = c.Flag
                local callback = c.Callback or function() end

                local row = MakeRow(50)
                NameLabel(row, name, 16)

                local current = default

                local swatch = Create("TextButton", {
                    Parent = row,
                    Size   = UDim2.new(0, 28, 0, 22),
                    Position = UDim2.new(1, -28, 0.5, -11),
                    BackgroundColor3 = current,
                    Text   = "",
                    AutoButtonColor = false,
                    BorderSizePixel = 0,
                    ZIndex = row.ZIndex + 3,
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = swatch })
                Create("UIStroke",  { Color = Theme.Border, Thickness = 1.5, Parent = swatch })

                -- RGB Picker popup
                local pickerOpen = false
                local picker = Create("Frame", {
                    Parent = Win,
                    Size   = UDim2.new(0, 180, 0, 0),
                    BackgroundColor3 = Theme.Panel,
                    BorderSizePixel = 0,
                    Visible = false,
                    ZIndex = 50,
                    ClipsDescendants = true,
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = picker })
                Create("UIStroke",  { Color = Theme.Accent, Thickness = 1, Parent = picker })
                local pickerLayout = Create("UIListLayout", {
                    Parent = picker, Padding = UDim.new(0, 4),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                })
                Create("UIPadding", {
                    Parent = picker,
                    PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8),
                    PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
                })

                local channels = {
                    { label = "R", color = Theme.Danger,  val = math.round(default.R * 255) },
                    { label = "G", color = Theme.Success, val = math.round(default.G * 255) },
                    { label = "B", color = Theme.Accent,  val = math.round(default.B * 255) },
                }

                local function UpdateColor()
                    current = Color3.fromRGB(channels[1].val, channels[2].val, channels[3].val)
                    swatch.BackgroundColor3 = current
                    if flag then Voidlibrary.Flags[flag] = current end
                    task.spawn(callback, current)
                end

                for i, ch in ipairs(channels) do
                    local chRow = Create("Frame", {
                        Parent = picker,
                        Size   = UDim2.new(1, 0, 0, 26),
                        BackgroundTransparency = 1,
                        LayoutOrder = i,
                    })
                    Create("TextLabel", {
                        Parent = chRow,
                        Text   = ch.label,
                        Font   = Enum.Font.GothamBold,
                        TextSize = 10,
                        TextColor3 = ch.color,
                        BackgroundTransparency = 1,
                        Size   = UDim2.new(0, 14, 1, 0),
                    })
                    local chBg = Create("Frame", {
                        Parent = chRow,
                        Size   = UDim2.new(1, -36, 0, 6),
                        Position = UDim2.new(0, 18, 0.5, -3),
                        BackgroundColor3 = Theme.PanelAlt,
                        BorderSizePixel = 0,
                    })
                    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = chBg })
                    local chFill = Create("Frame", {
                        Parent = chBg,
                        Size   = UDim2.new(ch.val / 255, 0, 1, 0),
                        BackgroundColor3 = ch.color,
                        BorderSizePixel = 0,
                    })
                    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = chFill })

                    local valTxt = Create("TextLabel", {
                        Parent = chRow,
                        Text   = tostring(ch.val),
                        Font   = Enum.Font.GothamBold,
                        TextSize = 9,
                        TextColor3 = Theme.Gray,
                        BackgroundTransparency = 1,
                        Size   = UDim2.new(0, 18, 1, 0),
                        Position = UDim2.new(1, -18, 0, 0),
                    })

                    local heldCh = false
                    chBg.InputBegan:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                            heldCh = true
                        end
                    end)
                    UserInputService.InputChanged:Connect(function(inp)
                        if heldCh and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                            local rel = math.clamp((inp.Position.X - chBg.AbsolutePosition.X) / chBg.AbsoluteSize.X, 0, 1)
                            ch.val = math.round(rel * 255)
                            chFill.Size = UDim2.new(rel, 0, 1, 0)
                            valTxt.Text = tostring(ch.val)
                            UpdateColor()
                        end
                    end)
                    UserInputService.InputEnded:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                            heldCh = false
                        end
                    end)
                end

                swatch.MouseButton1Click:Connect(function()
                    pickerOpen = not pickerOpen
                    if pickerOpen then
                        local abs = swatch.AbsolutePosition - Win.AbsolutePosition
                        picker.Position = UDim2.new(0, abs.X - 185, 0, abs.Y)
                        picker.Visible = true
                        Tween(picker, { Size = UDim2.new(0, 180, 0, 100) }, 0.22)
                    else
                        Tween(picker, { Size = UDim2.new(0, 180, 0, 0) }, 0.18)
                        task.delay(0.2, function() picker.Visible = false end)
                    end
                end)

                local api = {}
                function api:Set(col)
                    current = col
                    swatch.BackgroundColor3 = col
                    channels[1].val = math.round(col.R * 255)
                    channels[2].val = math.round(col.G * 255)
                    channels[3].val = math.round(col.B * 255)
                end
                function api:Get() return current end
                return api
            end

            -- ────────────────────────────────────────────────
            --  LABEL
            -- ────────────────────────────────────────────────
            function SectionObj:AddLabel(txt)
                local t = type(txt) == "string" and txt or (txt and txt.Text or "Label")
                local row = MakeRow(38)
                Create("TextLabel", {
                    Parent = row,
                    Text   = t,
                    Font   = Enum.Font.Gotham,
                    TextSize = 12,
                    TextColor3 = Theme.Gray,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Size   = UDim2.new(1, 0, 1, 0),
                })
            end

            -- ────────────────────────────────────────────────
            --  PARAGRAPH
            -- ────────────────────────────────────────────────
            function SectionObj:AddParagraph(c)
                c = c or {}
                local title   = c.Title or ""
                local content = c.Content or c.Body or ""
                SectionObj._count += 1

                local wrap = Create("Frame", {
                    Parent = Card,
                    Size   = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    LayoutOrder = SectionObj._count,
                })
                Create("UIPadding", {
                    Parent = wrap,
                    PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16),
                    PaddingTop = UDim.new(0, 10),  PaddingBottom = UDim.new(0, 10),
                })
                Create("UIListLayout", {
                    Parent = wrap, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4),
                })
                if title ~= "" then
                    Create("TextLabel", {
                        Parent = wrap,
                        Text   = title,
                        Font   = Enum.Font.GothamBold,
                        TextSize = 13,
                        TextColor3 = Theme.White,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextWrapped = true,
                        BackgroundTransparency = 1,
                        Size   = UDim2.new(1, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        LayoutOrder = 1,
                    })
                end
                Create("TextLabel", {
                    Parent = wrap,
                    Text   = content,
                    Font   = Enum.Font.Gotham,
                    TextSize = 11,
                    TextColor3 = Theme.Gray,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    BackgroundTransparency = 1,
                    Size   = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    LayoutOrder = 2,
                })
            end

            return SectionObj
        end -- AddSection

        return TabObj
    end -- AddTab

    -- Close button (X) on header top right
    local closeBtn = Create("TextButton", {
        Parent = Header,
        Size   = UDim2.new(0, 26, 0, 26),
        Position = UDim2.new(1, -38, 0, 12),
        BackgroundColor3 = Theme.PanelAlt,
        Text   = "✕",
        Font   = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = Theme.Muted,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        ZIndex = 6,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = closeBtn })
    closeBtn.MouseButton1Click:Connect(function()
        Tween(Win, { BackgroundTransparency = 1 }, 0.25)
        task.delay(0.3, function() ScreenGui:Destroy() end)
    end)
    closeBtn.MouseEnter:Connect(function() Tween(closeBtn, { TextColor3 = Theme.Danger, BackgroundColor3 = Color3.fromRGB(50,15,15) }, 0.12) end)
    closeBtn.MouseLeave:Connect(function() Tween(closeBtn, { TextColor3 = Theme.Muted,  BackgroundColor3 = Theme.PanelAlt }, 0.12) end)

    function WindowObj:Notify(cfg) Voidlibrary:Notify(cfg) end

    function WindowObj:Destroy() ScreenGui:Destroy() end

    return WindowObj
end -- CreateWindow

-- ============================================================
--  DESTROY ALL
-- ============================================================
function Voidlibrary:Destroy()
    for _, gui in ipairs(CoreGui:GetChildren()) do
        if gui.Name:find("Voidlibrary") then gui:Destroy() end
    end
    if NotifGui then NotifGui:Destroy() end
    self.Flags = {}
end

return Voidlibrary

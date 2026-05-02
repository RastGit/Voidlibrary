--[[
    ██╗   ██╗ 

-- ============================================================
-- SERVICES & UTILITIES
-- ============================================================

local Services = {
    CoreGui        = game:GetService("CoreGui"),
    Players        = game:GetService("Players"),
    RunService     = game:GetService("RunService"),
    TweenService   = game:GetService("TweenService"),
    UserInput      = game:GetService("UserInputService"),
    TextService    = game:GetService("TextService"),
    HttpService    = game:GetService("HttpService"),
}

local LocalPlayer = Services.Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Check if mobile
local function IsMobile()
    return Services.UserInput.TouchEnabled and not Services.UserInput.KeyboardEnabled
end

-- Tween helper
local function Tween(obj, props, duration, style, direction)
    style = style or Enum.EasingStyle.Quart
    direction = direction or Enum.EasingDirection.Out
    local info = TweenInfo.new(duration or 0.25, style, direction)
    local tween = Services.TweenService:Create(obj, info, props)
    tween:Play()
    return tween
end

-- Make instance helper
local function New(className, props, children)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            obj[k] = v
        end
    end
    for _, child in pairs(children or {}) do
        child.Parent = obj
    end
    if props and props.Parent then
        obj.Parent = props.Parent
    end
    return obj
end

-- Draggable (PC only)
local function MakeDraggable(frame, handle)
    if IsMobile() then return end
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    Services.UserInput.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ============================================================
-- THEME (matching screenshots)
-- ============================================================

Voidlibrary.Theme = {
    -- Backgrounds (dark navy/gray from screenshots)
    Background      = Color3.fromRGB(20, 22, 28),
    Panel           = Color3.fromRGB(28, 30, 38),
    PanelDark       = Color3.fromRGB(18, 20, 26),
    
    -- Borders
    Border          = Color3.fromRGB(40, 44, 54),
    BorderLight     = Color3.fromRGB(55, 60, 72),
    
    -- Text
    TextPrimary     = Color3.fromRGB(245, 245, 250),
    TextSecondary   = Color3.fromRGB(160, 165, 180),
    TextMuted       = Color3.fromRGB(100, 105, 120),
    
    -- Accent (cyan like in screenshots)
    Accent          = Color3.fromRGB(85, 170, 255), -- light blue
    AccentDark      = Color3.fromRGB(50, 120, 200),
    
    -- Success/Warning/Danger
    Success         = Color3.fromRGB(80, 200, 120),
    Warning         = Color3.fromRGB(255, 180, 60),
    Danger          = Color3.fromRGB(255, 90, 90),
    
    -- Toggle
    ToggleOn        = Color3.fromRGB(85, 170, 255),
    ToggleOff       = Color3.fromRGB(50, 55, 65),
    ToggleKnob      = Color3.fromRGB(240, 240, 245),
}

-- ============================================================
-- CREATE WINDOW
-- ============================================================

function Voidlibrary:CreateWindow(config)
    config = config or {}
    
    local windowName    = config.Name or "Home"
    local playerName    = config.PlayerName or LocalPlayer.Name
    local welcomeText   = config.WelcomeText or "Good morning,"
    local subtitle      = config.Subtitle or ""
    local icon          = config.Icon -- player avatar headshot URL or rbxassetid
    
    -- Window sizing (adapt to mobile)
    local size, position
    if IsMobile() then
        size = UDim2.new(0.95, 0, 0.85, 0)
        position = UDim2.new(0.5, 0, 0.5, 0)
    else
        size = config.Size or UDim2.new(0, 650, 0, 480)
        position = config.Position or UDim2.new(0.5, -325, 0.5, -240)
    end
    
    local theme = config.Theme or self.Theme
    
    -- ScreenGui
    local screenGui
    local ok = pcall(function()
        screenGui = Instance.new("ScreenGui")
        screenGui.Name = "Voidlibrary_" .. windowName
        screenGui.ResetOnSpawn = false
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screenGui.DisplayOrder = 999
        screenGui.IgnoreGuiInset = true
        screenGui.Parent = Services.CoreGui
    end)
    if not ok then
        screenGui = Instance.new("ScreenGui")
        screenGui.Parent = LocalPlayer.PlayerGui
    end
    
    -- Main container
    local mainFrame = New("Frame", {
        Parent = screenGui,
        Size = size,
        Position = position,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    })
    New("UICorner", { CornerRadius = UDim.new(0, 14), Parent = mainFrame })
    
    -- Make draggable (PC)
    MakeDraggable(mainFrame, mainFrame)
    
    -- ══════════════════════════════════════════════════════════
    -- HEADER PANEL (matching screenshot 3)
    -- ══════════════════════════════════════════════════════════
    local header = New("Frame", {
        Parent = mainFrame,
        Size = UDim2.new(1, 0, 0, 110),
        BackgroundColor3 = theme.Panel,
        BorderSizePixel = 0,
    })
    New("UICorner", { CornerRadius = UDim.new(0, 14), Parent = header })
    
    -- Fix bottom corners
    New("Frame", {
        Parent = header,
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 1, -14),
        BackgroundColor3 = theme.Panel,
        BorderSizePixel = 0,
        ZIndex = 2,
    })
    
    -- Bottom separator line
    New("Frame", {
        Parent = header,
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = theme.Border,
        BorderSizePixel = 0,
        ZIndex = 3,
    })
    
    -- Home icon + name
    local homeLabelFrame = New("Frame", {
        Parent = header,
        Size = UDim2.new(0, 100, 0, 30),
        Position = UDim2.new(0, 16, 0, 14),
        BackgroundTransparency = 1,
    })
    
    New("ImageLabel", {
        Parent = homeLabelFrame,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 0, 0, 5),
        BackgroundTransparency = 1,
        Image = "rbxasset://textures/ui/GuiImagePlaceholder.png", -- home icon placeholder
        ImageColor3 = theme.Accent,
        ScaleType = Enum.ScaleType.Fit,
    })
    
    New("TextLabel", {
        Parent = homeLabelFrame,
        Text = windowName,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextColor3 = theme.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 70, 1, 0),
        Position = UDim2.new(0, 28, 0, 0),
    })
    
    -- Welcome message + player info (like screenshot 3)
    New("TextLabel", {
        Parent = header,
        Text = welcomeText,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = theme.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 300, 0, 16),
        Position = UDim2.new(0, 16, 0, 52),
    })
    
    -- Player name (big)
    New("TextLabel", {
        Parent = header,
        Text = playerName,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = theme.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 400, 0, 24),
        Position = UDim2.new(0, 16, 0, 68),
    })
    
    -- Subtitle (e.g. "Roblox member for 8 months")
    if subtitle ~= "" then
        New("ImageLabel", {
            Parent = header,
            Size = UDim2.new(0, 14, 0, 14),
            Position = UDim2.new(0, 16, 0, 94),
            BackgroundTransparency = 1,
            Image = "rbxasset://textures/ui/GuiImagePlaceholder.png",
            ImageColor3 = theme.Success,
        })
        New("TextLabel", {
            Parent = header,
            Text = subtitle,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextColor3 = theme.TextMuted,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 400, 0, 14),
            Position = UDim2.new(0, 34, 0, 94),
        })
    end
    
    -- Player avatar/icon (rounded, right side)
    local avatarSize = 64
    local avatarFrame = New("Frame", {
        Parent = header,
        Size = UDim2.new(0, avatarSize, 0, avatarSize),
        Position = UDim2.new(1, -avatarSize - 20, 0.5, -avatarSize/2 + 5),
        BackgroundColor3 = theme.PanelDark,
        BorderSizePixel = 0,
    })
    New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = avatarFrame })
    New("UIStroke", { Color = theme.Accent, Thickness = 2, Parent = avatarFrame })
    
    -- Avatar image
    local avatarUrl = icon or string.format(
        "https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=150&height=150&format=png",
        LocalPlayer.UserId
    )
    
    local avatarImg = New("ImageLabel", {
        Parent = avatarFrame,
        Size = UDim2.new(1, -4, 1, -4),
        Position = UDim2.new(0, 2, 0, 2),
        BackgroundTransparency = 1,
        Image = avatarUrl,
        ScaleType = Enum.ScaleType.Crop,
    })
    New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = avatarImg })
    
    -- ══════════════════════════════════════════════════════════
    -- BOTTOM NAV BAR (like screenshot bottom icons)
    -- ══════════════════════════════════════════════════════════
    local navHeight = 56
    local navBar = New("Frame", {
        Parent = mainFrame,
        Size = UDim2.new(1, 0, 0, navHeight),
        Position = UDim2.new(0, 0, 1, -navHeight),
        BackgroundColor3 = theme.Panel,
        BorderSizePixel = 0,
        ZIndex = 10,
    })
    New("UICorner", { CornerRadius = UDim.new(0, 14), Parent = navBar })
    
    -- Fix top corners
    New("Frame", {
        Parent = navBar,
        Size = UDim2.new(1, 0, 0, 14),
        BackgroundColor3 = theme.Panel,
        BorderSizePixel = 0,
        ZIndex = 11,
    })
    
    -- Top separator
    New("Frame", {
        Parent = navBar,
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = theme.Border,
        BorderSizePixel = 0,
        ZIndex = 12,
    })
    
    local navList = New("UIListLayout", {
        Parent = navBar,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 8),
    })
    
    -- ══════════════════════════════════════════════════════════
    -- CONTENT AREA (scrollable)
    -- ══════════════════════════════════════════════════════════
    local contentArea = New("ScrollingFrame", {
        Parent = mainFrame,
        Size = UDim2.new(1, 0, 1, -110 - navHeight),
        Position = UDim2.new(0, 0, 0, 110),
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
    })
    New("UIPadding", {
        Parent = contentArea,
        PaddingTop = UDim.new(0, 16),
        PaddingLeft = UDim.new(0, 16),
        PaddingRight = UDim.new(0, 16),
        PaddingBottom = UDim.new(0, 16),
    })
    New("UIListLayout", {
        Parent = contentArea,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
    })
    
    -- ══════════════════════════════════════════════════════════
    -- WINDOW OBJECT
    -- ══════════════════════════════════════════════════════════
    local Window = {}
    Window._theme = theme
    Window._tabs = {}
    Window._activeTab = nil
    Window._navBar = navBar
    Window._contentArea = contentArea
    Window._screenGui = screenGui
    Window._mainFrame = mainFrame
    
    table.insert(Voidlibrary.Windows, Window)
    
    -- ══════════════════════════════════════════════════════════
    -- ADD TAB
    -- ══════════════════════════════════════════════════════════
    function Window:AddTab(tabConfig)
        tabConfig = tabConfig or {}
        local tabName = tabConfig.Name or ("Tab " .. #self._tabs + 1)
        local tabIcon = tabConfig.Icon -- rbxassetid or rbxasset
        
        -- Nav button
        local navBtn = New("TextButton", {
            Parent = self._navBar,
            Size = UDim2.new(0, 50, 0, 44),
            BackgroundTransparency = 1,
            Text = "",
            ZIndex = 13,
        })
        
        -- Icon
        local iconImg = New("ImageLabel", {
            Parent = navBtn,
            Size = UDim2.new(0, 24, 0, 24),
            Position = UDim2.new(0.5, -12, 0, 6),
            BackgroundTransparency = 1,
            Image = tabIcon or "rbxasset://textures/ui/GuiImagePlaceholder.png",
            ImageColor3 = theme.TextMuted,
        })
        
        -- Active indicator (dot below icon)
        local activeDot = New("Frame", {
            Parent = navBtn,
            Size = UDim2.new(0, 6, 0, 6),
            Position = UDim2.new(0.5, -3, 1, -10),
            BackgroundColor3 = theme.Accent,
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            ZIndex = 14,
        })
        New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = activeDot })
        
        -- Tab content frame
        local tabFrame = New("Frame", {
            Parent = self._contentArea,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Visible = false,
        })
        New("UIListLayout", {
            Parent = tabFrame,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
        })
        
        local Tab = {}
        Tab._frame = tabFrame
        Tab._navBtn = navBtn
        Tab._iconImg = iconImg
        Tab._activeDot = activeDot
        Tab._theme = theme
        Tab._sections = {}
        Tab._elementCount = 0
        
        local function Activate()
            -- Deactivate all
            for _, t in pairs(self._tabs) do
                t._frame.Visible = false
                Tween(t._iconImg, { ImageColor3 = theme.TextMuted }, 0.2)
                Tween(t._activeDot, { BackgroundTransparency = 1 }, 0.2)
            end
            -- Activate this
            tabFrame.Visible = true
            Tween(iconImg, { ImageColor3 = theme.Accent }, 0.2)
            Tween(activeDot, { BackgroundTransparency = 0 }, 0.2)
            self._activeTab = Tab
        end
        
        navBtn.MouseButton1Click:Connect(Activate)
        
        table.insert(self._tabs, Tab)
        
        -- Auto-activate first tab
        if #self._tabs == 1 then
            Activate()
        end
        
        -- ══════════════════════════════════════════════════════
        -- ADD SECTION
        -- ══════════════════════════════════════════════════════
        function Tab:AddSection(sectionName)
            sectionName = sectionName or "Section"
            Tab._elementCount += 1
            
            local sectionWrap = New("Frame", {
                Parent = tabFrame,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                LayoutOrder = Tab._elementCount,
            })
            
            -- Section header
            local sectionHeader = New("Frame", {
                Parent = sectionWrap,
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundTransparency = 1,
            })
            
            New("TextLabel", {
                Parent = sectionHeader,
                Text = sectionName:upper(),
                Font = Enum.Font.GothamBold,
                TextSize = 11,
                TextColor3 = theme.TextMuted,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 200, 1, 0),
            })
            
            -- Section container
            local sectionContainer = New("Frame", {
                Parent = sectionWrap,
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 32),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = theme.Panel,
                BorderSizePixel = 0,
            })
            New("UICorner", { CornerRadius = UDim.new(0, 12), Parent = sectionContainer })
            New("UIPadding", {
                Parent = sectionContainer,
                PaddingTop = UDim.new(0, 8),
                PaddingBottom = UDim.new(0, 8),
            })
            New("UIListLayout", {
                Parent = sectionContainer,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 1),
            })
            
            sectionContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                sectionWrap.Size = UDim2.new(1, 0, 0, sectionContainer.AbsoluteSize.Y + 36)
            end)
            
            local Section = {}
            Section._container = sectionContainer
            Section._theme = theme
            Section._count = 0
            
            -- ══════════════════════════════════════════════════
            -- ELEMENT HELPERS
            -- ══════════════════════════════════════════════════
            local function MakeRow(name, height)
                Section._count += 1
                local row = New("Frame", {
                    Parent = sectionContainer,
                    Size = UDim2.new(1, 0, 0, height or 48),
                    BackgroundTransparency = 1,
                    LayoutOrder = Section._count,
                })
                New("UIPadding", {
                    Parent = row,
                    PaddingLeft = UDim.new(0, 16),
                    PaddingRight = UDim.new(0, 16),
                })
                -- Separator
                if Section._count > 1 then
                    New("Frame", {
                        Parent = row,
                        Size = UDim2.new(1, -32, 0, 1),
                        Position = UDim2.new(0, 16, 0, 0),
                        BackgroundColor3 = theme.Border,
                        BorderSizePixel = 0,
                        BackgroundTransparency = 0.5,
                    })
                end
                return row
            end
            
            -- ══════════════════════════════════════════════════
            -- TOGGLE
            -- ══════════════════════════════════════════════════
            function Section:AddToggle(config)
                config = config or {}
                local name     = config.Name or "Toggle"
                local desc     = config.Description
                local default  = config.Default or false
                local flag     = config.Flag
                local callback = config.Callback or function() end
                
                local height = desc and 62 or 48
                local row = MakeRow(name, height)
                
                -- Label
                local label = New("TextLabel", {
                    Parent = row,
                    Text = name,
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 14,
                    TextColor3 = theme.TextPrimary,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 400, 0, 20),
                    Position = UDim2.new(0, 0, 0, desc and 10 or 14),
                })
                
                if desc then
                    New("TextLabel", {
                        Parent = row,
                        Text = desc,
                        Font = Enum.Font.Gotham,
                        TextSize = 11,
                        TextColor3 = theme.TextMuted,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 400, 0, 14),
                        Position = UDim2.new(0, 0, 1, -20),
                    })
                end
                
                local toggled = default
                
                -- Toggle switch
                local track = New("Frame", {
                    Parent = row,
                    Size = UDim2.new(0, 48, 0, 26),
                    Position = UDim2.new(1, -48, 0.5, -13),
                    BackgroundColor3 = toggled and theme.ToggleOn or theme.ToggleOff,
                    BorderSizePixel = 0,
                })
                New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })
                
                local knob = New("Frame", {
                    Parent = track,
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = toggled and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10),
                    BackgroundColor3 = theme.ToggleKnob,
                    BorderSizePixel = 0,
                })
                New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
                
                local function Set(state, skipCb)
                    toggled = state
                    Tween(track, { BackgroundColor3 = state and theme.ToggleOn or theme.ToggleOff }, 0.2)
                    Tween(knob, { Position = state and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10) }, 0.2)
                    if flag then Voidlibrary.Flags[flag] = state end
                    if not skipCb then task.spawn(callback, state) end
                end
                
                Set(default, true)
                
                local btn = New("TextButton", {
                    Parent = row,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    ZIndex = 5,
                })
                btn.MouseButton1Click:Connect(function() Set(not toggled) end)
                
                return { Set = Set, Get = function() return toggled end }
            end
            
            -- ══════════════════════════════════════════════════
            -- BUTTON
            -- ══════════════════════════════════════════════════
            function Section:AddButton(config)
                config = config or {}
                local name = config.Name or "Button"
                local desc = config.Description
                local callback = config.Callback or function() end
                
                local height = desc and 62 or 48
                local row = MakeRow(name, height)
                
                New("TextLabel", {
                    Parent = row,
                    Text = name,
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 14,
                    TextColor3 = theme.TextPrimary,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 350, 0, 20),
                    Position = UDim2.new(0, 0, 0, desc and 10 or 14),
                })
                
                if desc then
                    New("TextLabel", {
                        Parent = row,
                        Text = desc,
                        Font = Enum.Font.Gotham,
                        TextSize = 11,
                        TextColor3 = theme.TextMuted,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 350, 0, 14),
                        Position = UDim2.new(0, 0, 1, -20),
                    })
                end
                
                local btn = New("TextButton", {
                    Parent = row,
                    Size = UDim2.new(0, 80, 0, 32),
                    Position = UDim2.new(1, -80, 0.5, -16),
                    BackgroundColor3 = theme.Accent,
                    Text = "GO",
                    Font = Enum.Font.GothamBold,
                    TextSize = 12,
                    TextColor3 = Color3.fromRGB(255,255,255),
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                })
                New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = btn })
                
                btn.MouseButton1Click:Connect(function()
                    Tween(btn, { BackgroundColor3 = theme.AccentDark }, 0.1)
                    task.delay(0.1, function()
                        Tween(btn, { BackgroundColor3 = theme.Accent }, 0.2)
                    end)
                    task.spawn(callback)
                end)
            end
            
            -- ══════════════════════════════════════════════════
            -- SLIDER
            -- ══════════════════════════════════════════════════
            function Section:AddSlider(config)
                config = config or {}
                local name = config.Name or "Slider"
                local min = config.Min or 0
                local max = config.Max or 100
                local default = config.Default or min
                local suffix = config.Suffix or ""
                local flag = config.Flag
                local callback = config.Callback or function() end
                
                local row = MakeRow(name, 70)
                
                -- Name + value
                New("TextLabel", {
                    Parent = row,
                    Text = name,
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 14,
                    TextColor3 = theme.TextPrimary,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 300, 0, 20),
                    Position = UDim2.new(0, 0, 0, 8),
                })
                
                local valLabel = New("TextLabel", {
                    Parent = row,
                    Text = tostring(default) .. suffix,
                    Font = Enum.Font.GothamBold,
                    TextSize = 13,
                    TextColor3 = theme.Accent,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    Position = UDim2.new(0, 0, 0, 8),
                })
                
                -- Track
                local trackBg = New("Frame", {
                    Parent = row,
                    Size = UDim2.new(1, 0, 0, 6),
                    Position = UDim2.new(0, 0, 1, -20),
                    BackgroundColor3 = theme.PanelDark,
                    BorderSizePixel = 0,
                })
                New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = trackBg })
                
                local fill = New("Frame", {
                    Parent = trackBg,
                    Size = UDim2.new((default-min)/(max-min), 0, 1, 0),
                    BackgroundColor3 = theme.Accent,
                    BorderSizePixel = 0,
                })
                New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })
                
                local knob = New("Frame", {
                    Parent = trackBg,
                    Size = UDim2.new(0, 16, 0, 16),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new((default-min)/(max-min), 0, 0.5, 0),
                    BackgroundColor3 = theme.ToggleKnob,
                    BorderSizePixel = 0,
                })
                New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
                New("UIStroke", { Color = theme.Accent, Thickness = 2, Parent = knob })
                
                local value = default
                local dragging = false
                
                local function Update(input)
                    local relX = math.clamp((input.Position.X - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X, 0, 1)
                    value = math.round(min + (max - min) * relX)
                    fill.Size = UDim2.new(relX, 0, 1, 0)
                    knob.Position = UDim2.new(relX, 0, 0.5, 0)
                    valLabel.Text = tostring(value) .. suffix
                    if flag then Voidlibrary.Flags[flag] = value end
                    task.spawn(callback, value)
                end
                
                trackBg.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        Update(inp)
                    end
                end)
                
                Services.UserInput.InputChanged:Connect(function(inp)
                    if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                        Update(inp)
                    end
                end)
                
                Services.UserInput.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
                
                return {
                    Set = function(_, v)
                        value = math.clamp(v, min, max)
                        local relX = (v - min) / (max - min)
                        fill.Size = UDim2.new(relX, 0, 1, 0)
                        knob.Position = UDim2.new(relX, 0, 0.5, 0)
                        valLabel.Text = tostring(v) .. suffix
                        if flag then Voidlibrary.Flags[flag] = v end
                    end,
                    Get = function() return value end
                }
            end
            
            -- Add other elements (Textbox, Dropdown, Colorpicker, Keybind, Label, Paragraph)
            -- ... (keep same logic as before but with updated theme)
            
            function Section:AddLabel(text)
                local row = MakeRow(text, 40)
                New("TextLabel", {
                    Parent = row,
                    Text = text,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    TextColor3 = theme.TextSecondary,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                })
            end
            
            return Section
        end
        
        return Tab
    end
    
    return Window
end

-- ============================================================
-- NOTIFICATIONS
-- ============================================================

function Voidlibrary:Notify(config)
    config = config or {}
    local title = config.Title or "Voidlibrary"
    local desc = config.Description or ""
    local duration = config.Duration or 4
    
    -- Simple print for now (can expand later)
    print(string.format("[%s] %s", title, desc))
end

-- ============================================================
-- DESTROY
-- ============================================================

function Voidlibrary:Destroy()
    for _, win in pairs(self.Windows) do
        if win._screenGui then win._screenGui:Destroy() end
    end
    self.Windows = {}
    self.Flags = {}
end

-- Wait for game to load
if not game:IsLoaded() then
    game.Loaded:Wait()
end

return Voidlibrary

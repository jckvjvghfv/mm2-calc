-- ============================================================
-- MM2 TRADE CALCULATOR v1.0 (Mobile Optimized)
-- ============================================================

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local PRICE_URL = "" 
local FALLBACK_PRICES = {
    ["chroma traveler's gun"] = {value = 140000, demand = 10, rarity = "chroma"},
    ["chroma evergreen"] = {value = 42000, demand = 9, rarity = "chroma"},
    ["gingerscope"] = {value = 15250, demand = 8, rarity = "godly"},
    ["traveler's gun"] = {value = 5200, demand = 7, rarity = "godly"},
    ["corrupt"] = {value = 350, demand = 6, rarity = "unique"},
    ["harvester"] = {value = 250, demand = 5, rarity = "godly"},
    ["icebreaker"] = {value = 180, demand = 6, rarity = "godly"},
    ["luger"] = {value = 18, demand = 4, rarity = "legendary"},
    ["icewing"] = {value = 13, demand = 3, rarity = "legendary"},
}
local FAIR_THRESHOLD = 0.10 

local Prices = {}
local LastUpdated = "embedded"

local function loadPrices()
    if PRICE_URL ~= "" then
        local ok, raw = pcall(function() return HttpService:GetAsync(PRICE_URL) end)
        if ok and raw then
            local decodeOk, data = pcall(function() return HttpService:JSONDecode(raw) end)
            if decodeOk and data and data.items then
                for name, info in pairs(data.items) do
                    Prices[name:lower()] = { value = tonumber(info.value) or 0, demand = tonumber(info.demand) or 0, rarity = info.rarity or "unknown" }
                end
                LastUpdated = data.last_updated or "unknown"
                return
            end
        end
    end
    for name, info in pairs(FALLBACK_PRICES) do Prices[name] = info end
    LastUpdated = "embedded"
end

loadPrices()

local oldGui = CoreGui:FindFirstChild("MM2TradeCalc")
if oldGui then oldGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "MM2TradeCalc"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 620, 0, 460) -- Уменьшена высота для мобилок
main.Position = UDim2.new(0.5, -310, 0.5, -230)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 38)
title.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
title.Text = "  MM2 Trade Calculator  |  DB: " .. LastUpdated
title.TextColor3 = Color3.fromRGB(220, 220, 230)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = main

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = title

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -34, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.Parent = main
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

local function createPanel(xOffset, labelText)
    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(0, 280, 0, 300)
    panel.Position = UDim2.new(0, xOffset, 0, 45)
    panel.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    panel.BorderSizePixel = 0
    panel.Parent = main

    local pc = Instance.new("UICorner")
    pc.CornerRadius = UDim.new(0, 6)
    pc.Parent = panel

    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, 0, 0, 32)
    header.BackgroundColor3 = Color3.fromRGB(42, 42, 58)
    header.Text = labelText
    header.TextColor3 = Color3.fromRGB(200, 200, 215)
    header.Font = Enum.Font.GothamBold
    header.TextSize = 13
    header.Parent = panel

    local hc = Instance.new("UICorner")
    hc.CornerRadius = UDim.new(0, 6)
    hc.Parent = header

    local search = Instance.new("TextBox")
    search.Size = UDim2.new(1, -16, 0, 32)
    search.Position = UDim2.new(0, 8, 0, 40)
    search.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    search.TextColor3 = Color3.fromRGB(200, 200, 210)
    search.PlaceholderText = "Search item..."
    search.PlaceholderColor3 = Color3.fromRGB(90, 90, 105)
    search.Font = Enum.Font.Gotham
    search.TextSize = 12
    search.TextXAlignment = Enum.TextXAlignment.Left
    search.ClearTextOnFocus = false
    search.Parent = panel

    local sc = Instance.new("UICorner")
    sc.CornerRadius = UDim.new(0, 4)
    sc.Parent = search

    local suggestions = Instance.new("ScrollingFrame")
    suggestions.Size = UDim2.new(1, -16, 0, 80)
    suggestions.Position = UDim2.new(0, 8, 0, 76)
    suggestions.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    suggestions.BorderSizePixel = 0
    suggestions.CanvasSize = UDim2.new(0, 0, 0, 0)
    suggestions.ScrollBarThickness = 3
    suggestions.Visible = false
    suggestions.Parent = panel

    local scc = Instance.new("UICorner")
    scc.CornerRadius = UDim.new(0, 4)
    scc.Parent = suggestions

    local sugLayout = Instance.new("UIListLayout")
    sugLayout.Padding = UDim.new(0, 2)
    sugLayout.Parent = suggestions

    local list = Instance.new("ScrollingFrame")
    list.Size = UDim2.new(1, -16, 0, 140)
    list.Position = UDim2.new(0, 8, 0, 164)
    list.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    list.BorderSizePixel = 0
    list.CanvasSize = UDim2.new(0, 0, 0, 0)
    list.ScrollBarThickness = 4
    list.Parent = panel

    local lc = Instance.new("UICorner")
    lc.CornerRadius = UDim.new(0, 4)
    lc.Parent = list

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 3)
    listLayout.Parent = list

    local total = Instance.new("TextLabel")
    total.Size = UDim2.new(1, -16, 0, 28)
    total.Position = UDim2.new(0, 8, 0, 312)
    total.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    total.Text = "Total: 0"
    total.TextColor3 = Color3.fromRGB(150, 200, 255)
    total.Font = Enum.Font.GothamBold
    total.TextSize = 13
    total.Parent = panel

    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(0, 4)
    tc.Parent = total

    local selected = {}
    local function refreshList()
        for _, child in ipairs(list:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        local sum = 0
        local y = 0
        for i, entry in ipairs(selected) do
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, -6, 0, 26)
            row.Position = UDim2.new(0, 3, 0, y)
            row.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
            row.BorderSizePixel = 0
            row.Parent = list

            local rc = Instance.new("UICorner")
            rc.CornerRadius = UDim.new(0, 3)
            rc.Parent = row

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Size = UDim2.new(0.7, 0, 1, 0)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text = entry.name
            nameLbl.TextColor3 = Color3.fromRGB(200, 200, 215)
            nameLbl.Font = Enum.Font.Gotham
            nameLbl.TextSize = 11
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left
            nameLbl.Parent = row

            local valLbl = Instance.new("TextLabel")
            valLbl.Size = UDim2.new(0.28, 0, 1, 0)
            valLbl.Position = UDim2.new(0.72, 0, 0, 0)
            valLbl.BackgroundTransparency = 1
            valLbl.Text = tostring(entry.value)
            valLbl.TextColor3 = Color3.fromRGB(150, 220, 150)
            valLbl.Font = Enum.Font.GothamBold
            valLbl.TextSize = 11
            valLbl.TextXAlignment = Enum.TextXAlignment.Right
            valLbl.Parent = row

            local del = Instance.new("TextButton")
            del.Size = UDim2.new(0, 18, 0, 18)
            del.Position = UDim2.new(1, -20, 0, 4)
            del.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
            del.Text = "x"
            del.TextColor3 = Color3.fromRGB(255, 120, 120)
            del.Font = Enum.Font.GothamBold
            del.TextSize = 10
            del.Parent = row
            del.MouseButton1Click:Connect(function()
                table.remove(selected, i)
                refreshList()
            end)

            sum = sum + entry.value
            y = y + 29
        end
        list.CanvasSize = UDim2.new(0, 0, 0, y)
        total.Text = "Total: " .. tostring(sum)
        return sum
    end

    search:GetPropertyChangedSignal("Text"):Connect(function()
        for _, child in ipairs(suggestions:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        local query = search.Text:lower():trim()
        if query == "" then
            suggestions.Visible = false
            return
        end
        local count = 0
        local y = 0
        for name, info in pairs(Prices) do
            if name:find(query, 1, true) then
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -4, 0, 24)
                btn.Position = UDim2.new(0, 2, 0, y)
                btn.BackgroundColor3 = Color3.fromRGB(32, 32, 44)
                btn.Text = name .. "  (" .. tostring(info.value) .. ")"
                btn.TextColor3 = Color3.fromRGB(180, 180, 200)
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 11
                btn.TextXAlignment = Enum.TextXAlignment.Left
                btn.Parent = suggestions
                btn.MouseButton1Click:Connect(function()
                    table.insert(selected, {name = name, value = info.value})
                    search.Text = ""
                    suggestions.Visible = false
                    refreshList()
                end)
                y = y + 26
                count = count + 1
                if count >= 20 then break end
            end
        end
        suggestions.CanvasSize = UDim2.new(0, 0, 0, y)
        suggestions.Visible = count > 0
    end)

    return panel, function() return refreshList() end
end

local leftPanel, getLeftSum = createPanel(15, "YOUR OFFER  (You Give)")
local rightPanel, getRightSum = createPanel(325, "THEIR OFFER  (You Receive)")

local verdict = Instance.new("Frame")
verdict.Size = UDim2.new(0, 590, 0, 50)
verdict.Position = UDim2.new(0, 15, 0, 355)
verdict.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
verdict.BorderSizePixel = 0
verdict.Parent = main

local vc = Instance.new("UICorner")
vc.CornerRadius = UDim.new(0, 6)
vc.Parent = verdict

local verdictLabel = Instance.new("TextLabel")
verdictLabel.Size = UDim2.new(1, 0, 1, 0)
verdictLabel.BackgroundTransparency = 1
verdictLabel.Text = "Add items to both sides, then press CALCULATE"
verdictLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
verdictLabel.Font = Enum.Font.GothamBold
verdictLabel.TextSize = 14
verdictLabel.Parent = verdict

local calcBtn = Instance.new("TextButton")
calcBtn.Size = UDim2.new(0, 180, 0, 36)
calcBtn.Position = UDim2.new(0.5, -90, 1, -46)
calcBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
calcBtn.Text = "CALCULATE"
calcBtn.TextColor3 = Color3.fromRGB(180, 220, 255)
calcBtn.Font = Enum.Font.GothamBold
calcBtn.TextSize = 14
calcBtn.Parent = main

local cb = Instance.new("UICorner")
cb.CornerRadius = UDim.new(0, 5)
cb.Parent = calcBtn

calcBtn.MouseButton1Click:Connect(function()
    local left = getLeftSum()
    local right = getRightSum()
    local diff = right - left
    local percent = 0
    if left > 0 then percent = (diff / left) * 100 end

    local verdictText, color
    if math.abs(percent) <= FAIR_THRESHOLD * 100 then
        verdictText = string.format("FAIR TRADE  |  Diff: %d (%.1f%%)", diff, percent)
        color = Color3.fromRGB(200, 200, 100)
    elseif diff > 0 then
        verdictText = string.format("WIN for you  |  +%d (%.1f%%)", diff, percent)
        color = Color3.fromRGB(100, 220, 100)
    else
        verdictText = string.format("LOSE for you  |  %d (%.1f%%)", diff, percent)
        color = Color3.fromRGB(220, 100, 100)
    end

    verdictLabel.Text = verdictText
    verdictLabel.TextColor3 = color
end)

print("[MM2 Calc] Loaded successfully!")
    search:GetPropertyChangedSignal("Text"):Connect(function()
        for _, child in ipairs(suggestions:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        local query = search.Text:lower():trim()
        if query == "" then
            suggestions.Visible = false
            return
        end
        local count = 0
        local y = 0
        for name, info in pairs(Prices) do
            if name:find(query, 1, true) then
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -4, 0, 24)
                btn.Position = UDim2.new(0, 2, 0, y)
                btn.BackgroundColor3 = Color3.fromRGB(32, 32, 44)
                btn.Text = name .. "  (" .. tostring(info.value) .. ")"
                btn.TextColor3 = Color3.fromRGB(180, 180, 200)
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 11
                btn.TextXAlignment = Enum.TextXAlignment.Left
                btn.Parent = suggestions
                btn.MouseButton1Click:Connect(function()
                    table.insert(selected, {name = name, value = info.value})
                    search.Text = ""
                    suggestions.Visible = false
                    refreshList()
                end)
                y = y + 26
                count = count + 1
                if count >= 20 then break end
            end
        end
        suggestions.CanvasSize = UDim2.new(0, 0, 0, y)
        suggestions.Visible = count > 0
    end)

    return panel, function() return refreshList() end
end

local leftPanel, getLeftSum = createPanel(15, "YOUR OFFER  (You Give)")
local rightPanel, getRightSum = createPanel(325, "THEIR OFFER  (You Receive)")

local verdict = Instance.new("Frame")
verdict.Size = UDim2.new(0, 590, 0, 60)
verdict.Position = UDim2.new(0, 15, 0, 410)
verdict.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
verdict.BorderSizePixel = 0
verdict.Parent = main

local vc = Instance.new("UICorner")
vc.CornerRadius = UDim.new(0, 6)
vc.Parent = verdict

local verdictLabel = Instance.new("TextLabel")
verdictLabel.Size = UDim2.new(1, 0, 1, 0)
verdictLabel.BackgroundTransparency = 1
verdictLabel.Text = "Add items to both sides, then press CALCULATE"
verdictLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
verdictLabel.Font = Enum.Font.GothamBold
verdictLabel.TextSize = 15
verdictLabel.Parent = verdict

local calcBtn = Instance.new("TextButton")
calcBtn.Size = UDim2.new(0, 180, 0, 36)
calcBtn.Position = UDim2.new(0.5, -90, 1, -46)
calcBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
calcBtn.Text = "CALCULATE"
calcBtn.TextColor3 = Color3.fromRGB(180, 220, 255)
calcBtn.Font = Enum.Font.GothamBold
calcBtn.TextSize = 14
calcBtn.Parent = main

local cb = Instance.new("UICorner")
cb.CornerRadius = UDim.new(0, 5)
cb.Parent = calcBtn

calcBtn.MouseButton1Click:Connect(function()
    local left = getLeftSum()
    local right = getRightSum()
    local diff = right - left
    local percent = 0
    if left > 0 then
        percent = (diff / left) * 100
    end

    local verdictText
    local color
    if math.abs(percent) <= FAIR_THRESHOLD * 100 then
        verdictText = string.format("FAIR TRADE  |  Diff: %d (%.1f%%)", diff, percent)
        color = Color3.fromRGB(200, 200, 100)
    elseif diff > 0 then
        verdictText = string.format("WIN for you  |  +%d (%.1f%%)", diff, percent)
        color = Color3.fromRGB(100, 220, 100)
    else
        verdictText = string.format("LOSE for you  |  %d (%.1f%%)", diff, percent)
        color = Color3.fromRGB(220, 100, 100)
    end

    verdictLabel.Text = verdictText
    verdictLabel.TextColor3 = color
end)

print("[MM2 Calc] Loaded. DB: " .. LastUpdated)

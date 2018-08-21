local Window = LibStub("LibWindow-1.1")

local Grindon = LibStub("AceAddon-3.0"):GetAddon("Grindon")
local Widget = Grindon:NewModule("Widget", "AceTimer-3.0", "AceConsole-3.0", "AceEvent-3.0")

local Config = Grindon:GetModule("Config")

local L = LibStub("AceLocale-3.0"):GetLocale("Grindon").Widget

local database

local options = {
    show_widget = {
        order = 0,
        type = "execute",
        name = L["ToggleWidget"],
        func = function()
            if Widget.Frame:IsShown() then
                Widget.Frame:Hide()
            else
                Widget.Frame:Show()
            end
        end
    },
    reset_widget = {
        order = 1,
        type = "execute",
        name = L["ResetWidget"],
        func = function() Widget:ResetSettings() end
    },
    header = {
        order = 1,
        type = "header",
        name = L["Header"]
    },
    lockMove = {
        order = 2,
        name = L["LockMove"],
        type = "toggle",
        set = function(_, val) database.profile.lockMove = val end,
        get = function() return database.profile.lockMove end
    },
    lockSize = {
        order = 3,
        name = L["LockSize"],
        type = "toggle",
        set = function(_, val) database.profile.lockSize = val end,
        get = function() return database.profile.lockSize end
    },
    frequency = {
        order = 4,
        name = L["Frequency"],
        type = "toggle",
        set = function(_, val) Widget:ToggleFrequency(val) end,
        get = function() return database.profile.frequency end
    },
    header_color = {
        order = 5,
        name = L["HeaderColor"],
        type = "color",
        hasAlpha = true,
        set = function(_, r, g, b, a)
            if r == nil or g == nil or b == nil then return end
            database.profile.colors.header.bg.r = r
            database.profile.colors.header.bg.g = g
            database.profile.colors.header.bg.b = b
            database.profile.colors.header.bg.a = a
            Widget.HeaderBackground:SetColorTexture(r, g, b, a)
        end,
        get = function()
            local color = database.profile.colors.header.bg
            return color.r , color.g, color.b, color.a
        end
    },
    header_text_color = {
        order = 6,
        name = L["HeaderTextColor"],
        type = "color",
        set = function(_, r, g, b)
            if r == nil or g == nil or b == nil then return end
            database.profile.colors.header.text.r = r
            database.profile.colors.header.text.g = g
            database.profile.colors.header.text.b = b
            Widget.Header.Title:SetTextColor(r, g, b)
            Widget.Header.Time:SetTextColor(r, g, b)
        end,
        get = function()
            local color = database.profile.colors.header.text
            return color.r , color.g, color.b
        end
    },
    content_color = {
        order = 7,
        name = L["ContentColor"],
        type = "color",
        hasAlpha = true,
        set = function(_, r, g, b, a)
            if r == nil or g == nil or b == nil then return end
            database.profile.colors.content.bg.r = r
            database.profile.colors.content.bg.g = g
            database.profile.colors.content.bg.b = b
            database.profile.colors.content.bg.a = a
            Widget.ContentBackground:SetColorTexture(r, g, b, a)
        end,
        get = function()
            local color = database.profile.colors.content.bg
            return color.r , color.g, color.b, color.a
        end
    },
    scale = {
        order = 8,
        name = L["Scale"],
        type = "range",
        min = 0.5,
        max = 1.5,
        set = function(_, val) Window.SetScale(Widget.Frame, val) end,
        get = function() return database.profile.transform.scale end,
        isPercent = true
    }
}

local defaults = {
    profile = {
        transform = {
            x = 0,
            y = 0,
            sizeX = 250,
            sizeY = 250,
            scale = 1,
            point = "CENTER"
        },
        colors = {
            header = {
                bg = {r = 0, g = 0, b = 0, a = 0.8},
                text = {r = 1.0, g = 0.82, b = 0}
            },
            content = {
                bg = {r = 0, g = 0, b = 0, a = 0.5}
            },
        },
        lockMove = false,
        lockSize = false,
        frequency = true,
    }
}

function Widget:OnInitialize()
    database = Grindon:RegisterNamespace("Widget", defaults)

    Config:Register(L["ConfigName"], options, 2)

    self.FrameCache = {}

    self:RegisterMessage("OnProfileChanged", "OnProfileChanged")
    self:RegisterMessage("OnSegmentStart", "OnSegmentStart")
    self:RegisterMessage("OnSegmentStop", "OnSegmentStop")

    self:CreateFrame()
end

function Widget:OnSegmentStart()
    self.Time = 0
    self.Timer = self:ScheduleRepeatingTimer("SegmentTimer", 1)

    self.Tree = {
        Categories = {},
        Items = {}
    }

    self.Frame:Show()
end

function Widget:OnSegmentStop()
    self.Header.Time:SetText("00:00:00")
    self:CleanCategory(self.Tree)
    self.Tree = {
        Categories = {},
        Items = {}
    }

    self.Frame:Hide()
end

function Widget:CreateFrame()
    self.Frame = CreateFrame("Frame", "GrindonWidget" , UIParent)
    self.Frame:SetResizable(true)
    self.Frame:SetMovable(true)
    self.Frame:SetPoint("CENTER", UIParent)
    self.Frame:SetSize(database.profile.transform.sizeX, database.profile.transform.sizeY)
    self.Frame:SetMinResize(200, 200)
    self.Frame:SetClampedToScreen(true)

    Window.RegisterConfig(self.Frame, database.profile.transform)
    Window.RestorePosition(self.Frame)

    self.Header = CreateFrame("Frame", nil, self.Frame)
    self.Header:EnableMouse(true)
    self.Header:SetPoint("TOPLEFT", self.Frame)
    self.Header:SetPoint("TOPRIGHT", self.Frame)
    self.Header:SetHeight(25)
    self.Header:RegisterForDrag("LeftButton")
    self.Header:SetScript("OnDragStart", function() if not database.profile.lockMove then self.Frame:StartMoving() end end)
    self.Header:SetScript("OnDragStop", function()
        self.Frame:StopMovingOrSizing()
        Window.SavePosition(self.Frame)
    end)

    local colors = database.profile.colors
    self.HeaderBackground = self.Header:CreateTexture(nil, "OVERLAY")
    self.HeaderBackground:SetColorTexture(colors.header.bg.r, colors.header.bg.g, colors.header.bg.b, colors.header.bg.a)
    self.HeaderBackground:SetAllPoints(self.Header)

    self.Header.Time = self.Header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.Header.Time:SetPoint("RIGHT", self.Header, -5, 0)
    self.Header.Time:SetText("00:00:00")
    self.Header.Time:SetTextColor(colors.header.text.r, colors.header.text.g, colors.header.text.b)

    self.Header.Title = self.Header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.Header.Title:SetPoint("LEFT", self.Header, 5, 0)
    self.Header.Title:SetPoint("RIGHT", self.Header.Time, "LEFT")
    self.Header.Title:SetText(L["Title"])
    self.Header.Title:SetJustifyH("LEFT")
    self.Header.Title:SetHeight(20)
    self.Header.Title:SetTextColor(colors.header.text.r, colors.header.text.g, colors.header.text.b)

    self.Content = CreateFrame("Frame", nil, self.Frame)
    self.Content:SetPoint("TOPLEFT", self.Header, "BOTTOMLEFT", 5, -5)
    self.Content:SetPoint("BOTTOMRIGHT", self.Frame, -5, 5)
    self.Content:SetClipsChildren(true)

    self.ContentTop = CreateFrame("Frame", nil, self.Content)
    self.ContentTop:SetPoint("TOPLEFT", self.Content)
    self.ContentTop:SetPoint("TOPRIGHT", self.Content)
    self.ContentTop:SetHeight(1)

    self.ContentBackground = self.Frame:CreateTexture(nil, "BACKGROUND")
    self.ContentBackground:SetColorTexture(colors.content.bg.r, colors.content.bg.g, colors.content.bg.b, colors.content.bg.a)
    self.ContentBackground:SetPoint("TOPLEFT", self.Header, "BOTTOMLEFT")
    self.ContentBackground:SetPoint("BOTTOMRIGHT", self.Frame)

    self.Anchor = CreateFrame("Frame", nil, self.Frame)
    self.Anchor:EnableMouse(true)
    self.Anchor:SetPoint("BOTTOMRIGHT", self.Frame, "BOTTOMRIGHT")
    self.Anchor:SetSize(30, 30)
    self.Anchor:RegisterForDrag("LeftButton")

    self.Anchor:SetScript("OnDragStart", function() if not database.profile.lockSize then self.Frame:StartSizing() end end)
    self.Anchor:SetScript("OnDragStop", function()
        self.Frame:StopMovingOrSizing()
        database.profile.transform.sizeX = self.Frame:GetWidth()
        database.profile.transform.sizeY = self.Frame:GetHeight()
    end)

    local AnchorBackground = self.Anchor:CreateTexture(nil, "OVERLAY")
    AnchorBackground:SetTexture("Interface/Cursor/Item.blp")
    AnchorBackground:SetRotation(math.rad(-180))
    AnchorBackground:SetAllPoints(self.Anchor)

    self.Content.Categories = {}

    self.Frame:Hide()
end

function Widget:SegmentTimer()
    self.Time = self.Time + 1

    local h = string.format("%02.f", math.floor(self.Time / 3600))
    local m = string.format("%02.f", math.floor(self.Time / 60 - (h * 60)))
    local s = string.format("%02.f", math.floor(self.Time - h * 3600 - m * 60))
    self.Header.Time:SetText(h .. ":" .. m .. ":" .. s)

    if database.profile.frequency then self:UpdateFrequency(self.Tree) end
end

function Widget:SetItem(path, id, icon, name, amount, color, frequency)
    if color == nil then color = "ffffff" end
    if frequency == nil then frequency = true end

    local r, g, b = self:Hex2RGB(color)

    local categories = Grindon:Split(path, "/")

    local category = self.Tree
    local parent = self.Content
    for i, name in pairs(categories) do
        if not category.Categories[name] then
            local frameID = self:FindCategoryFrame(parent)
            category.Categories[name] = {
                Frame = frameID,
                Active = true,
                Categories = {},
                Items = {}
            }
            parent = self.FrameCache[frameID]

            self.FrameCache[frameID]:SetScript("OnMouseDown", function(_, button) if button == "LeftButton" then self:ToggleCategory(path, i) end end)
            self.FrameCache[frameID].Text:SetText(name)
        else
            parent = self.FrameCache[category.Categories[name].Frame]
        end
        category = category.Categories[name]
    end

    if category.Items[id] ~= nil then
        local item = category.Items[id]

        item.Amount = amount
        item.Frequency = frequency

        self.FrameCache[item.Frame].Icon:SetTexture(icon)
        self.FrameCache[item.Frame].Amount:SetText(amount)
        self.FrameCache[item.Frame].Name:SetText(name)
        self.FrameCache[item.Frame].Name:SetTextColor(r, g, b)
        return
    end

    local frameID = self:FindItemFrame(parent)
    category.Items[id] = {
        Frame = frameID,
        Icon = icon,
        Name = name,
        Amount = amount,
        Frequency = frequency
    }

    self.FrameCache[frameID]:SetScript("OnMouseDown", function(_, button) if button == "RightButton" then self:RemoveItem(category, id) end end)
    self.FrameCache[frameID].Icon:SetTexture(icon)
    self.FrameCache[frameID].Amount:SetText(amount)
    self.FrameCache[frameID].Name:SetText(name)
    self.FrameCache[frameID].Name:SetTextColor(r, g, b)

    self:Recalculate()
end

function Widget:RemoveCategory(plugin, category, id)
    if self.Plugins[plugin].Categories[category] == nil then return end

    self:CleanCategory(self.Plugins[plugin].Categories[category].Frame)

    for _, item in pairs(self.Plugins[plugin].Categories[category].Items) do
        self:CleanItem(item.Frame)
    end

    self.Plugins[plugin].Categories[category] = nil
    self:Recalculate()
end

function Widget:RemoveItem(category, id)
    self:CleanItem(category.Items[id].Frame)
    category.Items[id] = nil
    self:Recalculate()
end

function Widget:FindCategoryFrame(parent)
    for index, value in pairs(self.FrameCache) do
        if not value.Taken and value.Type == 0 then
            self.FrameCache[index].Taken = true
            self.FrameCache[index].Icon:SetRotation(math.rad(-90))
            self.FrameCache[index]:SetParent(parent)
            return index
        end
    end
    local id = #self.FrameCache + 1
    self.FrameCache[id] = CreateFrame("Frame", nil, parent)
    self.FrameCache[id]:SetHeight(20)

    self.FrameCache[id].Icon = self.FrameCache[id]:CreateTexture(nil, "OVERLAY")
    self.FrameCache[id].Icon:SetPoint("LEFT", self.FrameCache[id])
    self.FrameCache[id].Icon:SetSize(11, 11)
    self.FrameCache[id].Icon:SetTexture("Interface/Moneyframe/Arrow-Right-Down.blp")
    self.FrameCache[id].Icon:SetRotation(math.rad(-90))

    self.FrameCache[id].Text = self.FrameCache[id]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.FrameCache[id].Text:SetPoint("LEFT", self.FrameCache[id].Icon, "RIGHT")
    self.FrameCache[id].Text:SetPoint("RIGHT", self.FrameCache[id])
    self.FrameCache[id].Text:SetHeight(20)
    self.FrameCache[id].Text:SetJustifyH("LEFT")

    self.FrameCache[id].Type = 0
    self.FrameCache[id].Taken = true
    return id
end

function Widget:FindItemFrame(parent)
    for index, value in pairs(self.FrameCache) do
        if not value.Taken and value.Type == 1 then
            self.FrameCache[index].Taken = true
            self.FrameCache[index]:SetParent(parent)
            return index
        end
    end
    local id = #self.FrameCache + 1
    self.FrameCache[id] = CreateFrame("Frame", nil, parent)
    self.FrameCache[id]:SetHeight(20)

    self.FrameCache[id].Icon = self.FrameCache[id]:CreateTexture(nil, "OVERLAY")
    self.FrameCache[id].Icon:SetSize(15, 15)
    self.FrameCache[id].Icon:SetPoint("LEFT", self.FrameCache[id])

    self.FrameCache[id].Amount = self.FrameCache[id]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.FrameCache[id].Amount:SetPoint("RIGHT", self.FrameCache[id])
    self.FrameCache[id].Amount:SetJustifyH("RIGHT")
    self.FrameCache[id].Amount:SetHeight(20)

    self.FrameCache[id].Frequency = self.FrameCache[id]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.FrameCache[id].Frequency:SetPoint("RIGHT", self.FrameCache[id].Amount, "LEFT", -20, 0)
    self.FrameCache[id].Frequency:SetJustifyH("RIGHT")
    self.FrameCache[id].Frequency:SetHeight(20)

    self.FrameCache[id].Name = self.FrameCache[id]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.FrameCache[id].Name:SetPoint("LEFT", self.FrameCache[id].Icon, "RIGHT", 5, 0)
    self.FrameCache[id].Name:SetPoint("RIGHT", self.FrameCache[id].Frequency, "LEFT", -5, 0)
    self.FrameCache[id].Name:SetJustifyH("LEFT")
    self.FrameCache[id].Name:SetHeight(20)

    self.FrameCache[id].Type = 1
    self.FrameCache[id].Taken = true
    return id
end

function Widget:ToggleCategory(path, offset)
    local categories = Grindon:Split(path, "/")

    local target = self.Tree
    for i = 1, offset, 1
    do
        target = target.Categories[categories[i]]
    end

    for _, item in pairs(target.Items) do
        if target.Active then
            self.FrameCache[item.Frame]:Hide()
        else
            self.FrameCache[item.Frame]:Show()
        end
    end

    for _, category in pairs(target.Categories) do
        if target.Active then
            self.FrameCache[category.Frame]:Hide()
        else
            self.FrameCache[category.Frame]:Show()
        end
    end

    target.Active = not target.Active

    if target.Active then
        self.FrameCache[target.Frame].Icon:SetRotation(math.rad(-90))
    else
        self.FrameCache[target.Frame].Icon:SetRotation(0)
    end

    self:Recalculate()
end

function Widget:Recalculate()
    self.LastParent = self.ContentTop
    self:RecalculateCategory(self.Tree, 0)
end

function Widget:RecalculateCategory(category, offset)
    for _, category in pairs(category.Categories) do
        self.FrameCache[category.Frame]:SetPoint("TOP", self.LastParent, "BOTTOM")
        self.FrameCache[category.Frame]:SetPoint("LEFT", self.Content, offset, 0)
        self.FrameCache[category.Frame]:SetPoint("RIGHT", self.Content)
        self.FrameCache[category.Frame]:Show()
        self.LastParent = self.FrameCache[category.Frame]

        if category.Active then

            for _, item in pairs(category.Items) do
                self.FrameCache[item.Frame]:SetPoint("TOP", self.LastParent, "BOTTOM")
                self.FrameCache[item.Frame]:SetPoint("LEFT", self.Content, offset + 10, 0)
                self.FrameCache[item.Frame]:SetPoint("RIGHT", self.Content)
                self.FrameCache[item.Frame]:Show()
                self.LastParent = self.FrameCache[item.Frame]
            end

            self:RecalculateCategory(category, offset + 10)
        end
    end
end

function Widget:UpdateFrequency(category)
    for _, category in pairs(category.Categories) do
        if category.Active then
            for _, item in pairs(category.Items) do
                if item.Frequency then
                    local frequency = string.format("%.2f", (item.Amount * 60) / self.Time):gsub("%.?0+$", "")
                    self.FrameCache[item.Frame].Frequency:SetText(frequency .. "/m")
                end
            end
            self:UpdateFrequency(category)
        end
    end
end

function Widget:CleanCategory(category)
    for _, category in pairs(category.Categories) do
        self.FrameCache[category.Frame]:SetScript("OnMouseDown", nil)
        self.FrameCache[category.Frame].Text:SetText(nil)
        self.FrameCache[category.Frame].Taken = false
        self.FrameCache[category.Frame]:Hide()

        for _, item in pairs(category.Items) do
            self:CleanItem(item.Frame)
        end

        self:CleanCategory(category)
    end
end

function Widget:CleanItem(frame)
    self.FrameCache[frame]:SetScript("OnMouseDown", nil)
    self.FrameCache[frame].Icon:SetTexture(nil)
    self.FrameCache[frame].Amount:SetText(nil)
    self.FrameCache[frame].Name:SetText(nil)
    self.FrameCache[frame].Frequency:SetText(nil)
    self.FrameCache[frame].Taken = false
    self.FrameCache[frame]:Hide()
end

function Widget:ToggleFrequency(val)
    if val == false then
        self:CleanFrequency(self.Tree)
    end

    database.profile.frequency = val
end

function Widget:CleanFrequency(category)
    for _, category in pairs(category.Categories) do
        for _, item in pairs(category.Items) do
            self.FrameCache[item.Frame].Frequency:SetText(nil)
        end
        self:CleanFrequency(category)
    end
end

function Widget:OnProfileChanged()
    Window.RegisterConfig(self.Frame, database.profile.transform)
    Window.RestorePosition(self.Frame)
    self.Frame:SetSize(database.profile.transform.sizeX, database.profile.transform.sizeY)

    local colors = database.profile.colors
    self.HeaderBackground:SetColorTexture(colors.header.bg.r, colors.header.bg.g, colors.header.bg.b, colors.header.bg.a)
    self.ContentBackground:SetColorTexture(colors.content.bg.r, colors.content.bg.g, colors.content.bg.b, colors.content.bg.a)
    self.Header.Title:SetTextColor(colors.header.text.r, colors.header.text.g, colors.header.text.b)
    self.Header.Time:SetTextColor(colors.header.text.r, colors.header.text.g, colors.header.text.b)
end

function Widget:ResetSettings()
    database:ResetProfile()

    self:OnProfileChanged()
end

function Widget:Hex2RGB(hex)
    local result = hex:gsub("#","")
    return tonumber("0x"..result:sub(1,2)) / 255, tonumber("0x"..result:sub(3,4)) / 255, tonumber("0x"..result:sub(5,6)) / 255
end
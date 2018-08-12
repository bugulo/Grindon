local AceAddon = LibStub("AceAddon-3.0")

local Grinder = AceAddon:GetAddon("Grinder")
local Widget = Grinder:NewModule("Widget", "AceTimer-3.0", "AceConsole-3.0", "AceEvent-3.0")

local Config = Grinder:GetModule("Config")

local options = {
    lockMove = {
        name = "Lock Frame Moving",
        type = "toggle",
        set = function(_, val) Widget.Database.profile.lockMove = val end,
        get = function() return Widget.Database.profile.lockMove end
    },
    lockSize = {
        name = "Lock Frame Sizing",
        type = "toggle",
        set = function(_, val) Widget.Database.profile.lockSize = val end,
        get = function() return Widget.Database.profile.lockSize end
    }
}

local defaults = {
    profile = {
        lockMove = false,
        lockSize = false
    }
}

function Widget:OnInitialize()
    self.Database = Grinder.Database:RegisterNamespace("Widget", defaults)

    Config:Register("Widget", options)

    self:RegisterMessage("OnSegmentStart", "OnSegmentStart")
    self:RegisterMessage("OnSegmentStop", "OnSegmentStop")

    self:CreateFrame()

    --self.Frame:Show()
    --self:SetItem("Test", "test", 133784, "test", "test", false)
end

function Widget:OnSegmentStart()
    self.Time = 0
    self.Timer = self:ScheduleRepeatingTimer("SegmentTimer", 1)

    self.Frame:Show()
end

function Widget:OnSegmentStop()
    self:CancelTimer(self.Timer)

    self:Clean()
    self.Frame:Hide()
end

function Widget:CreateFrame()
    self.Frame = CreateFrame("Frame", "GrinderWidget" , UIParent);
    self.Frame:SetResizable(true)
    self.Frame:SetMovable(true)
    self.Frame:SetPoint("CENTER", UIParent)
    self.Frame:SetSize(200, 200)
    self.Frame:SetMinResize(200, 200)
    self.Frame:SetClampedToScreen(true)

    local FrameBackground = self.Frame:CreateTexture(nil, "BACKGROUND")
    FrameBackground:SetColorTexture(0, 0, 0, 0.5)
    FrameBackground:SetAllPoints(self.Frame);

    self.Header = CreateFrame("Frame", "GrinderWidgetHeader" , self.Frame);
    self.Header:EnableMouse(true)
    self.Header:SetPoint("TOPLEFT", self.Frame)
    self.Header:SetPoint("TOPRIGHT", self.Frame)
    self.Header:SetHeight(25)
    self.Header:RegisterForDrag("LeftButton")
    self.Header:SetScript("OnDragStart", function() if not Widget.Database.profile.lockMove then self.Frame:StartMoving() end end)
    self.Header:SetScript("OnDragStop", function() self.Frame:StopMovingOrSizing() end)

    local HeaderBackground = self.Header:CreateTexture(nil, "OVERLAY")
    HeaderBackground:SetColorTexture(0, 0, 0, 0.6)
    HeaderBackground:SetAllPoints(self.Header);

    self.Header.Time = self.Header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.Header.Time:SetPoint("RIGHT", self.Header, -5, 0)
    self.Header.Time:SetText("00:00:00")

    self.Header.Title = self.Header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.Header.Title:SetPoint("LEFT", self.Header, 5, 0)
    self.Header.Title:SetPoint("RIGHT", self.Header.Time, "LEFT")
    self.Header.Title:SetText("Grinder Segment")
    self.Header.Title:SetJustifyH("LEFT")
    self.Header.Title:SetHeight(20)

    self.Content = CreateFrame("Frame", "GrinderWidgetContent" , self.Frame);
    --self.Content:EnableMouse(true)
    self.Content:SetPoint("TOPLEFT", self.Header, "BOTTOMLEFT", 5, -5)
    self.Content:SetPoint("BOTTOMRIGHT", self.Frame, -5, 5)
    self.Content:SetClipsChildren(true)

    self.ContentTop = CreateFrame("Frame", "GrinderWidgetContentTop" , self.Content);
    self.ContentTop:SetPoint("TOPLEFT", self.Content)
    self.ContentTop:SetPoint("TOPRIGHT", self.Content)
    self.ContentTop:SetHeight(1)

    --local ContentBackground = self.Content:CreateTexture(nil, "BACKGROUND")
    --ContentBackground:SetColorTexture(0, 1, 0)
    --ContentBackground:SetAllPoints(self.Content);

    self.Anchor = CreateFrame("Frame", "GrinderWidgetAnchor", self.Frame);
    self.Anchor:EnableMouse(true)
    self.Anchor:SetPoint("BOTTOMRIGHT", self.Frame, "BOTTOMRIGHT")
    self.Anchor:SetSize(30, 30)
    self.Anchor:RegisterForDrag("LeftButton")
    self.Anchor:SetScript("OnDragStart", function() if not Widget.Database.profile.lockSize then self.Frame:StartSizing() end end)
    self.Anchor:SetScript("OnDragStop", function() self.Frame:StopMovingOrSizing() end)

    local AnchorBackground = self.Anchor:CreateTexture(nil, "OVERLAY")
    AnchorBackground:SetTexture("Interface/Cursor/Item.blp")
    AnchorBackground:SetRotation(math.rad(-180))
    AnchorBackground:SetAllPoints(self.Anchor);

    self.Content.Categories = {}

    self.Frame:Hide()
end

function Widget:SegmentTimer()
    self.Time = self.Time + 1
    local h = string.format("%02.f", math.floor(self.Time / 3600));
    local m = string.format("%02.f", math.floor(self.Time / 60 - (h * 60)));
    local s = string.format("%02.f", math.floor(self.Time - h * 3600 - m * 60));
    self.Header.Time:SetText(h .. ":" .. m .. ":" .. s)

    self:UpdateFrequency()
end

function Widget:SetItem(category, id, icon, name, amount, frequency)
    if frequency == nil then frequency = true end

    if self.Content.Categories[category] == nil then
        self.Content.Categories[category] = self.Content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        self.Content.Categories[category]:SetHeight(20)
        self.Content.Categories[category]:SetJustifyH("LEFT")
        self.Content.Categories[category].Items = {}
    end

    if self.Content.Categories[category].Items[id] == nil then
        self.Content.Categories[category].Items[id] = CreateFrame("Frame", nil, self.Content)
        self.Content.Categories[category].Items[id]:SetHeight(20)

        self.Content.Categories[category].Items[id].Icon = self.Content.Categories[category].Items[id]:CreateTexture(nil, "OVERLAY")
        self.Content.Categories[category].Items[id].Icon:SetSize(15, 15)
        self.Content.Categories[category].Items[id].Icon:SetPoint("LEFT", self.Content.Categories[category].Items[id], 5, 0)

        self.Content.Categories[category].Items[id].Amount = self.Content.Categories[category].Items[id]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        self.Content.Categories[category].Items[id].Amount:SetPoint("RIGHT", self.Content.Categories[category].Items[id])
        self.Content.Categories[category].Items[id].Amount:SetJustifyH("RIGHT")
        self.Content.Categories[category].Items[id].Amount:SetHeight(20)

        self.Content.Categories[category].Items[id].Frequency = self.Content.Categories[category].Items[id]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        self.Content.Categories[category].Items[id].Frequency:SetPoint("RIGHT", self.Content.Categories[category].Items[id].Amount, "LEFT", -20, 0)
        self.Content.Categories[category].Items[id].Frequency:SetJustifyH("RIGHT")
        self.Content.Categories[category].Items[id].Frequency:SetHeight(20)

        self.Content.Categories[category].Items[id].Name = self.Content.Categories[category].Items[id]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        self.Content.Categories[category].Items[id].Name:SetPoint("LEFT", self.Content.Categories[category].Items[id].Icon, "RIGHT", 5, 0)
        self.Content.Categories[category].Items[id].Name:SetPoint("RIGHT", self.Content.Categories[category].Items[id].Frequency, "LEFT", -5, 0)
        self.Content.Categories[category].Items[id].Name:SetJustifyH("LEFT")
        self.Content.Categories[category].Items[id].Name:SetHeight(20)
    end

    self.Content.Categories[category]:SetText(category)
    self.Content.Categories[category].Items[id].Icon:SetTexture(icon)
    self.Content.Categories[category].Items[id].Amount:SetText(amount)
    self.Content.Categories[category].Items[id].Name:SetText(name)

    if frequency then
        local frequency = string.format("%.3f", (amount * 60) / self.Time):gsub("%.?0+$", "")
        self.Content.Categories[category].Items[id].Frequency:SetText(frequency .. "/m")
        self.Content.Categories[category].Items[id].Amount.Value = amount
    end

    self.Content.Categories[category].Active = true
    self.Content.Categories[category].Items[id].Active = true
    self:Recalculate()
end

function Widget:UpdateItem(category, id, amount)
    self.Content.Categories[category].Items[id].Amount:SetText(amount)

    if self.Content.Categories[category].Items[id].Frequency:GetText() then
        local frequency = string.format("%.3f", (amount * 60) / self.Time):gsub("%.?0+$", "")
        self.Content.Categories[category].Items[id].Frequency:SetText(frequency .. "/m")
        self.Content.Categories[category].Items[id].Amount.Value = amount
    end
end

function Widget:ItemExists(category, id)
    return (self.Content.Categories[category] ~= nil and self.Content.Categories[category].Items[id] ~= nil and self.Content.Categories[category].Items[id].Active == true)
end

function Widget:Recalculate()
    local lastItem = self.ContentTop
    for name, category in pairs(self.Content.Categories) do
        if category.Active then
            self.Content.Categories[name]:SetPoint("TOPLEFT", lastItem, "BOTTOMLEFT")
            self.Content.Categories[name]:SetPoint("TOPRIGHT", lastItem, "BOTTOMRIGHT")
            lastItem = self.Content.Categories[name]

            for id, item in pairs(category.Items) do
                if item.Active then
                    self.Content.Categories[name].Items[id]:SetPoint("TOPLEFT", lastItem, "BOTTOMLEFT")
                    self.Content.Categories[name].Items[id]:SetPoint("TOPRIGHT", lastItem, "BOTTOMRIGHT")
                    lastItem = self.Content.Categories[name].Items[id]
                end
            end
        end
    end
end

function Widget:UpdateFrequency()
    for name, category in pairs(self.Content.Categories) do
        if category.Active then
            for id, item in pairs(category.Items) do
                if item.Active then
                    if self.Content.Categories[name].Items[id].Frequency:GetText() then
                        local amount = self.Content.Categories[name].Items[id].Amount.Value
                        local frequency = string.format("%.3f", (amount * 60) / self.Time):gsub("%.?0+$", "")
                        self.Content.Categories[name].Items[id].Frequency:SetText(frequency .. "/m")
                    end
                end
            end
        end
    end
end

function Widget:Clean()
    self.Header.Time:SetText("00:00:00")

    for name, category in pairs(self.Content.Categories) do
        self.Content.Categories[name].Active = false
        self.Content.Categories[name]:SetText(nil)

        for id, _ in pairs(category.Items) do
            self.Content.Categories[name].Items[id].Active = false
            self.Content.Categories[name].Items[id].Icon:SetTexture(nil)
            self.Content.Categories[name].Items[id].Amount:SetText(nil)
            self.Content.Categories[name].Items[id].Amount.Value = nil
            self.Content.Categories[name].Items[id].Frequency:SetText(nil)
            self.Content.Categories[name].Items[id].Name:SetText(nil)
        end
    end
end
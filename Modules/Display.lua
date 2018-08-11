local AceAddon = LibStub("AceAddon-3.0")

local Grinder = AceAddon:GetAddon("Grinder")
local Display = Grinder:NewModule("Display", "AceTimer-3.0", "AceConsole-3.0", "AceEvent-3.0")

function Display:OnInitialize()
    self:RegisterMessage("OnSegmentStart", "OnSegmentStart")
    self:RegisterMessage("OnSegmentStop", "OnSegmentStop")

    self:CreateFrame()
end

function Display:OnSegmentStart()
    self.Time = 0
    self.Timer = self:ScheduleRepeatingTimer("SegmentTimer", 1)

    self.Frame:Show()
end

function Display:OnSegmentStop()
    self:CancelTimer(self.Timer)

    self:Clean()
    self.Frame:Hide()
end

function Display:CreateFrame()
    self.Frame = CreateFrame("Frame", "DisplayFrame" , UIParent);
    self.Frame:SetResizable(true)
    self.Frame:SetMovable(true)
    self.Frame:SetPoint("CENTER", UIParent)
    self.Frame:SetSize(200, 200)
    self.Frame:SetMinResize(200, 200)
    self.Frame:SetClampedToScreen(true)
    self.Frame:SetClipsChildren(true)

    self.Header = CreateFrame("Frame", "DisplayHeader" , self.Frame);
    self.Header:EnableMouse(true)
    self.Header:SetPoint("TOPLEFT", self.Frame)
    self.Header:SetPoint("TOPRIGHT", self.Frame)
    self.Header:SetHeight(20)
    self.Header:RegisterForDrag("LeftButton")
    self.Header:SetScript("OnDragStart", function() self.Frame:StartMoving() end)
    self.Header:SetScript("OnDragStop", function() self.Frame:StopMovingOrSizing() end)

    local HeaderBackground = self.Header:CreateTexture(nil, "OVERLAY")
    HeaderBackground:SetColorTexture(0, 0, 0)
    HeaderBackground:SetAllPoints(self.Header);

    self.Content = CreateFrame("Frame", "DisplayContent" , self.Frame);
    self.Content:EnableMouse(true)
    self.Content:SetPoint("TOPLEFT", self.Frame, 0, -20)
    self.Content:SetPoint("BOTTOMRIGHT", self.Frame)

    local ContentBackground = self.Content:CreateTexture(nil, "BACKGROUND")
    ContentBackground:SetColorTexture(0, 1, 0)
    ContentBackground:SetAllPoints(self.Content);

    self.Anchor = CreateFrame("Frame", "Anchor", self.Content);
    self.Anchor:EnableMouse(true)
    self.Anchor:SetPoint("BOTTOMRIGHT", self.Content, "BOTTOMRIGHT")
    self.Anchor:SetSize(20, 20)
    self.Anchor:RegisterForDrag("LeftButton")
    self.Anchor:SetScript("OnDragStart", function() self.Frame:StartSizing() end)
    self.Anchor:SetScript("OnDragStop", function() self.Frame:StopMovingOrSizing() end)

    local AnchorBackground = self.Anchor:CreateTexture(nil, "OVERLAY")
    AnchorBackground:SetColorTexture(0, 0, 0)
    AnchorBackground:SetAllPoints(self.Anchor);

    self.Content.Categories = {}

    self.Frame:Hide()
end

function Display:SegmentTimer()
    self.Time = self.Time + 1
    local h = string.format("%02.f", math.floor(self.Time / 3600));
    local m = string.format("%02.f", math.floor(self.Time / 60 - (h * 60)));
    local s = string.format("%02.f", math.floor(self.Time - h * 3600 - m * 60));
    --self.Content.Time:SetText(h .. ":" .. m .. ":" .. s)
end

function Display:SetItem(category, id, icon, name, amount)
    if self.Content.Categories[category] == nil then
        self.Content.Categories[category] = self.Content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        self.Content.Categories[category]:SetHeight(20)
        self.Content.Categories[category].Items = {}
    end

    if self.Content.Categories[category].Items[id] == nil then
        self.Content.Categories[category].Items[id] = CreateFrame("Frame", nil, self.Content)
        self.Content.Categories[category].Items[id]:SetHeight(20)

        self.Content.Categories[category].Items[id].Icon = self.Content.Categories[category].Items[id]:CreateTexture(nil, "OVERLAY")
        self.Content.Categories[category].Items[id].Icon:SetSize(15, 15)
        self.Content.Categories[category].Items[id].Icon:SetPoint("TOPLEFT", self.Content.Categories[category].Items[id])

        self.Content.Categories[category].Items[id].Name = self.Content.Categories[category].Items[id]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        self.Content.Categories[category].Items[id].Name:SetPoint("CENTER", self.Content.Categories[category].Items[id])

        self.Content.Categories[category].Items[id].Amount = self.Content.Categories[category].Items[id]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        self.Content.Categories[category].Items[id].Amount:SetPoint("TOPRIGHT", self.Content.Categories[category].Items[id])
    end

    self.Content.Categories[category]:SetText(category)
    self.Content.Categories[category].Items[id].Icon:SetTexture(icon)
    self.Content.Categories[category].Items[id].Name:SetText(name)
    self.Content.Categories[category].Items[id].Amount:SetText(amount)

    self.Content.Categories[category].Active = true
    self.Content.Categories[category].Items[id].Active = true
    self:Recalculate()
end

function Display:UpdateItem(category, id, amount)
    self.Content.Categories[category].Items[id].Amount:SetText(amount)
end

function Display:ItemExists(category, id)
    return (self.Content.Categories[category] ~= nil and self.Content.Categories[category].Items[id] ~= nil and self.Content.Categories[category].Items[id].Active == true)
end

function Display:Recalculate()
    local lastItem = self.Header
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

function Display:Clean()
    --self.Content.Time:SetText("00:00:00")

    for name, category in pairs(self.Content.Categories) do
        self.Content.Categories[name].Active = false
        self.Content.Categories[name]:SetText(nil)

        for id, _ in pairs(category.Items) do
            self.Content.Categories[name].Items[id].Active = false
            self.Content.Categories[name].Items[id].Icon:SetTexture(nil)
            self.Content.Categories[name].Items[id].Name:SetText(nil)
            self.Content.Categories[name].Items[id].Amount:SetText(nil)
        end
    end
end
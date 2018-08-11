local AceAddon = LibStub("AceAddon-3.0")

local Grinder = AceAddon:GetAddon("Grinder")
local Display = Grinder:NewModule("Display", "AceTimer-3.0", "AceConsole-3.0", "AceEvent-3.0")

function Display:OnInitialize()
    self:RegisterMessage("OnSegmentStart", "OnSegmentStart")
    self:RegisterMessage("OnSegmentStop", "OnSegmentStop")
end

function Display:OnSegmentStart()
    self.Time = 0
    self.Timer = self:ScheduleRepeatingTimer("SegmentTimer", 1)

    self.Frame = CreateFrame("Frame", "DisplayFrame", UIParent)
    self.Frame:SetSize(200, 200)
    self.Frame:SetPoint("CENTER", UIParent)

    self.Frame:EnableMouse(true)
    self.Frame:SetMovable(true)
    self.Frame:SetResizable(true)
    self.Frame:RegisterForDrag("LeftButton")
    self.Frame:SetScript("OnDragStart", self.Frame.StartMoving)
    self.Frame:SetScript("OnDragStop", self.Frame.StopMovingOrSizing)

    self.Frame.Header = self.Frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.Frame.Header:SetPoint("TOPLEFT", self.Frame, "TOPLEFT", 0, 0)
    self.Frame.Header:SetText("Grinder")

    self.Frame.Time = self.Frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.Frame.Time:SetPoint("TOPRIGHT", self.Frame, "TOPRIGHT", 0, 0)
    self.Frame.Time:SetText("00:00:00")

    self.Frame.Categories = {}
    self.Frame.Headers = {}
end

function Display:OnSegmentStop()
    self:CancelTimer(self.Timer)
    self.Frame:Hide()
end

function Display:SegmentTimer()
    self.Time = self.Time + 1
    local h = string.format("%02.f", math.floor(self.Time / 3600));
    local m = string.format("%02.f", math.floor(self.Time / 60 - (h * 60)));
    local s = string.format("%02.f", math.floor(self.Time - h * 3600 - m * 60));
    self.Frame.Time:SetText(h .. ":" .. m .. ":" .. s)
end

function Display:SetItem(category, id, icon, name, amount)
    if self.Frame.Categories[category] == nil then
        self.Frame.Categories[category] = {}

        self.Frame.Headers[category] = self.Frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        self.Frame.Headers[category]:SetText(category)
    end

    self.Frame.Categories[category][id] = {}

    self.Frame.Categories[category][id].Icon = self.Frame:CreateTexture(nil, "OVERLAY")
    self.Frame.Categories[category][id].Icon:SetSize(15, 15)
    self.Frame.Categories[category][id].Icon:SetTexture(icon)

    self.Frame.Categories[category][id].Name = self.Frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.Frame.Categories[category][id].Name:SetText(name)

    self.Frame.Categories[category][id].Amount = self.Frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.Frame.Categories[category][id].Amount:SetText(amount)

    self:Recalculate()
end

function Display:UpdateItem(category, id, amount)
    self.Frame.Categories[category][id].Amount:SetText(amount)
end

function Display:ItemExists(category, id)
    return (self.Frame.Categories[category] ~= nil and self.Frame.Categories[category][id] ~= nil)
end

function Display:Recalculate()
    local i = 0
    for category, items in pairs(self.Frame.Categories) do
        self.Frame.Headers[category]:SetPoint("TOPLEFT", self.Frame, "TOPLEFT", 0, -20 + -20 * i)
        i = i + 1

        for id, _ in pairs(items) do
            self.Frame.Categories[category][id].Icon:SetPoint("TOPLEFT", self.Frame, "TOPLEFT", 5, -17 + -20 * i)
            self.Frame.Categories[category][id].Name:SetPoint("TOPLEFT", self.Frame, "TOPLEFT", 25, -18 + -20 * i)
            self.Frame.Categories[category][id].Amount:SetPoint("TOPRIGHT", self.Frame, "TOPRIGHT", 0, -18 + -20 * i)
            i = i + 1
        end
    end
end
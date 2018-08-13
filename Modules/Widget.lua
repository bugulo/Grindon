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
    },
    frequency = {
        name = "Allow frequency meter",
        type = "toggle",
        set = function(_, val) Widget:ToggleFrequency(val) end,
        get = function() return Widget.Database.profile.frequency end
    }
}

local defaults = {
    profile = {
        lockMove = false,
        lockSize = false,
        frequency = true,
    }
}

function Widget:OnInitialize()
    self.Database = Grinder.Database:RegisterNamespace("Widget", defaults)

    Config:Register("Widget", options, 1)

    self.FrameCache = {}

    self:RegisterMessage("OnSegmentStart", "OnSegmentStart")
    self:RegisterMessage("OnSegmentStop", "OnSegmentStop")

    self:CreateFrame()

    --[[self.Plugins = {}
    self.Frame:Show()
    self:SetItem("Core", "Test", "test", 133784, "test", "test", false)
    self:SetItem("Core", "Test", "testt", 133784, "test", "test", false)

    self:RemoveCategory("Core", "Test")
    self:RemoveItem("Core", "Test", "testt")--]]
end

function Widget:OnSegmentStart()
    self.Time = 0
    self.Timer = self:ScheduleRepeatingTimer("SegmentTimer", 1)

    self.Plugins = {}

    self.Frame:Show()
end

function Widget:OnSegmentStop()
    self:CancelTimer(self.Timer)

    self:Clean()
    self.Plugins = nil
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

    if Widget.Database.profile.frequency then self:UpdateFrequency() end
end

function Widget:SetItem(plugin, category, id, icon, name, amount, frequency)
    if frequency == nil then frequency = true end

    if self.Plugins[plugin] == nil then
        local frameID = self:FindCategoryFrame(self.Content)
        self.Plugins[plugin] = {
            Frame = frameID,
            Active = true,
            Categories = {}
        }
        self.FrameCache[frameID]:SetScript("OnMouseDown", function(_, button) if button == "LeftButton" then self:TogglePlugin(plugin) end end)
        self.FrameCache[frameID].Text:SetText(plugin)
    end

    if self.Plugins[plugin].Categories[category] == nil then
        local frameID = self:FindCategoryFrame(self.FrameCache[self.Plugins[plugin].Frame])
        self.Plugins[plugin].Categories[category] = {
            Frame = frameID,
            Active = true,
            Items = {}
        }
        self.FrameCache[frameID]:SetScript("OnMouseDown", function(_, button) if button == "LeftButton" then self:ToggleCategory(plugin, category) end end)
        self.FrameCache[frameID].Text:SetPoint("LEFT", self.FrameCache[frameID], 10, 0)
        self.FrameCache[frameID].Text:SetText(category)
    end

    local frameID = self:FindItemFrame(self.FrameCache[self.Plugins[plugin].Categories[category].Frame])
    self.Plugins[plugin].Categories[category].Items[id] = {
        Frame = frameID,
        Icon = icon,
        Name = name,
        Amount = amount,
        Frequency = frequency
    }

    self.FrameCache[frameID].Icon:SetTexture(icon)
    self.FrameCache[frameID].Amount:SetText(amount)
    self.FrameCache[frameID].Name:SetText(name)

    self:Recalculate()
end

function Widget:UpdateItem(plugin, category, id, amount)
    local frameID = self.Plugins[plugin].Categories[category].Items[id].Frame

    self.Plugins[plugin].Categories[category].Items[id].Amount = amount
    self.FrameCache[frameID].Amount:SetText(amount)
end

function Widget:ItemExists(plugin, category, id)
    return (self.Plugins[plugin] ~= nil and self.Plugins[plugin].Categories[category] ~= nil and self.Plugins[plugin].Categories[category].Items[id] ~= nil)
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

function Widget:RemoveItem(plugin, category, id)
    if self.Plugins[plugin].Categories[category].Items[id] == nil then return end

    self:CleanItem(self.Plugins[plugin].Categories[category].Items[id].Frame)

    self.Plugins[plugin].Categories[category].Items[id] = nil
    self:Recalculate()
end

function Widget:FindCategoryFrame(parent)
    for index, value in pairs(self.FrameCache) do
        if not value.Taken and value.Type == 0 then
            self.FrameCache[index].Taken = true
            self.FrameCache[index]:Show()
            return index
        end
    end
    local id = #self.FrameCache + 1
    self.FrameCache[id] = CreateFrame("Frame", nil, parent)
    self.FrameCache[id]:SetHeight(20)

    self.FrameCache[id].Text =  self.FrameCache[id]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.FrameCache[id].Text:SetPoint("LEFT", self.FrameCache[id])
    self.FrameCache[id].Text:SetPoint("RIGHT", self.FrameCache[id])
    self.FrameCache[id].Text:SetHeight(20)
    self.FrameCache[id].Text:SetJustifyH("LEFT")

    self.FrameCache[id].Type = 0
    self.FrameCache[id].Taken = true
    self.FrameCache[id]:Show()
    return id
end

function Widget:FindItemFrame(parent)
    for index, value in pairs(self.FrameCache) do
        if not value.Taken and value.Type == 1 then
            self.FrameCache[index].Taken = true
            self.FrameCache[index]:Show()
            return index
        end
    end
    local id = #self.FrameCache + 1
    self.FrameCache[id] = CreateFrame("Frame", nil, parent)
    self.FrameCache[id]:SetHeight(20)

    self.FrameCache[id].Icon = self.FrameCache[id]:CreateTexture(nil, "OVERLAY")
    self.FrameCache[id].Icon:SetSize(15, 15)
    self.FrameCache[id].Icon:SetPoint("LEFT", self.FrameCache[id], 20, 0)

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
    self.FrameCache[id]:Show()
    return id
end

function Widget:TogglePlugin(plugin)
    for _, category in pairs(self.Plugins[plugin].Categories) do
        if self.Plugins[plugin].Active then
            self.FrameCache[category.Frame]:Hide()
        else
            self.FrameCache[category.Frame]:Show()
        end
    end
    self.Plugins[plugin].Active = not self.Plugins[plugin].Active
    self:Recalculate()
end

function Widget:ToggleCategory(plugin, category)
    for _, item in pairs(self.Plugins[plugin].Categories[category].Items) do
        if self.Plugins[plugin].Categories[category].Active then
            self.FrameCache[item.Frame]:Hide()
        else
            self.FrameCache[item.Frame]:Show()
        end
    end
    self.Plugins[plugin].Categories[category].Active = not self.Plugins[plugin].Categories[category].Active
    self:Recalculate()
end

function Widget:Recalculate()
    local lastItem = self.ContentTop
    for _, plugin in pairs(self.Plugins) do
        self.FrameCache[plugin.Frame]:SetPoint("TOPLEFT", lastItem, "BOTTOMLEFT")
        self.FrameCache[plugin.Frame]:SetPoint("TOPRIGHT", lastItem, "BOTTOMRIGHT")
        lastItem = self.FrameCache[plugin.Frame]

        if plugin.Active then
            for _, category in pairs(plugin.Categories) do
                self.FrameCache[category.Frame]:SetPoint("TOPLEFT", lastItem, "BOTTOMLEFT")
                self.FrameCache[category.Frame]:SetPoint("TOPRIGHT", lastItem, "BOTTOMRIGHT")
                lastItem = self.FrameCache[category.Frame]

                if category.Active then
                    for _, item in pairs(category.Items) do
                        self.FrameCache[item.Frame]:SetPoint("TOPLEFT", lastItem, "BOTTOMLEFT")
                        self.FrameCache[item.Frame]:SetPoint("TOPRIGHT", lastItem, "BOTTOMRIGHT")
                        lastItem = self.FrameCache[item.Frame]
                    end
                end
            end
        end
    end
end

function Widget:UpdateFrequency()
    for pluginName, plugin in pairs(self.Plugins) do
        if plugin.Active then
            for categoryName, category in pairs(plugin.Categories) do
                if category.Active then
                    for name, item in pairs(category.Items) do
                        if self.Plugins[pluginName].Categories[categoryName].Items[name].Frequency then
                            local amount = self.Plugins[pluginName].Categories[categoryName].Items[name].Amount
                            local frequency = string.format("%.2f", (amount * 60) / self.Time):gsub("%.?0+$", "")
                            self.FrameCache[item.Frame].Frequency:SetText(frequency .. "/m")
                        end
                    end
                end
            end
        end
    end
end

function Widget:Clean()
    self.Header.Time:SetText("00:00:00")

    for _, plugin in pairs(self.Plugins) do
        self:CleanCategory(plugin.Frame)

        for _, category in pairs(plugin.Categories) do
            self:CleanCategory(category.Frame)

            for _, item in pairs(category.Items) do
                self:CleanItem(item.Frame)
            end
        end
    end
end

function Widget:CleanCategory(frame)
    self.FrameCache[frame].Text:SetText(nil)
    self.FrameCache[frame].Taken = false
    self.FrameCache[frame]:Hide()
end

function Widget:CleanItem(frame)
    self.FrameCache[frame].Icon:SetTexture(nil)
    self.FrameCache[frame].Amount:SetText(nil)
    self.FrameCache[frame].Name:SetText(nil)
    self.FrameCache[frame].Frequency:SetText(nil)
    self.FrameCache[frame].Taken = false
    self.FrameCache[frame]:Hide()
end

function Widget:ToggleFrequency(val)
    if val == false then
        for _, plugin in pairs(self.Plugins) do
            for _, category in pairs(plugin.Categories) do
                for _, item in pairs(category.Items) do
                    self.FrameCache[item.Frame].Frequency:SetText(nil)
                end
            end
        end
    end

    Widget.Database.profile.frequency = val
end
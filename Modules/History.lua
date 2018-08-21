local AceGUI = LibStub("AceGUI-3.0")

local Grindon = LibStub("AceAddon-3.0"):GetAddon("Grindon")
local History = Grindon:NewModule("History", "AceConsole-3.0")

local Plugin = Grindon:GetModule("Plugin")
local Window = Grindon:GetModule("Window")

local L = LibStub("AceLocale-3.0"):GetLocale("Grindon").History

function History:OnInitialize()
    Window:AddItem("History", function(c) self:Open(c) end)
end

function History:Open(container)
    local group = AceGUI:Create("SimpleGroup")
    group:SetFullWidth(true)
    group:SetFullHeight(true)
    group:SetLayout("fill")

    container:AddChild(group)

    self.scroll = AceGUI:Create("ScrollFrame")
    self.scroll:SetLayout("Flow")
    group:AddChild(self.scroll)

    self:DrawIndex()
end

function History:DrawIndex()
    self.scroll:ReleaseChildren()

    local lastItem
    for i, value in Grindon:IterateSegments() do
        if i ~= Grindon:GetSegmentID() then
            local segment = AceGUI:Create("InteractiveLabel")
            segment:SetText("ID#" .. i .. ", " .. date('%Y-%m-%d %H:%M:%S', value.timeStart) .. ", " .. value.character)
            segment:SetImage(133784)
            segment:SetFullWidth(true)
            segment:SetHighlight("Interface/Tooltips/UI-Tooltip-Background")
            segment:SetCallback("OnClick", function() self:DrawSegment(i) end)
            self.scroll:AddChild(segment, lastItem)
            lastItem = segment
        end
    end
end

function History:DrawSegment(id)
    self.scroll:ReleaseChildren()

    local info = Grindon:GetSegmentInfo(id)

    local button = AceGUI:Create("Button")
    button:SetText("<- " .. L["Back"])
    button:SetWidth(100)
    button:SetCallback("OnClick", function() self:DrawIndex() end)
    self.scroll:AddChild(button)

    local button = AceGUI:Create("Button")
    button:SetText(L["Delete"])
    button:SetWidth(100)
    button:SetCallback("OnClick", function() self:DeleteSegment(id) end)
    self.scroll:AddChild(button)

    local item = AceGUI:Create("Label")
    item:SetText(L["Character"] .. ": " .. info.character)
    item:SetFullWidth(true)
    self.scroll:AddChild(item)

    local item = AceGUI:Create("Label")
    item:SetText(L["TimeStart"] .. ": " .. date('%Y-%m-%d %H:%M:%S', info.timeStart))
    item:SetFullWidth(true)
    self.scroll:AddChild(item)

    local item = AceGUI:Create("Label")
    item:SetText(L["TimeEnd"].. ": " .. date('%Y-%m-%d %H:%M:%S', info.timeEnd))
    item:SetFullWidth(true)
    self.scroll:AddChild(item)

    for name, module in Plugin:IterateModules() do
        if module.RequestHistory and module:IsEnabled() then
            local history = module:RequestHistory(id)

            if next(history) then
                local header = AceGUI:Create("Heading")
                header:SetText(name)
                header:SetFullWidth(true)

                self.scroll:AddChild(header)

                for _, value in pairs(history) do
                    local item = AceGUI:Create("Label")
                    item:SetText(value.Text)
                    item:SetImage(value.Icon)
                    item:SetRelativeWidth(0.7)
                    self.scroll:AddChild(item)

                    local amount = AceGUI:Create("Label")
                    amount:SetText(value.Amount)
                    amount:SetRelativeWidth(0.2)
                    self.scroll:AddChild(amount)
                end
            end
       end
    end
end

function History:DeleteSegment(id)
    Grindon:DeleteSegment(id)
    self:DrawIndex()
end
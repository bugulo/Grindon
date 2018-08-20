local AceGUI = LibStub("AceGUI-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local Grindon = LibStub("AceAddon-3.0"):GetAddon("Grindon")
local Window = Grindon:NewModule("Window", "AceConsole-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale("Grindon").Window

local items = {}

local opened = false

function Window:OnInitialize()
    self:RegisterChatCommand("grindon", "Open")

    self:AddItem(L["General"], function(c) self:General(c) end)
    self:AddItem(L["Config"], function(c) self:Config(c) end)
end

function Window:Open()
    if opened then return end

    local frame = AceGUI:Create("Frame")
    frame:SetTitle("Grindon")
    frame:SetCallback("OnClose", function(widget)
        AceGUI:Release(widget)
        opened = false
    end)
    frame:SetStatusText("Version: @project-version@")
    frame:SetLayout("Fill")

    local menu = AceGUI:Create("TreeGroup")
    menu:SetLayout("Flow")
    menu:SetTree(items)
    menu:SetCallback("OnGroupSelected", function(c, _, g) self:Change(c, g) end)
    menu:SelectByPath("General")

    frame:AddChild(menu)

    opened = true
end

function Window:Change(container, group)
    container:ReleaseChildren()
    for _, item in pairs(items) do
        if item.value == group then
            item.callback(container)
        end
    end
end

function Window:General(container)
    local heading = AceGUI:Create("Heading")
    heading:SetText("!!! " .. L["Notice"] .. " !!!")
    heading:SetFullWidth(true)
    container:AddChild(heading)

    local label = AceGUI:Create("Label")
    label:SetText(L["NoticeContent"])
    label:SetFont(GameFontNormal:GetFont(), 16)
    label:SetFullWidth(true)
    container:AddChild(label)

    local heading = AceGUI:Create("Heading")
    heading:SetFullWidth(true)
    container:AddChild(heading)

    local button = AceGUI:Create("Button")
    button:SetText(L["StartSegment"])
    button:SetCallback("OnClick", function() Grindon:StartSegment() end)
    container:AddChild(button)

    local button = AceGUI:Create("Button")
    button:SetText(L["StopSegment"])
    button:SetCallback("OnClick", function() Grindon:StopSegment() end)
    container:AddChild(button)
end

function Window:Config(container)
    local group = AceGUI:Create("SimpleGroup")
    group:SetFullWidth(true)
    group:SetFullHeight(true)
    group:SetLayout("fill")
    container:AddChild(group)

    AceConfigDialog:Open("Grindon", group)
end

function Window:AddItem(name, callback)
    table.insert(items, {text = name, value = name, callback = callback})
end
local AceAddon = LibStub("AceAddon-3.0")

local Grinder = AceAddon:GetAddon("Grinder")
local Currency = Grinder:GetModule("Plugin"):NewModule("Currency", "AceConsole-3.0", "AceEvent-3.0")

local Display = Grinder:GetModule("Display")

local defaults = {
    global = {
        segments = {
            ["*"] = {
                money = 0
            }
        }
    }
}

function Currency:OnInitialize()
    self.Database = Grinder.Database:RegisterNamespace("Currency", defaults)

    self:RegisterMessage("OnSegmentStart", "OnSegmentStart")
    self:RegisterMessage("OnSegmentStop", "OnSegmentStop")
end

function Currency:OnSegmentStart()
    self:RegisterEvent("CHAT_MSG_MONEY", "OnMoneyReceive")
end

function Currency:OnSegmentStop()
    self:UnregisterEvent("CHAT_MSG_MONEY")
end

function Currency:OnMoneyReceive(_, msg)
    local gold = string.match(msg, "(%d+) Gold")
    local silver = string.match(msg, "(%d+) Silver")
    local copper = string.match(msg, "(%d+) Copper")

    if gold == nil then gold = 0 end
    if silver == nil then silver = 0 end
    if copper == nil then copper = 0 end

    local result = self.Database.global.segments[Grinder.CurrentSegment].money + gold * 10000 + silver * 100 + copper

    self.Database.global.segments[Grinder.CurrentSegment].money = result

    local g = math.floor(result / 10000);
    local s = math.floor((result - g * 10000) / 100);
    local c = math.floor(result - (g * 10000) - (s * 100));
    result = g .. "g" .. s .. "s" .. c .. "c"

    if Display:ItemExists("Currency", "money") then
        Display:UpdateItem("Currency", "money", result)
    else
        Display:SetItem("Currency", "money", 133784, "Gold", result)
    end
end
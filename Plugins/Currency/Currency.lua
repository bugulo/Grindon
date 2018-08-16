local Grindon = LibStub("AceAddon-3.0"):GetAddon("Grindon")
local Plugin = Grindon:GetModule("Plugin")
local Currency = Plugin:NewModule("Currency", "AceConsole-3.0", "AceEvent-3.0")

local Widget = Grindon:GetModule("Widget")

local defaults = {
    global = {
        segments = {
            ["*"] = {
                ["*"] = {
                    count = 0
                },
                money = 0
            }
        }
    }
}

function Currency:OnInitialize()
    self.Database = Grindon.Database:RegisterNamespace("Currency", defaults)
    --Plugin:RegisterConfig("Currency", options, 1, true)
end

function Currency:OnEnable()
    self:RegisterMessage("OnSegmentStart", "OnSegmentStart")
    self:RegisterMessage("OnSegmentStop", "OnSegmentStop")
end

function Currency:OnDisable()
    self:UnregisterMessage("OnSegmentStart")
    self:UnregisterMessage("OnSegmentStop")
end

function Currency:OnSegmentStart()
    self:RegisterEvent("CHAT_MSG_MONEY", "OnMoneyReceive")
    self:RegisterEvent("CHAT_MSG_CURRENCY", "OnCurrencyReceive")
end

function Currency:OnSegmentStop()
    self:UnregisterEvent("CHAT_MSG_MONEY")
    self:UnregisterEvent("CHAT_MSG_CURRENCY")
end

function Currency:OnMoneyReceive(_, msg)
    local gold = string.match(msg, "(%d+) Gold")
    local silver = string.match(msg, "(%d+) Silver")
    local copper = string.match(msg, "(%d+) Copper")

    if gold == nil then gold = 0 end
    if silver == nil then silver = 0 end
    if copper == nil then copper = 0 end

    local result = self.Database.global.segments[Grindon.CurrentSegment].money + gold * 10000 + silver * 100 + copper

    self.Database.global.segments[Grindon.CurrentSegment].money = result

    local g = math.floor(result / 10000);
    local s = math.floor((result - g * 10000) / 100);
    local c = math.floor(result - (g * 10000) - (s * 100));
    result = g .. "g" .. s .. "s" .. c .. "c"

    Widget:SetItem("Currency", "money", 133784, "Gold", result, false)
end

function Currency:OnCurrencyReceive(_, msg)
    local id = tonumber(string.match(msg, "Hcurrency:(%d+):"))
    local name = string.match(msg, "%[(.+)%]")
    local count = string.match(msg, "x(%d+)")
    if count == nil then count = 1 end

    self.Database.global.segments[Grindon.CurrentSegment][id].count = self.Database.global.segments[Grindon.CurrentSegment][id].count + count

    local _, _, texture = GetCurrencyInfo(id)

    Widget:SetItem("Currency", id, texture, name, self.Database.global.segments[Grindon.CurrentSegment][id].count)
end
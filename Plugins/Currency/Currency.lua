local Grindon = LibStub("AceAddon-3.0"):GetAddon("Grindon")
local Plugin = Grindon:GetModule("Plugin")
local Currency = Plugin:NewModule("Currency", "AceConsole-3.0", "AceEvent-3.0")

local Widget = Grindon:GetModule("Widget")

local database

local defaults = {
    global = {
        segments = {
            ["*"] = {
                money = 0,
                other = {
                    ["*"] = {
                        count = 0
                    }
                }
            }
        }
    }
}

function Currency:OnInitialize()
    database = Grindon:RegisterNamespace("Currency", defaults)
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

    local segment = database.global.segments[Grindon:GetSegmentID()]

    local result = segment.money + gold * 10000 + silver * 100 + copper

    segment.money = result

    Widget:SetItem("Currency", "money", 133784, "Gold", self:FormatCopper(result), "FED000", false)
end

function Currency:OnCurrencyReceive(_, msg)
    local id = tonumber(string.match(msg, "Hcurrency:(%d+):"))
    local name = string.match(msg, "%[(.+)%]")
    local count = string.match(msg, "x(%d+)")
    local color = string.match(msg, "|?c?f?f?(%x*)|")

    if count == nil then count = 1 end

    local item = database.global.segments[Grindon:GetSegmentID()].other[id]

    item.count = item.count + count

    local _, _, texture = GetCurrencyInfo(id)

    Widget:SetItem("Currency", id, texture, name, item.count, color)
end

function Currency:FormatCopper(amount)
    local g = math.floor(amount / 10000)
    local s = math.floor((amount - g * 10000) / 100)
    local c = math.floor(amount - (g * 10000) - (s * 100))
    return g .. "g" .. s .. "s" .. c .. "c"
end

function Currency:RequestHistory(id)
    local response = {}
    local segment = database.global.segments[id]
    if(segment.money > 0) then
        table.insert(response, {Text = "Gold", Icon = 133784, Amount = self:FormatCopper(segment.money)})
    end
    for currencyId, currency in pairs(database.global.segments[id].other) do
        local name, _, texture = GetCurrencyInfo(currencyId)
        table.insert(response, {Text = name, Icon = texture, Amount = currency.count})
    end
    return response
end
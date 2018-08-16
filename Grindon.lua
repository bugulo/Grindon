local Grindon = LibStub("AceAddon-3.0"):NewAddon("Grindon", "AceConsole-3.0", "AceEvent-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale("Grindon").General

local defaults = {
    global = {
        segments = {
            ["*"] = {
                character = nil,
                timeStart = nil,
                items = {
                    ["*"] = {
                        count = 0
                    }
                }
            }
        }
    }
}

function Grindon:OnInitialize()
    self.Database = LibStub("AceDB-3.0"):New("GrindonDB", defaults, true)
    self.Database.RegisterCallback(self, "OnProfileChanged", "ProfileChanged")
    self.Database.RegisterCallback(self, "OnProfileCopied", "ProfileChanged")
    self.Database.RegisterCallback(self, "OnProfileReset", "ProfileChanged")

    self.Reserved = {}

    self:RegisterChatCommand("startgrind", "StartSegment")
    self:RegisterChatCommand("stopgrind", "StopSegment")
end

function Grindon:ProfileChanged()
    if self.CurrentSegment then
        self:StopSegment()
        self:Print(L["ProfileChanged"])
    end
    self:SendMessage("OnProfileChanged")
end

function Grindon:ReserveIDs(table, state)
    for _, v in pairs(table) do
        if type(v) == "table" then
            self:ReserveIDs(v, state)
        else
            self.Reserved[v] = state
        end
    end
end

function Grindon:StartSegment()
    if self.CurrentSegment then
        self:Print(L["SegmentAlreadyStarted"])
        return
    end

    self.CurrentSegment = self:RandomID()
    self.Database.global.segments[self.CurrentSegment].character = UnitName("player")
    self.Database.global.segments[self.CurrentSegment].timeStart = time(date("!*t"))

    self:SendMessage("OnSegmentStart")
    self:Print(L["SegmentStarted"])
end

function Grindon:StopSegment()
    if not self.CurrentSegment then
        self:Print(L["SegmentNotStarted"])
        return
    end

    self.Database.global.segments[self.CurrentSegment].timeEnd = time(date("!*t"))
    self.CurrentSegment = nil

    self:SendMessage("OnSegmentStop")
    self:Print(L["SegmentStopped"])
end

function Grindon:GetItemAmount(id)
    return self.Database.global.segments[self.CurrentSegment].items[id].count
end

-- HELPER FUNCTIONS

function Grindon:RandomID()
    local random = math.random
    return string.gsub("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx", "[xy]", function (c)
        local v = (c == "x") and random(0, 0xf) or random(8, 0xb)
        return string.format("%x", v)
    end)
end

function Grindon:InArray(array, val)
    for _, value in ipairs(array) do
        if value == val then
            return true
        end
    end
    return false
end

function Grindon:Split(string, delimeter)
    local sep, fields = delimeter or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    string:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end
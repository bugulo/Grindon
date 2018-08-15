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

    self.Reserved = {}

    self:RegisterChatCommand("startgrind", "StartSegment")
    self:RegisterChatCommand("stopgrind", "StopSegment")
end

function Grindon:ReserveIDs(idtable)
    for _, v in pairs(idtable) do
        if type(v) == "table" then
            self:ReserveIDs(v)
        else
            self.Reserved[v] = true
        end
    end
end

function Grindon:UnreserveIDs(idtable)
    for _, v in pairs(idtable) do
        if type(v) == "table" then
            self:UnreserveIDs(v)
        else
            self.Reserved[v] = false
        end
    end
end

function Grindon:IsReserved(id)
   return self.Reserved[id] == true
end

function Grindon:StartSegment()
    if self.CurrentSegment then
        self:Print(L["SegmentAlreadyStarted"])
        return
    end

    self.CurrentSegment = self:RandomID()
    self.Database.global.segments[self.CurrentSegment].character = UnitName("player")
    self.Database.global.segments[self.CurrentSegment].timeStart = time(date("!*t"))

    self:SendMessage("OnSegmentStart", self.CurrentSegment)
    self:Print(L["SegmentStarted"])
end

function Grindon:StopSegment()
    if self.CurrentSegment == nil then
        self:Print(L["SegmentNotStarted"])
        return
    end

    local id = self.CurrentSegment

    self.Database.global.segments[self.CurrentSegment].timeEnd = time(date("!*t"))
    self.CurrentSegment = nil

    self:SendMessage("OnSegmentStop", id)
    self:Print(L["SegmentStopped"])
end

function Grindon:GetSegment()
    return self.Database.global.segments[self.CurrentSegment]
end

function Grindon:GetItemAmount(itemId)
    return self.Database.global.segments[self.CurrentSegment].items[itemId].count
end

function Grindon:InArray(array, val)
    for _, value in ipairs(array) do
        if value == val then
            return true
        end
    end
    return false
end

function Grindon:KeyInArray(array, val)
    for index, _ in pairs(array) do
        if index == val then
            return true
        end
    end
    return false
end

function Grindon:RandomID()
    local random = math.random
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

function Grindon:ArraySize(array)
    local count = 0
    for _ in pairs(array) do count = count + 1 end
    return count
end

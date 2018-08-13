local AceAddon = LibStub("AceAddon-3.0")
local AceDB = LibStub("AceDB-3.0")

local Grinder = AceAddon:NewAddon("Grinder", "AceConsole-3.0", "AceEvent-3.0")

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

function Grinder:OnInitialize()
    self.Database = AceDB:New("GrinderDB", defaults, true)

    self.Reserved = {}

    self:RegisterChatCommand("grindstart", "StartSegment")
    self:RegisterChatCommand("grindstop", "StopSegment")
end

function Grinder:ReserveIDs(idtable)
    for _, v in pairs(idtable) do
        self.Reserved[v] = true
    end
end

function Grinder:UnreserveIDs(idtable)
    for _, v in pairs(idtable) do
        self.Reserved[v] = false
    end
end

function Grinder:IsReserved(id)
   return self.Reserved[id] == true
end

function Grinder:StartSegment()
    if self.CurrentSegment then
        self:Print("Segment already started")
        return
    end

    self.CurrentSegment = self:RandomID()
    self.Database.global.segments[self.CurrentSegment].character = UnitName("player")
    self.Database.global.segments[self.CurrentSegment].timeStart = time(date("!*t"))

    self:SendMessage("OnSegmentStart", self.CurrentSegment)
    self:Print("Segment started")
end

function Grinder:StopSegment()
    if self.CurrentSegment == nil then
        self:Print("Segment not started")
        return
    end

    local id = self.CurrentSegment

    self.Database.global.segments[self.CurrentSegment].timeEnd = time(date("!*t"))
    self.CurrentSegment = nil

    self:SendMessage("OnSegmentStop", id)
    self:Print("Segment stopped")
end

function Grinder:GetSegment()
    return self.Database.global.segments[self.CurrentSegment]
end

function Grinder:GetItemAmount(itemId)
    return self.Database.global.segments[self.CurrentSegment].items[itemId].count
end

function Grinder:InArray(array, val)
    for _, value in ipairs(array) do
        if value == val then
            return true
        end
    end
    return false
end

function Grinder:KeyInArray(array, val)
    for index, _ in pairs(array) do
        if index == val then
            return true
        end
    end
    return false
end

function Grinder:RandomID()
    local random = math.random
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

function Grinder:ArraySize(array)
    local count = 0
    for _ in pairs(array) do count = count + 1 end
    return count
end

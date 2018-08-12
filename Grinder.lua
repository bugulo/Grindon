local AceAddon = LibStub("AceAddon-3.0")
local AceDB = LibStub("AceDB-3.0")

local Grinder = AceAddon:NewAddon("Grinder", "AceTimer-3.0", "AceConsole-3.0", "AceEvent-3.0")

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
    self.Timer = self:ScheduleRepeatingTimer("CheckQueue", 1)

    self.Reserved = {}
    self.Queue = {}

    self:RegisterChatCommand("start", "StartSegment")
    self:RegisterChatCommand("stop", "StopSegment")
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

    self:RegisterEvent("CHAT_MSG_LOOT", "OnLootReceive")
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

    self:UnregisterEvent("CHAT_MSG_LOOT")
    self:SendMessage("OnSegmentStop", id)
    self:Print("Segment stopped")
end

function Grinder:OnLootReceive(_, msg)
    msg = string.gsub(msg, "|", "/")
    local name = string.match(msg, "%[(.+)%]")
    local count = string.match(msg, "x(%d+)")
    if count == nil then count = 1 end

    self:GetItemID(name, function(id)
        self.Database.global.segments[self.CurrentSegment].items[id].count = self.Database.global.segments[self.CurrentSegment].items[id].count + count

        self:SendMessage("OnLootReceive", id, count, name)
    end)
end

function Grinder:GetSegment()
    return self.Database.global.segments[self.CurrentSegment]
end

function Grinder:GetItemAmount(itemId)
    return self.Database.global.segments[self.CurrentSegment].items[itemId].count
end


-- UTILS

function Grinder:CheckQueue()
    for key, value in pairs(self.Queue) do
        local _, itemLink = GetItemInfo(value.identifier)

        if itemLink ~= nil then
            value.callback(self:GetIDFromLink(itemLink))
            self.Queue[key] = nil
        else
            local id = GetItemInfoInstant(value.identifier)
            if id ~= nil then
                value.callback(id)
            end
        end
    end
end

function Grinder:GetItemID(identifier, callback)
    local _, itemLink = GetItemInfo(identifier)
    if itemLink ~= nil then
        callback(self:GetIDFromLink(itemLink))
    else
        local id = GetItemInfoInstant(identifier)
        if id ~= nil then
            callback(id)
        else
            table.insert(self.Queue, {identifier = identifier, callback = callback})
        end
    end
end

function Grinder:GetIDFromLink(link)
    local match = string.match(link, "%:(%d+)%:")
    return tonumber(match)
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

local Grindon = LibStub("AceAddon-3.0"):NewAddon("Grindon", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale("Grindon").General

local hash = "2A8ios1r8c"

local database, reserved, segment, timer

local defaults = {
    global = {
        lastSegment = 1,
        segments = {
            ["*"] = {
                hash = nil,
                character = nil,
                timeStart = nil,
                timeEnd = nil,
                items = {
                    ["*"] = {
                        name = nil,
                        count = 0
                    }
                }
            }
        }
    }
}

function Grindon:OnInitialize()
    reserved = {}

    database = LibStub("AceDB-3.0"):New("GrindonDB", defaults, true)
    database.RegisterCallback(self, "OnProfileChanged", "ProfileChanged")
    database.RegisterCallback(self, "OnProfileCopied", "ProfileChanged")
    database.RegisterCallback(self, "OnProfileReset", "ProfileChanged")

    self:RegisterChatCommand("startgrind", "StartSegment")
    self:RegisterChatCommand("stopgrind", "StopSegment")

    for id, segment in pairs(database.global.segments) do
        if segment.hash ~= hash then
            database.global.segments[id] = nil
        end
    end
end

function Grindon:ProfileChanged()
    if segment then
        self:StopSegment()
        self:Print(L["ProfileChanged"])
    end
    self:SendMessage("OnProfileChanged")
end

function Grindon:StartSegment()
    if segment then
        self:Print(L["SegmentAlreadyStarted"])
        return
    end

    segment = database.global.lastSegment
    database.global.lastSegment = database.global.lastSegment + 1
    database.global.segments[segment].hash = hash
    database.global.segments[segment].character = UnitName("player")
    database.global.segments[segment].timeStart = time(date("!*t"))
    database.global.segments[segment].timeEnd = time(date("!*t"))

    timer = self:ScheduleRepeatingTimer("SegmentTimer", 1)

    self:SendMessage("OnSegmentStart")
    self:Print(L["SegmentStarted"])
end

function Grindon:SegmentTimer()
    database.global.segments[segment].timeEnd = database.global.segments[segment].timeEnd + 1
end

function Grindon:StopSegment()
    if not segment then
        self:Print(L["SegmentNotStarted"])
        return
    end

    database.global.segments[segment].timeEnd = time(date("!*t"))
    self:CancelTimer(timer)
    segment = nil

    self:SendMessage("OnSegmentStop")
    self:Print(L["SegmentStopped"])
end

-- API

function Grindon:GetOptionsTable()
    return LibStub("AceDBOptions-3.0"):GetOptionsTable(database)
end

function Grindon:Reserve(table, state)
    for _, v in pairs(table) do
        if type(v) == "table" then
            self:Reserve(v, state)
        else
            reserved[v] = state
        end
    end
end

function Grindon:IsReserved(id)
    return reserved[id] == true
end

function Grindon:GetItemInfo(id, seg)
    if not seg then seg = segment end
    return database.global.segments[seg].items[id]
end

function Grindon:GetSegmentInfo(seg)
    if not seg then seg = segment end
    local target = database.global.segments[seg]

    return {
        character = target.character,
        timeStart = target.timeStart,
        timeEnd = target.timeEnd
    }
end

function Grindon:GetSegmentID()
    return segment
end

function Grindon:IsStarted()
    return segment ~= nil
end

function Grindon:DeleteSegment(seg)
    database.global.segments[seg] = nil
end

function Grindon:IterateItems(seg) --todo exclude items with count 0
    if not seg then seg = segment end
    return pairs(database.global.segments[seg].items)
end

function Grindon:IterateSegments()
    return self:PairsByKey(database.global.segments)
end

function Grindon:RegisterNamespace(name, defaults)
    return database:RegisterNamespace(name, defaults)
end

-- HELPER LUA FUNCTIONS

function Grindon:InTable(table, val)
    for _, value in ipairs(table) do
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

function Grindon:PairsByKey(t)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a)
    local i = 0
    local iterator = function ()
        i = i + 1
        if a[i] == nil then
            return nil
        else
            return a[i], t[a[i]]
        end
    end
    return iterator
end
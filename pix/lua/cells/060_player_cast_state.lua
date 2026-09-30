-- 60: 施法状态；61: 剩余秒数；62: 技能类别；63: 本次读条目标。
local _, addonTable = ...
local cells = {}
local pending = {}
local activeGUID, activeTarget, activeKind = nil, 0, 0
local units = { "player", "party1", "party2", "party3", "party4" }
local frame = CreateFrame("Frame")

local function Kind(spellID)
    if issecretvalue(spellID) or spellID == nil then return 0 end
    if spellID == 82326 then return 1 end
    if spellID == 19750 then return 2 end
    return 3
end

local function FindTarget(targetName)
    if issecretvalue(targetName) or targetName == nil or targetName == "" then return 0 end
    local found = 0
    for index, unit in ipairs(units) do
        if UnitExists(unit) then
            local name, realm = UnitFullName(unit)
            if not issecretvalue(name) and not issecretvalue(realm) and name then
                local fullName = realm and realm ~= "" and (name .. "-" .. realm) or name
                if targetName == name or targetName == fullName then
                    if found ~= 0 then return 0 end
                    found = index
                end
            end
        end
    end
    return found
end

local function Gray(cell, value)
    local gray = value / 255
    cell:setCellRGBA(gray, gray, gray)
end

local function Refresh()
    if not cells[60] then return end
    local _, _, _, _, _, _, _, _, spellID, _, delay = UnitCastingInfo("player")
    local empowered = select(9, UnitChannelInfo("player"))
    local state, remaining = 0, addonTable.COLOR.WHITE
    if delay ~= nil then
        state = 1
        local duration = UnitCastingDuration("player")
        if issecretvalue(duration) or duration ~= nil then
            remaining = duration:EvaluateRemainingDuration(addonTable.CURVE.SpellColddownRemaining)
        end
        if activeKind == 0 then activeKind = Kind(spellID) end
    elseif empowered ~= nil then
        state = 2
        activeGUID, activeTarget, activeKind = nil, 0, 0
    else
        activeGUID, activeTarget, activeKind = nil, 0, 0
    end
    Gray(cells[60], state)
    cells[61]:setCell(remaining)
    Gray(cells[62], activeKind)
    Gray(cells[63], activeTarget)
end

local rosterEvents = {
    PLAYER_ENTERING_WORLD = true, GROUP_ROSTER_UPDATE = true,
    GROUP_JOINED = true, GROUP_LEFT = true, GROUP_FORMED = true,
}
for event in pairs(rosterEvents) do frame:RegisterEvent(event) end
for _, event in ipairs({
    "UNIT_SPELLCAST_SENT", "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_STOP",
    "UNIT_SPELLCAST_SUCCEEDED", "UNIT_SPELLCAST_FAILED", "UNIT_SPELLCAST_FAILED_QUIET",
    "UNIT_SPELLCAST_INTERRUPTED", "UNIT_SPELLCAST_DELAYED",
    "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_STOP",
    "UNIT_SPELLCAST_EMPOWER_START", "UNIT_SPELLCAST_EMPOWER_STOP",
}) do frame:RegisterUnitEvent(event, "player") end

frame:SetScript("OnEvent", function(_, event, _, arg1, arg2, arg3)
    if rosterEvents[event] then
        pending = {}
        activeGUID, activeTarget, activeKind = nil, 0, 0
    elseif event == "UNIT_SPELLCAST_SENT" then
        local targetName, castGUID, spellID = arg1, arg2, arg3
        if not issecretvalue(castGUID) and castGUID then
            pending[castGUID] = { target = FindTarget(targetName), kind = Kind(spellID) }
        end
    elseif event == "UNIT_SPELLCAST_START" then
        local castGUID, spellID = arg1, arg2
        activeGUID, activeTarget, activeKind = nil, 0, Kind(spellID)
        if not issecretvalue(castGUID) and castGUID then
            local request = pending[castGUID]
            activeGUID = castGUID
            if request then activeTarget = request.target end
            pending[castGUID] = nil
        end
    elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_SUCCEEDED"
        or event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_FAILED_QUIET"
        or event == "UNIT_SPELLCAST_INTERRUPTED" then
        local castGUID = arg1
        if not issecretvalue(castGUID) and castGUID then
            pending[castGUID] = nil
            if castGUID == activeGUID then activeGUID, activeTarget, activeKind = nil, 0, 0 end
        end
    end
    C_Timer.After(0, Refresh)
end)
local elapsed = 0
frame:SetScript("OnUpdate", function(_, delta)
    elapsed = elapsed + delta
    if elapsed >= 0.05 then elapsed = elapsed % 0.05; Refresh() end
end)
table.insert(addonTable.UIInitFuncs, function()
    for x = 60, 63 do cells[x] = addonTable.Cell:New({ x = x }) end
    Refresh()
end)

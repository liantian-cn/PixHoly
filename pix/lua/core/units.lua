-- 小队属性按单位顺序集中创建；每项属性拥有连续的四个队友槽。
local _, addonTable = ...
local Units = {}
addonTable.UnitCells = Units
Units.Party = { "party1", "party2", "party3", "party4" }

local callbacks = {}
local rosterEvents = {
    PLAYER_ENTERING_WORLD = true, GROUP_ROSTER_UPDATE = true,
    GROUP_JOINED = true, GROUP_LEFT = true, GROUP_FORMED = true,
}
local eventFrame = CreateFrame("Frame")
local registered = {}
local function Register(event)
    if not registered[event] then
        eventFrame:RegisterEvent(event)
        registered[event] = true
    end
end
for event in pairs(rosterEvents) do Register(event) end

-- 将同帧队伍事件合并；重绑光环不能只调用相同 token 的 SetUnit。
local pending = false
eventFrame:SetScript("OnEvent", function(_, event)
    if rosterEvents[event] then
        if pending then return end
        pending = true
        C_Timer.After(0, function()
            pending = false
            for _, entry in ipairs(callbacks) do entry.refresh(true) end
        end)
    else
        for _, entry in ipairs(callbacks) do
            if entry.events[event] then entry.refresh(false) end
        end
    end
end)
eventFrame:SetScript("OnUpdate", function(_, elapsed)
    for _, entry in ipairs(callbacks) do
        if entry.interval then
            entry.elapsed = entry.elapsed + elapsed
            if entry.elapsed >= entry.interval then
                entry.elapsed = entry.elapsed % entry.interval
                entry.refresh(false)
            end
        end
    end
end)

local function Watch(refresh, events, interval)
    local wanted = {}
    for _, event in ipairs(events or {}) do
        wanted[event] = true
        Register(event)
    end
    callbacks[#callbacks + 1] = {
        refresh = refresh, events = wanted, interval = interval, elapsed = 0,
    }
    refresh(true)
end

local function Cells(x, units, read, events, interval)
    table.insert(addonTable.UIInitFuncs, function()
        local cells = {}
        for index in ipairs(units) do
            cells[index] = addonTable.Cell:New({ x = x + index - 1 })
        end
        Watch(function()
            for index, unit in ipairs(units) do
                local color = addonTable.COLOR.BLACK
                if UnitExists(unit) then color = read(unit) end
                cells[index]:setCell(color)
            end
        end, events, interval)
    end)
end

function Units.Boolean(x, units, read, events, interval)
    Cells(x, units, function(unit)
        local value = read(unit)
        if not issecretvalue(value) and value == nil then value = false end
        return C_CurveUtil.EvaluateColorFromBoolean(value, addonTable.COLOR.WHITE, addonTable.COLOR.BLACK)
    end, events, interval or 2)
end

function Units.Number(x, units, read, events)
    Cells(x, units, function(unit)
        local value = read(unit)
        if issecretvalue(value) or value == nil then value = 0 end
        local gray = value / 255
        return CreateColor(gray, gray, gray, 1)
    end, events, 2)
end

function Units.Health(x, units)
    Cells(x, units, function(unit)
        return UnitHealthPercent(unit, true, addonTable.CURVE.percent)
    end, { "UNIT_HEALTH", "UNIT_MAXHEALTH", "UNIT_HEAL_PREDICTION",
        "UNIT_ABSORB_AMOUNT_CHANGED", "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" }, 2)
end

function Units.Alive(x, units)
    Cells(x, units, function(unit)
        return C_CurveUtil.EvaluateColorFromBoolean(UnitIsDeadOrGhost(unit), addonTable.COLOR.BLACK, addonTable.COLOR.WHITE)
    end, { "UNIT_FLAGS", "PARTY_MEMBER_ENABLE", "PARTY_MEMBER_DISABLE" }, 2)
end

function Units.Role(unit)
    local role = UnitGroupRolesAssigned(unit)
    if issecretvalue(role) then return 5 end
    return ({ TANK = 1, HEALER = 2, DAMAGER = 3 })[role] or 5
end

function Units.Class(unit)
    local _, _, classID = UnitClass(unit)
    return classID
end

function Units.Range(x, units)
    Units.Boolean(x, units, function(unit)
        return C_Spell.IsSpellInRange(82326, unit)
    end, { "SPELLS_CHANGED", "PLAYER_TARGET_CHANGED" }, 0.1)
end

function Units.AbsorbPresence(x, units, healing)
    table.insert(addonTable.UIInitFuncs, function()
        local bars = {}
        for index in ipairs(units) do
            local backing = addonTable.CellBackplate:New({ x = x + index - 1 })
            local bar = CreateFrame("StatusBar", nil, backing.Frame)
            bar:SetAllPoints(backing.Frame)
            bar:SetFrameLevel(addonTable.FrameLevel.Content)
            bar:SetColorFill(1, 1, 1, 1)
            bar:SetMinMaxValues(0, 1)
            bars[index] = bar
        end
        Watch(function()
            for index, unit in ipairs(units) do
                if not UnitExists(unit) then
                    bars[index]:SetValue(0)
                elseif healing then
                    bars[index]:SetValue(UnitGetTotalHealAbsorbs(unit))
                else
                    bars[index]:SetValue(UnitGetTotalAbsorbs(unit))
                end
            end
        end, { "UNIT_ABSORB_AMOUNT_CHANGED", "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" }, 2)
    end)
end

function Units.Aura(x, units, filter, candidateFilters)
    table.insert(addonTable.UIInitFuncs, function()
        if not C_AddOns.IsAddOnLoaded("Blizzard_AuraContainer") then
            C_AddOns.LoadAddOn("Blizzard_AuraContainer")
        end
        local containers = {}
        for index, unit in ipairs(units) do
            local backing = addonTable.Cell:New({ x = x + index - 1 })
            local container = CreateFrame("AuraContainer", nil, backing.Frame, "CustomAuraContainerTemplate")
            container:SetAllPoints(backing.Frame)
            container:SetFrameLevel(addonTable.FrameLevel.AuraContainer)
            container:SetUnit(unit)
            container:AddAuraSlot("aura", filter, {
                candidateFilters = candidateFilters,
                initializeFrame = function(frame)
                    frame:SetSize(addonTable.SIZE.CELL, addonTable.SIZE.CELL)
                    frame:SetPoint("TOPLEFT", container, "TOPLEFT")
                    frame:SetFrameLevel(addonTable.FrameLevel.AuraButton)
                    local texture = frame:CreateTexture(nil, "OVERLAY")
                    texture:SetAllPoints(frame)
                    texture:SetColorTexture(1, 1, 1, 1)
                end,
            })
            containers[index] = container
        end
        Watch(function()
            for index, unit in ipairs(units) do
                local container = containers[index]
                if UnitExists(unit) then
                    container:Show()
                    container:SetUnit(unit)
                    container:SetAuraSlotCandidateFilters("aura", candidateFilters)
                    container:UpdateAllAuras()
                else
                    container:Hide()
                end
            end
        end, { "PLAYER_TARGET_CHANGED" })
    end)
end

-- 每条内容宽 5 Cell，连分隔占 6 Cell；秘密吸收量只交原生 StatusBar。
function Units.HealAbsorb(x, units)
    table.insert(addonTable.UIInitFuncs, function()
        local entries = {}
        for index in ipairs(units) do
            local backing = addonTable.ValueBarBackplate:New(x + (index - 1) * 6, 5)
            local bar = CreateFrame("StatusBar", nil, backing.Frame)
            bar:SetAllPoints(backing.Frame)
            bar:SetFrameLevel(addonTable.FrameLevel.Content)
            bar:SetColorFill(1, 1, 1, 1)
            entries[index] = { bar = bar, calculator = CreateUnitHealPredictionCalculator() }
        end
        Watch(function()
            for index, unit in ipairs(units) do
                local entry = entries[index]
                if UnitExists(unit) then
                    UnitGetDetailedHealPrediction(unit, nil, entry.calculator)
                    entry.bar:SetMinMaxValues(0, entry.calculator:GetMaximumHealth())
                    local amount = entry.calculator:GetHealAbsorbs()
                    entry.bar:SetValue(amount)
                else
                    entry.bar:SetMinMaxValues(0, 1)
                    entry.bar:SetValue(0)
                end
            end
        end, { "UNIT_HEALTH", "UNIT_MAXHEALTH", "UNIT_HEAL_PREDICTION",
            "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" }, 2)
    end)
end

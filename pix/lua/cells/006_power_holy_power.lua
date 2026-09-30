-- 圣能按普通整数编码：灰度字节值直接等于圣能数量。
local addonName, addonTable = ...
local insert = table.insert
local CreateFrame = CreateFrame
local After = C_Timer.After
local UnitPower = UnitPower
local issecretvalue = issecretvalue
local POWER_TYPE = Enum.PowerType.HolyPower
local Cell = addonTable.Cell
local UIInitFuncs = addonTable.UIInitFuncs
local X = 6
local cell
local eventFrame = CreateFrame("Frame")

local function Update()
    if not cell then return end
    local power = UnitPower("player", POWER_TYPE, false)
    if issecretvalue(power) then error("圣能返回秘密值") end
    if type(power) ~= "number" or power < 0 or power > 255 or power % 1 ~= 0 then
        error("圣能必须为 0..255 整数")
    end
    local value = power / 255
    cell:setCellRGBA(value, value, value)
end

local function Initialize()
    cell = Cell:New({ x = X })
    Update()
end

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
eventFrame:RegisterUnitEvent("UNIT_MAXPOWER", "player")
eventFrame:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
eventFrame:SetScript("OnEvent", function() After(0, Update) end)
insert(UIInitFuncs, Initialize)

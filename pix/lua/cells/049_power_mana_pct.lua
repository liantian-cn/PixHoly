-- 玩家法力百分比；原生曲线直接消费资源比例。
local addonName, addonTable = ...
local X = 49
local cell
local eventFrame = CreateFrame("Frame")
local function Refresh()
    if not cell then return end
    cell:setCell(UnitPowerPercent("player", Enum.PowerType.Mana, false, addonTable.CURVE.percent))
end
local function Initialize()
    cell = addonTable.Cell:New({ x = X })
    Refresh()
end
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
eventFrame:RegisterUnitEvent("UNIT_MAXPOWER", "player")
eventFrame:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
eventFrame:SetScript("OnEvent", function() C_Timer.After(0, Refresh) end)
table.insert(addonTable.UIInitFuncs, Initialize)

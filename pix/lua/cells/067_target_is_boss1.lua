-- 同一属性按单位顺序集中创建，空槽由存在性控制。
local _, addonTable = ...
local Units = addonTable.UnitCells
Units.Boolean(67, { "target" }, function(unit) return UnitIsUnit(unit, "boss1") end, { "PLAYER_TARGET_CHANGED", "INSTANCE_ENCOUNTER_ENGAGE_UNIT" }, 0.1)

-- 同一属性按单位顺序集中创建，空槽由存在性控制。
local _, addonTable = ...
local Units = addonTable.UnitCells
Units.Boolean(96, Units.Party, function(unit) return UnitCanAssist("player", unit) end, { "UNIT_FLAGS", "UNIT_TARGETABLE_CHANGED" })

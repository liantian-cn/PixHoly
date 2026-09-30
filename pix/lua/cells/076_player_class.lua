-- 同一属性按单位顺序集中创建，空槽由存在性控制。
local _, addonTable = ...
local Units = addonTable.UnitCells
Units.Number(76, { "player" }, Units.Class)

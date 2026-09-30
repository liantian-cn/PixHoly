-- 同一属性按单位顺序集中创建，空槽由存在性控制。
local _, addonTable = ...
local Units = addonTable.UnitCells
Units.Aura(81, { "player" }, "HELPFUL", { includeSpellIDs = { [53563] = true, [156910] = true, [1244893] = true } })

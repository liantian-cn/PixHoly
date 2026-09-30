-- 同一属性按单位顺序集中创建，空槽由存在性控制。
local _, addonTable = ...
local Units = addonTable.UnitCells
Units.Aura(78, { "player" }, "HARMFUL|RAID_PLAYER_DISPELLABLE", { includeDispelTypes = { Magic = true } })

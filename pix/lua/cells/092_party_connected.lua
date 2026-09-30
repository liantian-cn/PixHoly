-- 同一属性按单位顺序集中创建，空槽由存在性控制。
local _, addonTable = ...
local Units = addonTable.UnitCells
Units.Boolean(92, Units.Party, UnitIsConnected, { "UNIT_CONNECTION", "PARTY_MEMBER_ENABLE", "PARTY_MEMBER_DISABLE" })

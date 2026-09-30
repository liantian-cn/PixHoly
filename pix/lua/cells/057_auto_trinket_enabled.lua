-- 自动饰品开关：通过现有面板 combo 配置，默认开启。
local addonName, addonTable = ...

local insert = table.insert
local Cell = addonTable.Cell
local COLOR = addonTable.COLOR
local Config = addonTable.Config
local ConfigRows = addonTable.ConfigRows
local UIInitFuncs = addonTable.UIInitFuncs

local X = 57
local config = Config("auto_trinket_enabled")
local cell
config:set_default(true)

insert(ConfigRows, {
    type = "combo",
    name = "自动饰品",
    tooltip = "战斗中的爆发窗口内，完成驱散与自身急救判断后，依次使用上、下饰品。",
    bind_config = config,
    default_value = true,
    options = {
        { k = false, v = "关闭" },
        { k = true, v = "开启" },
    },
})

local function Refresh()
    if not cell then return end
    cell:setCell(config:get_value() == true and COLOR.WHITE or COLOR.BLACK)
end

local function Initialize()
    cell = Cell:New({ x = X })
    Refresh()
end

config:register_callback(Refresh)
insert(UIInitFuncs, Initialize)

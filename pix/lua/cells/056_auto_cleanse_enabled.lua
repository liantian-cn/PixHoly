-- 自动驱散开关：通过现有面板 combo 配置，默认开启。
local addonName, addonTable = ...

local insert = table.insert
local Cell = addonTable.Cell
local COLOR = addonTable.COLOR
local Config = addonTable.Config
local ConfigRows = addonTable.ConfigRows
local UIInitFuncs = addonTable.UIInitFuncs

local X = 56
local config = Config("auto_cleanse_enabled")
local cell
config:set_default(true)

insert(ConfigRows, {
    type = "combo",
    name = "自动驱散",
    tooltip = "自动清除小队和友方目标的魔法、疾病、中毒，按此顺序选择；无敌对目标时仍可驱散。",
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

-- 64: 首领编号；65–66: boss1/boss2 施法已过秒数，0.1秒一级。
local _, addonTable = ...
local ENCOUNTERS = {
    [0] = 0,     -- 未战斗
    -- 虚影尖塔
    [3176] = 1,  -- 元首阿福扎恩
    [3177] = 2,  -- 弗拉希乌斯
    [3179] = 3,  -- 陨落之王萨哈达尔
    [3178] = 4,  -- 威厄高尔和艾佐拉克
    [3180] = 5,  -- 光盲先锋军
    [3181] = 6,  -- 宇宙之冕
    [3306] = 7,  -- 奇美鲁斯，未梦之神
    [3182] = 8,  -- 贝洛朗，奥的子嗣
    [3183] = 9,  -- 至暗之夜降临
    [3454] = 10, -- 鲁阿夏尔
    [3459] = 11, -- 索姆贝兰
    [3431] = 12, -- 普雷达萨斯
    [3436] = 13, -- 克拉格平
    -- 孢陨幽境
    [3159] = 14, -- 腐沼
    -- 潮缚石窟
    [3379] = 15, -- 尼姆瑞莎·唤波者
    -- 烈毒之渊
    [3470] = 16, -- 盘魂者内克扎莉
    [3445] = 17, -- 陵寝哨兵
    [3497] = 18, -- 迷失的探险者
    [3455] = 19, -- 万毒邪祟者瓦什尼克
    [3420] = 20, -- 斯索拉克
    [3421] = 21, -- 双子毒牙
    [3429] = 22, -- 盘卷祭坛
    [3492] = 23, -- 乌拉特克

    -- 大米
    -- 节点希纳斯
    [3328] = 51, -- 核技工程长卡斯雷瑟
    [3332] = 52, -- 核心守卫奈萨拉
    [3333] = 53, -- 洛萨克森
    -- 迈萨拉洞窟
    [3212] = 54, -- 姆罗金和内克拉克斯
    [3213] = 55, -- 沃达扎
    [3214] = 56, -- 拉克图尔，聚魂之器
    -- 风行者之塔
    [3056] = 57, -- 烬晓
    [3057] = 58, -- 被遗弃的二人组
    [3058] = 59, -- 指挥官克罗鲁科
    [3059] = 60, -- 无眠之心
    -- 魔导师平台
    [3071] = 61, -- 奥能金刚库斯托斯
    [3072] = 62, -- 瑟拉奈尔·日鞭
    [3073] = 63, -- 吉美尔鲁斯
    [3074] = 64, -- 迪詹崔乌斯
    -- 执政团之座
    [2065] = 65, -- 晋升者祖拉尔
    [2066] = 66, -- 萨普瑞什
    [2067] = 67, -- 总督奈扎尔
    [2068] = 68, -- 鲁拉
    -- 艾杰斯亚学院
    [2562] = 69, -- 维克萨姆斯
    [2563] = 70, -- 茂林古树
    [2564] = 71, -- 克罗兹
    [2565] = 72, -- 多拉苟萨的回响
    -- 萨隆矿坑
    [1999] = 73, -- 熔炉之主加弗斯特
    [2001] = 74, -- 伊克和科瑞克
    [2000] = 75, -- 天灾领主泰兰努斯
    -- 通天峰
    [1698] = 76, -- 兰吉特
    [1699] = 77, -- 阿拉卡纳斯
    [1700] = 78, -- 鲁克兰
    [1701] = 79, -- 高阶贤者维里克斯
    -- 毒牙祭坛
    [3456] = 80, -- 拉维
    [3457] = 81, -- 扭缠盘蛇
    [3458] = 82, -- 祖尔加
    -- 纳洛拉克的洞穴
    [3207] = 83, -- 囤宝狂人
    [3208] = 84, -- 寒冬哨兵
    [3209] = 85, -- 纳洛拉克
    -- 密谋小径
    [3101] = 86, -- 凯斯媞亚·魔力之心
    [3102] = 87, -- 赞恩·刃悲
    [3103] = 88, -- 歼灭者萨祖克斯
    [3105] = 89, -- 利希尔·烬怒
    -- 夺目谷
    [3199] = 90, -- 光明众花
    [3200] = 91, -- 圣光猎手伊库兹
    [3201] = 92, -- 护光者鲁伊亚
    [3202] = 93, -- 兹欧凯特
    -- 诸王之眠
    [2139] = 94, -- 黄金风蛇
    [2140] = 95, -- 部族议会
    [2142] = 96, -- 殓尸者姆沁巴
    [2143] = 97, -- 达萨大王
    -- 红玉新生法池
    [2609] = 98, -- 梅莉杜莎·寒妆
    [2606] = 99, -- 柯姬雅·焰蹄
    [2623] = 100, -- 基拉卡与厄克哈特·风脉
    -- 虚空之痕竞技场
    [3285] = 101, -- 塔兹拉尔
    [3286] = 102, -- 阿特洛苏斯
    [3287] = 103, -- 煞戎努斯
    -- 塞塔里斯神庙
    [2124] = 104, -- 阿德里斯和阿斯匹克斯
    [2125] = 105, -- 米利克萨
    [2126] = 106, -- 加瓦兹特
    [2127] = 107, -- 塞塔里斯的化身
}
local cells = {}
local encounter = 0
local curve = C_CurveUtil.CreateColorCurve()
curve:SetType(Enum.LuaCurveType.Linear)
curve:AddPoint(0, CreateColor(0, 0, 0, 1))
curve:AddPoint(25.5, CreateColor(1, 1, 1, 1))
local function Refresh()
    if not cells[64] then return end
    local gray = encounter / 255
    cells[64]:setCellRGBA(gray, gray, gray)
    for index = 1, 2 do
        local unit = "boss" .. index
        local color = addonTable.COLOR.BLACK
        if UnitExists(unit) then
            local delay = select(11, UnitCastingInfo(unit))
            if delay ~= nil then
                local duration = UnitCastingDuration(unit)
                if issecretvalue(duration) or duration ~= nil then
                    color = duration:EvaluateElapsedDuration(curve)
                end
            end
        end
        cells[64 + index]:setCell(color)
    end
end
local frame = CreateFrame("Frame")
for _, event in ipairs({ "ENCOUNTER_START", "ENCOUNTER_END", "PLAYER_ENTERING_WORLD", "INSTANCE_ENCOUNTER_ENGAGE_UNIT" }) do
    frame:RegisterEvent(event)
end
frame:SetScript("OnEvent", function(_, event, encounterID)
    if event == "ENCOUNTER_START" then
        if not issecretvalue(encounterID) then encounter = ENCOUNTERS[encounterID] or 0 end
    elseif event == "ENCOUNTER_END" or event == "PLAYER_ENTERING_WORLD" then
        encounter = 0
    end
    Refresh()
end)
local elapsed = 0
frame:SetScript("OnUpdate", function(_, delta)
    elapsed = elapsed + delta
    if elapsed >= 0.1 then elapsed = elapsed % 0.1; Refresh() end
end)
table.insert(addonTable.UIInitFuncs, function()
    for x = 64, 66 do cells[x] = addonTable.Cell:New({ x = x }) end
    Refresh()
end)

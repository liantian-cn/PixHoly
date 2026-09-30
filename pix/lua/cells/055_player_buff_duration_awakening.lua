-- 玩家觉醒增益的剩余秒数，使用共享光环时间曲线。
-- 原生光环容器负责匹配与显隐，不读取秘密光环数据。
local addonName, addonTable    = ...

-- Lua 内置方法
local insert                  = table.insert
local ipairs                  = ipairs

-- WoW API
local CreateFrame             = CreateFrame
local After                   = C_Timer.After

-- 项目引用
local Cell                    = addonTable.Cell
local COLOR                   = addonTable.COLOR
local SIZE                    = addonTable.SIZE
local FrameLevel              = addonTable.FrameLevel
local UIInitFuncs             = addonTable.UIInitFuncs

-- 本地配置与状态
local X = 55
local AURA_IDS = { 414193 }
local eventFrame              = CreateFrame("Frame")
local container

local function Refresh()
    if not container then
        return
    end
    container:UpdateAllAuras()
end

local function Initialize()
    if not C_AddOns.IsAddOnLoaded("Blizzard_AuraContainer") then
        C_AddOns.LoadAddOn("Blizzard_AuraContainer")
    end
    if not C_AddOns.IsAddOnLoaded("Blizzard_AuraContainer") then
        error("未能加载 Blizzard_AuraContainer，无法绑定光环")
    end
    local cell = Cell:New({ x = X })
    container = CreateFrame("AuraContainer", nil, cell.Frame, "CustomAuraContainerTemplate")
    container:SetAllPoints(cell.Frame)
    container:SetFrameLevel(FrameLevel.AuraContainer)
    container:SetUnit("player")

    local includeSpellIDs = {}
    for _, spellID in ipairs(AURA_IDS) do
        includeSpellIDs[spellID] = true
    end
    container:AddAuraSlot("aura", "HELPFUL|PLAYER", {
        candidateFilters = { includeSpellIDs = includeSpellIDs },
        initializeFrame = function(frame)
            frame:SetSize(SIZE.CELL, SIZE.CELL)
            frame:SetPoint("TOPLEFT", container, "TOPLEFT")
            frame:SetFrameLevel(FrameLevel.AuraButton)
            frame:SetClipsChildren(true)
            local fontPath = GameFontNormal:GetFont()
            local text = frame:CreateFontString(nil, "ARTWORK")
            text:SetFont(fontPath, SIZE.CELL_FONT_SIZE, "")
            text:SetPoint("CENTER", frame, "CENTER")
            text:SetJustifyH("CENTER")
            text:SetJustifyV("MIDDLE")
            text:SetShadowOffset(0, 0)
            text:SetShadowColor(0, 0, 0, 0)
            text:SetTextColor(1, 1, 1, 1)
            -- 永久光环露出白底；到期文字为黑色，缺失光环露出外层黑底。
            local background = frame:CreateTexture(nil, "BACKGROUND")
            background:SetAllPoints(frame)
            background:SetColorTexture(1, 1, 1, 1)
            local durationBinding = C_DurationUtil.CreateDurationTextBinding()
            durationBinding:SetZeroDurationText("")
            durationBinding:SetExpiredText("█")
            frame:SetDurationText(text, {
                binding = durationBinding,
                textFormat = { formatString = "█", components = {} },
                textColor = {
                    curve = addonTable.CURVE.AuraRemaining,
                    property = Enum.DurationTextBindingProperty.RemainingDuration,
                },
            })
        end,
    })
    Refresh()
end

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", function()
    After(0, Refresh)
end)
insert(UIInitFuncs, Initialize)

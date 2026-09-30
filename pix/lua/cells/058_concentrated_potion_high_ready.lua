-- 库存、可使用状态和冷却与实际使用的物品一致。
local _, addonTable = ...
local X, ITEM_ID = 58, 271884
local cell
local frame = CreateFrame("Frame")
local function Refresh()
    if not cell then return end
    local color = addonTable.COLOR.BLACK
    if C_Item.GetItemCount(ITEM_ID) > 0 then
        local _, duration, enabled = C_Item.GetItemCooldown(ITEM_ID)
        local usable, noMana = C_Item.IsUsableItem(ITEM_ID)
        local available = C_CurveUtil.EvaluateColorFromBoolean(noMana, addonTable.COLOR.BLACK, addonTable.COLOR.WHITE)
        available = C_CurveUtil.EvaluateColorFromBoolean(usable, available, addonTable.COLOR.BLACK)
        available = C_CurveUtil.EvaluateColorFromBoolean(duration == 0, available, addonTable.COLOR.BLACK)
        color = C_CurveUtil.EvaluateColorFromBoolean(enabled, available, addonTable.COLOR.BLACK)
    end
    cell:setCell(color)
end
for _, event in ipairs({ "PLAYER_ENTERING_WORLD", "BAG_UPDATE_DELAYED", "BAG_UPDATE_COOLDOWN", "SPELL_UPDATE_COOLDOWN" }) do
    frame:RegisterEvent(event)
end
frame:SetScript("OnEvent", function() C_Timer.After(0, Refresh) end)
local elapsed = 0
frame:SetScript("OnUpdate", function(_, delta)
    elapsed = elapsed + delta
    if elapsed >= 1 then elapsed = elapsed % 1; Refresh() end
end)
table.insert(addonTable.UIInitFuncs, function()
    cell = addonTable.Cell:New({ x = X })
    Refresh()
end)

local addonName, addonTable = ...
if addonTable.RELOAD_REQUIRED then return end
local macroList = {
    { title = "reloadUI", key = "CTRL-F12", text = "/reload" },
    { title = "荣耀圣令_player", key = "RCTRL-NUMPAD1", text = "/cast [known:156322,@player,help,nodead] 永恒之火; [@player,help,nodead] 荣耀圣令" },
    { title = "荣耀圣令_party1", key = "RCTRL-NUMPAD2", text = "/cast [known:156322,@party1,help,nodead] 永恒之火; [@party1,help,nodead] 荣耀圣令" },
    { title = "荣耀圣令_party2", key = "RCTRL-NUMPAD3", text = "/cast [known:156322,@party2,help,nodead] 永恒之火; [@party2,help,nodead] 荣耀圣令" },
    { title = "荣耀圣令_party3", key = "RCTRL-NUMPAD4", text = "/cast [known:156322,@party3,help,nodead] 永恒之火; [@party3,help,nodead] 荣耀圣令" },
    { title = "荣耀圣令_party4", key = "RCTRL-NUMPAD5", text = "/cast [known:156322,@party4,help,nodead] 永恒之火; [@party4,help,nodead] 荣耀圣令" },
    { title = "圣光术_player", key = "RCTRL-NUMPAD6", text = "/cast [@player,help,nodead] 圣光术" },
    { title = "圣光术_party1", key = "RCTRL-NUMPAD7", text = "/cast [@party1,help,nodead] 圣光术" },
    { title = "圣光术_party2", key = "RCTRL-NUMPAD8", text = "/cast [@party2,help,nodead] 圣光术" },
    { title = "圣光术_party3", key = "RCTRL-NUMPAD9", text = "/cast [@party3,help,nodead] 圣光术" },
    { title = "圣光术_party4", key = "RCTRL-NUMPAD0", text = "/cast [@party4,help,nodead] 圣光术" },
    { title = "圣光闪现_player", key = "RSHIFT-NUMPAD1", text = "/cast [@player,help,nodead] 圣光闪现" },
    { title = "圣光闪现_party1", key = "RSHIFT-NUMPAD2", text = "/cast [@party1,help,nodead] 圣光闪现" },
    { title = "圣光闪现_party2", key = "RSHIFT-NUMPAD3", text = "/cast [@party2,help,nodead] 圣光闪现" },
    { title = "圣光闪现_party3", key = "RSHIFT-NUMPAD4", text = "/cast [@party3,help,nodead] 圣光闪现" },
    { title = "圣光闪现_party4", key = "RSHIFT-NUMPAD5", text = "/cast [@party4,help,nodead] 圣光闪现" },
    { title = "神圣震击_player", key = "RSHIFT-NUMPAD6", text = "/cast [@player,help,nodead] 神圣震击" },
    { title = "神圣震击_party1", key = "RSHIFT-NUMPAD7", text = "/cast [@party1,help,nodead] 神圣震击" },
    { title = "神圣震击_party2", key = "RSHIFT-NUMPAD8", text = "/cast [@party2,help,nodead] 神圣震击" },
    { title = "神圣震击_party3", key = "RSHIFT-NUMPAD9", text = "/cast [@party3,help,nodead] 神圣震击" },
    { title = "神圣震击_party4", key = "RSHIFT-NUMPAD0", text = "/cast [@party4,help,nodead] 神圣震击" },
    { title = "美德道标_player", key = "RCTRL-F1", text = "/cast [@player,help,nodead] 美德道标" },
    { title = "美德道标_party1", key = "RCTRL-F2", text = "/cast [@party1,help,nodead] 美德道标" },
    { title = "美德道标_party2", key = "RCTRL-F3", text = "/cast [@party2,help,nodead] 美德道标" },
    { title = "美德道标_party3", key = "RCTRL-F4", text = "/cast [@party3,help,nodead] 美德道标" },
    { title = "美德道标_party4", key = "RCTRL-F5", text = "/cast [@party4,help,nodead] 美德道标" },
    { title = "圣洁鸣钟_player", key = "RCTRL-F6", text = "/cast [@player,help,nodead] 圣洁鸣钟" },
    { title = "圣洁鸣钟_party1", key = "RCTRL-F7", text = "/cast [@party1,help,nodead] 圣洁鸣钟" },
    { title = "圣洁鸣钟_party2", key = "RCTRL-F8", text = "/cast [@party2,help,nodead] 圣洁鸣钟" },
    { title = "圣洁鸣钟_party3", key = "RCTRL-F9", text = "/cast [@party3,help,nodead] 圣洁鸣钟" },
    { title = "圣洁鸣钟_party4", key = "RCTRL-F10", text = "/cast [@party4,help,nodead] 圣洁鸣钟" },
    { title = "清洁术_player", key = "RCTRL-F11", text = "/cast [@player,help,nodead] 清洁术" },
    { title = "清洁术_party1", key = "RSHIFT-F1", text = "/cast [@party1,help,nodead] 清洁术" },
    { title = "清洁术_party2", key = "RSHIFT-F2", text = "/cast [@party2,help,nodead] 清洁术" },
    { title = "清洁术_party3", key = "RSHIFT-F3", text = "/cast [@party3,help,nodead] 清洁术" },
    { title = "清洁术_party4", key = "RSHIFT-F4", text = "/cast [@party4,help,nodead] 清洁术" },
    { title = "荣耀圣令_target", key = "RSHIFT-F5", text = "/cast [known:156322,@target,help,nodead] 永恒之火; [@target,help,nodead] 荣耀圣令" },
    { title = "圣光术_target", key = "RSHIFT-F6", text = "/cast [@target,help,nodead] 圣光术" },
    { title = "圣光闪现_target", key = "RSHIFT-F7", text = "/cast [@target,help,nodead] 圣光闪现" },
    { title = "神圣震击_target", key = "RSHIFT-F8", text = "/cast [@target,help,nodead] 神圣震击" },
    { title = "清洁术_target", key = "RSHIFT-F9", text = "/cast [@target,help,nodead] 清洁术" },
    { title = "攻击审判", key = "RSHIFT-F10", text = "/cast [@target,harm,nodead] 审判" },
    { title = "攻击神圣震击", key = "RSHIFT-F11", text = "/cast [@target,harm,nodead] 神圣震击" },
    { title = "攻击正义盾击", key = "RSHIFT-F12", text = "/cast [@target,harm,nodead] 正义盾击" },
    { title = "圣疗术_player", key = "RALT-F1", text = "/cast [@player,help,nodead] 圣疗术" },
    { title = "上饰品", key = "RALT-F2", text = "/use 13" },
    { title = "下饰品", key = "RALT-F3", text = "/use 14" },
    { title = "治疗药水_271884", key = "RALT-F5", text = "/use item:271884" },
    { title = "治疗药水_271883", key = "RALT-F6", text = "/use item:271883" },
    { title = "治疗药水_241304", key = "RALT-F7", text = "/use item:241304" },
    { title = "停止施法", key = "RALT-F8", text = "/stopcasting" },
}
local logging = addonTable.logging
for _, macro in ipairs(macroList) do
    local buttonName = addonName .. "Button" .. macro.title
    local frame = CreateFrame("Button", buttonName, UIParent, "SecureActionButtonTemplate")
    frame:SetAttribute("type", "macro")
    frame:SetAttribute("macrotext", macro.text)
    frame:RegisterForClicks("AnyDown", "AnyUp")
    SetOverrideBindingClick(frame, true, macro.key, buttonName)
    logging("bind " .. macro.key .. " > " .. macro.text)
end

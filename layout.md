# PixHoly 像素布局

Cell 为 4×4 物理像素，IconTile 为 8×8，基板高 12px。普通属性在首行，图标占下方两行。
坐标 x 和 ValueBar 内容宽度均使用整数 Cell。当前数据至 x=177，右侧检测列 x=178，总宽 716px。

## 编码

| 数据 | 编码与解析 |
| --- | --- |
| 布尔 | 黑色=false，白色=true |
| 百分比 | 灰度 / 255 × 100 |
| 整数、单位和首领编号 | 灰度字节取整，不除以255 |
| 冷却／玩家剩余读条 | 灰度255/155/115/25/0对应0/10/30/120/245秒 |
| 光环剩余时间 | 灰度0/150/180/210/255对应0/15/30/60/240秒；永久与饱和共用白色 |
| 首领读条已过时间 | 灰度字节 / 10秒，最多25.5秒 |
| 治疗吸收比例 | 黑白内容中白色像素比例 × 100；超过100%饱和 |

## 全局、玩家与目标属性

| x | 属性 | 说明 |
| --- | --- | --- |
| 001 | `enable` | 按属性名称解码 |
| 002 | `in_burst` | 按属性名称解码 |
| 003 | `delaying` | 按属性名称解码 |
| 004 | `player_is_alive` | 按属性名称解码 |
| 005 | `player_health_pct` | 按属性名称解码 |
| 006 | `power_holy_power` | 按属性名称解码 |
| 007 | `player_in_group` | 玩家是否在队伍或团队中 |
| 008 | `player_in_combat` | 按属性名称解码 |
| 009 | `player_is_player_target` | 按属性名称解码 |
| 010 | `player_is_moving` | 按属性名称解码 |
| 011 | `player_in_vehicle` | 按属性名称解码 |
| 012 | `player_is_targeting_spell` | 按属性名称解码 |
| 013 | `player_is_chatting` | 按属性名称解码 |
| 014 | `ticket_13_ready` | 按属性名称解码 |
| 015 | `ticket_14_ready` | 按属性名称解码 |
| 016 | `healthstone_ready` | 按属性名称解码 |
| 017 | `heal_potion_ready` | 物品241304：库存、可使用状态与冷却 |
| 018 | `player_has_heal_absorb` | 治疗吸收量严格大于0 |
| 019 | `player_has_damage_absorb` | 伤害吸收量严格大于0 |
| 020 | `player_cast_progress` | 按属性名称解码 |
| 021 | `player_is_empowering` | 按属性名称解码 |
| 022 | `target_is_exists` | 按属性名称解码 |
| 023 | `target_is_alive` | 按属性名称解码 |
| 024 | `target_can_attack` | 按属性名称解码 |
| 025 | `target_can_assist` | 按属性名称解码 |
| 026 | `target_health_pct` | 按属性名称解码 |
| 027 | `target_cast_interruptible` | 按属性名称解码 |
| 028 | `target_cast_progress` | 按属性名称解码 |
| 029 | `target_in_melee_range` | 技能853范围 |
| 030 | `target_in_ranged_range` | 技能853范围 |
| 031 | `target_in_interrupt_range` | 技能853范围 |
| 032 | `focus_is_exists` | 按属性名称解码 |
| 033 | `focus_is_alive` | 按属性名称解码 |
| 034 | `focus_can_attack` | 按属性名称解码 |
| 035 | `focus_can_assist` | 按属性名称解码 |
| 036 | `focus_health_pct` | 按属性名称解码 |
| 037 | `focus_cast_interruptible` | 按属性名称解码 |
| 038 | `focus_cast_progress` | 按属性名称解码 |
| 039 | `focus_in_melee_range` | 技能853范围 |
| 040 | `focus_in_ranged_range` | 技能853范围 |
| 041 | `focus_in_interrupt_range` | 技能853范围 |
| 042 | `spell_cd_global_cooldown` | 按属性名称解码 |
| 043 | `spell_cd_cleanse` | 4987 清洁术 |
| 044 | `spell_cd_lay_on_hands` | 633 圣疗术 |
| 045 | `spell_cd_holy_shock` | 20473 神圣震击 |
| 046 | `spell_cd_judgment` | 审判候选275773、275779、20271，神圣优先 |
| 047 | `spell_cd_beacon_of_virtue` | 200025 美德道标 |
| 048 | `spell_cd_divine_toll` | 375576 圣洁鸣钟 |
| 049 | `power_mana_pct` | 按属性名称解码 |
| 050 | `spell_charges_holy_shock` | 20473充能数，灰度0/1/2 |
| 051 | `spell_recharge_holy_shock` | 20473下一充能剩余时间，缺失为黑色 |
| 052 | `player_buff_duration_divine_purpose` | 223819 神圣意志 |
| 053 | `player_buff_duration_infusion_of_light` | 54149 圣光灌注 |
| 054 | `player_buff_duration_hand_of_divinity` | 414273 神性之手 |
| 055 | `player_buff_duration_awakening` | 414193 觉醒 |
| 056 | `auto_cleanse_enabled` | 自动驱散，默认开 |
| 057 | `auto_trinket_enabled` | 自动饰品，默认开 |
| 058 | `concentrated_potion_high_ready` | 物品271884就绪 |
| 059 | `concentrated_potion_ready` | 物品271883就绪 |
| 060 | `player_cast_state` | 0空闲、1普通读条、2引导或蓄力 |
| 061 | `player_cast_remaining` | 普通读条剩余秒数，最后0.4秒允许排队 |
| 062 | `player_cast_kind` | 0未知、1圣光术、2圣光闪现、3其他 |
| 063 | `player_cast_target` | 0未知、1玩家、2–5为party1–4 |
| 064 | `encounter` | 首领枚举；未知或未战斗为0 |
| 065 | `boss1_cast_elapsed` | boss1普通读条已过秒数 |
| 066 | `boss2_cast_elapsed` | boss2普通读条已过秒数 |
| 067 | `target_is_boss1` | 当前目标与boss1是同一单位 |
| 068 | `target_in_healing_range` | 圣光术82326范围 |
| 069 | `target_dispellable_magic` | 按属性名称解码 |
| 070 | `target_dispellable_disease` | 按属性名称解码 |
| 071 | `target_dispellable_poison` | 按属性名称解码 |
| 072 | `player_exists` | 按属性名称解码 |
| 073 | `player_connected` | 按属性名称解码 |
| 074 | `player_can_assist` | 按属性名称解码 |
| 075 | `player_role` | 职责：1坦克、2治疗、3输出、5未分配；缺席为0 |
| 076 | `player_class` | 职业classID，未知0 |
| 077 | `player_in_healing_range` | 圣光术82326范围 |
| 078 | `player_dispellable_magic` | 按属性名称解码 |
| 079 | `player_dispellable_disease` | 按属性名称解码 |
| 080 | `player_dispellable_poison` | 按属性名称解码 |
| 081 | `player_has_beacon` | 道标光环53563、156910、1244893 |
| 082 | `player_has_eternal_flame` | 永恒之火156322 |
| 083 | `player_has_spirit_of_redemption` | 救赎之魂27827 |

## 四连续队友属性

每行在一个 Lua 文件中集中创建四个槽，顺序始终为 party1、party2、party3、party4。
读取第 n 名队友时使用 `起点 + n - 1`。成员不存在时其他属性不参与计算；Context仍保留该成员字典。

| x | 属性 |
| --- | --- |
| 84–87 | 存在 |
| 88–91 | 存活 |
| 92–95 | 连接 |
| 96–99 | 可协助 |
| 100–103 | 预测生命百分比 |
| 104–107 | 职责：1坦克、2治疗、3输出、5未分配 |
| 108–111 | 职业classID |
| 112–115 | 圣光术范围 |
| 116–119 | 伤害吸收量大于0 |
| 120–123 | 治疗吸收量大于0 |
| 124–127 | 可驱散魔法 |
| 128–131 | 可驱散疾病 |
| 132–135 | 可驱散中毒 |
| 136–139 | 道标53563/156910/1244893 |
| 140–143 | 永恒之火156322 |
| 144–147 | 救赎之魂27827 |

## 治疗吸收 ValueBar

| 单位 | 起点 x | 内容宽 | 完整占位 |
| --- | --- | --- | --- |
| player | 148 | 5 Cell | 148–153 |
| party1 | 154 | 5 Cell | 154–159 |
| party2 | 160 | 5 Cell | 160–165 |
| party3 | 166 | 5 Cell | 166–171 |
| party4 | 172 | 5 Cell | 172–177 |

每条20px黑白内容，左右各2px红色分隔，完整占24px。Python调用 `getValueBar(x, 5)`；红色不计入黑白分母，每个内容像素约5个百分点。
数据取详细治疗计算器的 `GetHealAbsorbs()` 与 `GetMaximumHealth()`，表示计算后的治疗吸收比例。
伤害吸收存在性单独监控，不加入生命评分。

## 图标与检测格

I01玩家施法、I02辅助战斗、I03目标施法、I04焦点施法、I05–I19打断黑名单，继续沿用原尺寸和位置。
图标 n 的左边界为 `4 + 8 × (n−1)`，上边界4px。没有自动打断动作。
左检测列为x=0，右检测列为x=178；截图定位与Matrix检测方式保持一致。

## 刷新和首领

队伍变化事件合并刷新四槽，先判断存在；空槽清零，光环容器隐藏。相同party token换人时重新设置候选条件并刷新光环。
普通状态事件刷新并保留2秒兜底；友方范围、技能冷却和首领计时0.1秒刷新，玩家读条0.05秒刷新；光环依靠原生容器更新。
首领完整编号表位于 `pix/lua/cells/064_encounter.lua`：3201→92、2623→100、2127→107。战斗结束清零。

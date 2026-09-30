"""烈日奶骑治疗优先级：动态选择小队成员，执行首个满足条件的动作。"""

from pix.action import Cast, Idle, Use
from pix.context import Context, PartyMember


class Rotation:
    def __init__(self) -> None:
        self.keymap: dict[str, str] = {
            "荣耀圣令_player": "RCTRL-NUMPAD1",
            "荣耀圣令_party1": "RCTRL-NUMPAD2",
            "荣耀圣令_party2": "RCTRL-NUMPAD3",
            "荣耀圣令_party3": "RCTRL-NUMPAD4",
            "荣耀圣令_party4": "RCTRL-NUMPAD5",
            "圣光术_player": "RCTRL-NUMPAD6",
            "圣光术_party1": "RCTRL-NUMPAD7",
            "圣光术_party2": "RCTRL-NUMPAD8",
            "圣光术_party3": "RCTRL-NUMPAD9",
            "圣光术_party4": "RCTRL-NUMPAD0",
            "圣光闪现_player": "RSHIFT-NUMPAD1",
            "圣光闪现_party1": "RSHIFT-NUMPAD2",
            "圣光闪现_party2": "RSHIFT-NUMPAD3",
            "圣光闪现_party3": "RSHIFT-NUMPAD4",
            "圣光闪现_party4": "RSHIFT-NUMPAD5",
            "神圣震击_player": "RSHIFT-NUMPAD6",
            "神圣震击_party1": "RSHIFT-NUMPAD7",
            "神圣震击_party2": "RSHIFT-NUMPAD8",
            "神圣震击_party3": "RSHIFT-NUMPAD9",
            "神圣震击_party4": "RSHIFT-NUMPAD0",
            "美德道标_player": "RCTRL-F1",
            "美德道标_party1": "RCTRL-F2",
            "美德道标_party2": "RCTRL-F3",
            "美德道标_party3": "RCTRL-F4",
            "美德道标_party4": "RCTRL-F5",
            "圣洁鸣钟_player": "RCTRL-F6",
            "圣洁鸣钟_party1": "RCTRL-F7",
            "圣洁鸣钟_party2": "RCTRL-F8",
            "圣洁鸣钟_party3": "RCTRL-F9",
            "圣洁鸣钟_party4": "RCTRL-F10",
            "清洁术_player": "RCTRL-F11",
            "清洁术_party1": "RSHIFT-F1",
            "清洁术_party2": "RSHIFT-F2",
            "清洁术_party3": "RSHIFT-F3",
            "清洁术_party4": "RSHIFT-F4",
            "荣耀圣令_target": "RSHIFT-F5",
            "圣光术_target": "RSHIFT-F6",
            "圣光闪现_target": "RSHIFT-F7",
            "神圣震击_target": "RSHIFT-F8",
            "清洁术_target": "RSHIFT-F9",
            "攻击审判": "RSHIFT-F10",
            "攻击神圣震击": "RSHIFT-F11",
            "攻击正义盾击": "RSHIFT-F12",
            "圣疗术_player": "RALT-F1",
            "上饰品": "RALT-F2",
            "下饰品": "RALT-F3",
            "治疗药水_271884": "RALT-F5",
            "治疗药水_271883": "RALT-F6",
            "治疗药水_241304": "RALT-F7",
            "停止施法": "RALT-F8",
        }

    def calculate_party_health_score(self, ctx: Context) -> list[PartyMember]:
        party: list[PartyMember] = []
        for member in ctx.party.values():
            if not (member["exist"] and member["alive"] and member["connected"]
                    and member["can_assist"] and member["in_healing_range"]):
                continue
            if member["has_spirit_of_redemption"]:
                continue
            scored = member.copy()
            score = member["health_pct"] - member["heal_absorb_pct"]
            if ctx.player_cast_state == 1 and member["unit"] == ctx.player_cast_target:
                if ctx.player_cast_kind == 1:
                    score += 40
                elif ctx.player_cast_kind == 2:
                    score += 15
            scored["health_score"] = score
            party.append(scored)
        return party

    @staticmethod
    def lowest_member(party: list[PartyMember], threshold: float = 100,
                      role: int | None = None) -> PartyMember | None:
        injured = [member for member in party
                   if member["health_score"] < threshold and (role is None or member["role"] == role)]
        injured.sort(key=lambda member: member["health_score"])
        return injured[0] if injured else None

    @staticmethod
    def count_injured(party: list[PartyMember], threshold: float) -> int:
        return sum(0 < member["health_score"] < threshold for member in party)

    @staticmethod
    def healing_cast(spell: str, member: PartyMember, note: str = "") -> Cast:
        return Cast(f"{spell}_{member['unit']}", note)

    def main_rotation(self, ctx: Context) -> Cast | Use | Idle:
        # 如果 插件未启用、手动操作延迟中，或玩家无法行动
        # => 暂停自动动作
        if not ctx.enable:
            return Idle("插件未启用")
        if ctx.delaying:
            return Idle("手动操作延迟中")
        if not ctx.player_is_alive:
            return Idle("玩家未存活")
        if ctx.player_in_vehicle or ctx.player_is_chatting or ctx.player_is_targeting_spell:
            return Idle("骑乘、载具、输入或地面选点中")

        # 如果 首领危险施法已经过4秒
        # => 停止当前施法，并等待危险窗口结束
        if ctx.encounter_index == 100 and max(ctx.boss1_cast_elapsed, ctx.boss2_cast_elapsed) >= 4:
            if ctx.player_cast_state or ctx.player_is_empowering:
                return Use("停止施法")
            return Idle("首领危险施法中")

        # 如果 正在引导、蓄力，或普通读条尚未进入最后0.4秒
        # => 等待当前技能；末段按预测状态选择下一技能
        if ctx.player_cast_state == 2 or ctx.player_is_empowering:
            return Idle("玩家正在引导或蓄力")
        if ctx.player_cast_state == 1 and ctx.player_cast_remaining > 0.4:
            return Idle("等待读条排队窗口")

        party = self.calculate_party_health_score(ctx)
        lowest = self.lowest_member(party)
        damage_lowest = self.lowest_member(party, role=3)
        mana = ctx.power_mana_pct
        holy_power = ctx.power_holy_power
        if ctx.player_cast_state == 1 and ctx.player_cast_kind in (1, 2):
            holy_power += 1
        infusion = ctx.player_buff_duration_infusion_of_light
        divinity = ctx.player_buff_duration_hand_of_divinity
        purpose = ctx.player_buff_duration_divine_purpose
        awakening = ctx.player_buff_duration_awakening
        charges = ctx.spell_charges_holy_shock
        holy_threshold = int(mana - 25)
        flash_lowest = self.lowest_member(party, int(100 - infusion))
        divinity_lowest = self.lowest_member(party, int(100 - 2 * divinity))
        holy_lowest = self.lowest_member(party, holy_threshold)
        c90 = self.count_injured(party, 90)
        c80 = self.count_injured(party, 80)
        c70 = self.count_injured(party, 70)
        c_holy = self.count_injured(party, holy_threshold)
        friendly_target = (ctx.target_is_exists and ctx.target_is_alive
                           and ctx.target_can_assist and ctx.target_in_healing_range)
        enemy_target = (ctx.target_is_exists and ctx.target_is_alive
                        and ctx.target_can_attack and ctx.target_in_hammer_of_justice_range)

        # 如果 清洁术就绪且自动驱散开启
        # => 按魔法、疾病、中毒顺序选择首名队友，然后处理友方当前目标
        if ctx.auto_cleanse_enabled and ctx.spell_cd_cleanse == 0:
            magic = [member for member in party if member["dispellable_magic"]]
            disease = [member for member in party if member["dispellable_disease"]]
            poison = [member for member in party if member["dispellable_poison"]]
            for candidates in (magic, disease, poison):
                if candidates:
                    return self.healing_cast("清洁术", candidates[0])
            if friendly_target and (ctx.target_dispellable_magic or ctx.target_dispellable_disease
                                    or ctx.target_dispellable_poison):
                return Cast("清洁术_target")

        # 如果 自身生命不高于30%，且有可用治疗药水
        # => 优先浓缩药水；生命不高于20%且药水不可用时使用圣疗术
        potion = next((item for item, ready in (
            (271884, ctx.concentrated_potion_high_ready),
            (271883, ctx.concentrated_potion_ready),
            (241304, ctx.heal_potion_ready),
        ) if ready), None)
        if ctx.player_health_pct <= 30 and potion is not None:
            return Use(f"治疗药水_{potion}")
        if ctx.player_health_pct <= 20 and potion is None and ctx.spell_cd_lay_on_hands == 0:
            return Cast("圣疗术_player")

        # 如果 战斗中的爆发窗口有效且自动饰品开启
        # => 先使用上饰品，再使用下饰品
        if ctx.player_in_combat and ctx.in_burst and ctx.auto_trinket_enabled:
            if ctx.ticket_13_ready:
                return Use("上饰品")
            if ctx.ticket_14_ready:
                return Use("下饰品")

        # 如果 护光者鲁伊亚战斗中存在需要治疗的成员
        # => 按圣令、灌注闪现、震击、圣光术顺序治疗
        if ctx.encounter_index == 92 and lowest is not None:
            if holy_power >= 3:
                return self.healing_cast("荣耀圣令", lowest)
            if infusion > 0:
                return self.healing_cast("圣光闪现", lowest)
            if charges >= 1:
                return self.healing_cast("神圣震击", lowest)
            if infusion == 0:
                return self.healing_cast("圣光术", lowest)

        # 如果 最低成员生命评分不高于80，且有足够圣能或神圣意志
        # => 使用圣令；脱战时消耗即将结束的神圣意志或满圣能
        if lowest is not None:
            if lowest["health_score"] <= 80 and (holy_power >= 3 or purpose > 0):
                return self.healing_cast("荣耀圣令", lowest)
            if not ctx.player_in_combat and (0 < purpose <= 5 or holy_power == 5):
                return self.healing_cast("荣耀圣令", lowest)

        # 如果 战斗中有范围内敌人，且有足够圣能或即将结束的神圣意志
        # => 使用正义盾击
        if ctx.player_in_combat and enemy_target and (holy_power >= 3 or 0 < purpose <= 3):
            return Cast("攻击正义盾击")

        # 如果 有圣光灌注，且存在低于瞬闪阈值的成员
        # => 对该成员施放圣光闪现
        if infusion > 0 and flash_lowest is not None:
            return self.healing_cast("圣光闪现", flash_lowest)

        # 如果 输出成员评分不高于80，且队伍达到群疗人数条件
        # => 优先美德道标，低圣能时再考虑圣洁鸣钟
        if ctx.player_in_combat and damage_lowest is not None and damage_lowest["health_score"] <= 80:
            if ctx.spell_cd_beacon_of_virtue == 0 and (c90 >= 3 or c80 >= 2):
                return self.healing_cast("美德道标", damage_lowest)
            if holy_power <= 1 and ctx.spell_cd_divine_toll == 0 and (c80 >= 3 or c70 >= 2):
                return self.healing_cast("圣洁鸣钟", damage_lowest)

        # 如果 有神性之手且没有圣光灌注
        # => 优先治疗低于神性阈值的成员，再治疗评分不高于80的最低成员
        if divinity > 0 and infusion == 0:
            if divinity_lowest is not None:
                return self.healing_cast("圣光术", divinity_lowest)
            if lowest is not None and lowest["health_score"] <= 80:
                return self.healing_cast("圣光术", lowest)

        # 如果 审判就绪，战斗中有范围内敌人，且觉醒存在或没有圣光灌注
        # => 优先审判
        judgment_ready = ctx.player_in_combat and enemy_target and ctx.spell_cd_judgment == 0
        if judgment_ready and (awakening > 0 or infusion == 0):
            return Cast("攻击审判")

        # 如果 震击满充能、即将恢复第二层，或最低成员评分不高于90且无灌注
        # => 对最低成员施放神圣震击
        if lowest is not None:
            if charges == 2:
                return self.healing_cast("神圣震击", lowest, "满充能")
            if charges == 1 and ctx.spell_recharge_holy_shock <= 1:
                return self.healing_cast("神圣震击", lowest, "即将恢复充能")
            if charges == 1 and lowest["health_score"] <= 90 and infusion == 0:
                return self.healing_cast("神圣震击", lowest)

        # 如果 战斗中有范围内敌人
        # => 以就绪的审判、神圣震击填充输出
        if judgment_ready:
            return Cast("攻击审判")
        if ctx.player_in_combat and enemy_target and ctx.spell_cd_holy_shock == 0:
            return Cast("攻击神圣震击")

        # 如果 没有圣光灌注，且至少两人低于圣光阈值
        # => 治疗最低成员；否则静止时治疗低于圣光阈值的成员
        if infusion == 0:
            if c_holy >= 2 and lowest is not None:
                return self.healing_cast("圣光术", lowest)
            if holy_lowest is not None and not ctx.player_is_moving:
                return self.healing_cast("圣光术", holy_lowest)

        # 如果 塞塔里斯的化身战斗中，当前目标是可治疗的首领
        # => 按圣令、灌注闪现、震击、圣光术顺序治疗首领
        if ctx.encounter_index == 107 and friendly_target and ctx.target_is_boss1:
            if holy_power >= 3:
                return Cast("荣耀圣令_target")
            if infusion > 0:
                return Cast("圣光闪现_target")
            if charges > 0:
                return Cast("神圣震击_target")
            if mana >= 30:
                return Cast("圣光术_target")

        return Idle("没有满足条件的动作")

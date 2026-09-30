"""Semantic properties decoded from the current Lua cells and icon tiles."""

from functools import cached_property
from typing import TypedDict

import numpy as np

from pix.matrix import Matrix


class PartyMember(TypedDict):
    unit: str
    exist: bool
    alive: bool
    connected: bool
    can_assist: bool
    health_pct: float
    role: int
    class_id: int
    in_healing_range: bool
    has_damage_absorb: bool
    has_heal_absorb: bool
    heal_absorb_pct: float
    dispellable_magic: bool
    dispellable_disease: bool
    dispellable_poison: bool
    has_beacon: bool
    has_eternal_flame: bool
    has_spirit_of_redemption: bool
    health_score: float


class Context:
    def __init__(self, matrix: Matrix) -> None:
        self.matrix = matrix

    def readBooleanCell(self, x: int) -> bool:
        return self.matrix.getCell(x).is_white

    def readPercentCell(self, x: int) -> float:
        return self.matrix.getCell(x).percent

    def readNumberCell(self, x: int) -> float:
        return self.matrix.getCell(x).mean

    def readValueBarCell(self, x: int, width: int, max_value: float) -> float:
        return self.matrix.getValueBar(x, width).ratio * max_value

    def readSpellCDCell(self, x: int) -> float:
        return float(np.interp(self.matrix.getCell(x).mean, (0, 25, 115, 155, 255), (245, 120, 30, 10, 0)))

    def readAuraDurationCell(self, x: int) -> float:
        return float(np.interp(self.matrix.getCell(x).mean, (0, 150, 180, 210, 255), (0, 15, 30, 60, 240)))

    def readIconTile(self, x: int) -> str | None:
        return self.matrix.getIconTile(x).hash

    @property
    def enable(self) -> bool:
        return self.readBooleanCell(1)

    @property
    def in_burst(self) -> bool:
        return self.readBooleanCell(2)

    @property
    def delaying(self) -> bool:
        return self.readBooleanCell(3)

    @property
    def player_is_alive(self) -> bool:
        return self.readBooleanCell(4)

    @property
    def player_health_pct(self) -> float:
        return self.readPercentCell(5)

    @property
    def power_holy_power(self) -> int:
        return int(self.readNumberCell(6) + 0.5)

    @property
    def player_in_group(self) -> bool:
        return self.readBooleanCell(7)

    @property
    def player_in_combat(self) -> bool:
        return self.readBooleanCell(8)

    @property
    def player_is_player_target(self) -> bool:
        return self.readBooleanCell(9)

    @property
    def player_is_moving(self) -> bool:
        return self.readBooleanCell(10)

    @property
    def player_in_vehicle(self) -> bool:
        return self.readBooleanCell(11)

    @property
    def player_is_targeting_spell(self) -> bool:
        return self.readBooleanCell(12)

    @property
    def player_is_chatting(self) -> bool:
        return self.readBooleanCell(13)

    @property
    def ticket_13_ready(self) -> bool:
        return self.readBooleanCell(14)

    @property
    def ticket_14_ready(self) -> bool:
        return self.readBooleanCell(15)

    @property
    def healthstone_ready(self) -> bool:
        return self.readBooleanCell(16)

    @property
    def heal_potion_ready(self) -> bool:
        return self.readBooleanCell(17)

    @property
    def player_has_heal_absorb(self) -> bool:
        return self.readBooleanCell(18)

    @property
    def player_has_damage_absorb(self) -> bool:
        return self.readBooleanCell(19)

    @property
    def player_cast_progress(self) -> float:
        return self.readPercentCell(20)

    @property
    def player_is_empowering(self) -> bool:
        return self.readBooleanCell(21)

    @property
    def target_is_exists(self) -> bool:
        return self.readBooleanCell(22)

    @property
    def target_is_alive(self) -> bool:
        return self.readBooleanCell(23)

    @property
    def target_can_attack(self) -> bool:
        return self.readBooleanCell(24)

    @property
    def target_can_assist(self) -> bool:
        return self.readBooleanCell(25)

    @property
    def target_health_pct(self) -> float:
        return self.readPercentCell(26)

    @property
    def target_cast_interruptible_raw(self) -> bool:
        """Current interruptible cast/channel, without blacklist filtering."""
        return self.readBooleanCell(27)

    @property
    def target_cast_interruptible(self) -> bool:
        if not self.target_cast_interruptible_raw:
            return False
        icon = self.target_cast_icon
        return icon is not None and icon not in self.interrupt_blacklist

    @property
    def target_cast_progress(self) -> float:
        return self.readPercentCell(28)

    @property
    def target_in_melee_range(self) -> bool:
        return self.readBooleanCell(29)

    @property
    def target_in_ranged_range(self) -> bool:
        return self.readBooleanCell(30)

    @property
    def target_in_interrupt_range(self) -> bool:
        return self.readBooleanCell(31)

    @property
    def focus_is_exists(self) -> bool:
        return self.readBooleanCell(32)

    @property
    def focus_is_alive(self) -> bool:
        return self.readBooleanCell(33)

    @property
    def focus_can_attack(self) -> bool:
        return self.readBooleanCell(34)

    @property
    def focus_can_assist(self) -> bool:
        return self.readBooleanCell(35)

    @property
    def focus_health_pct(self) -> float:
        return self.readPercentCell(36)

    @property
    def focus_cast_interruptible_raw(self) -> bool:
        """Current interruptible cast/channel, without blacklist filtering."""
        return self.readBooleanCell(37)

    @property
    def focus_cast_interruptible(self) -> bool:
        if not self.focus_cast_interruptible_raw:
            return False
        icon = self.focus_cast_icon
        return icon is not None and icon not in self.interrupt_blacklist

    @property
    def focus_cast_progress(self) -> float:
        return self.readPercentCell(38)

    @property
    def focus_in_melee_range(self) -> bool:
        return self.readBooleanCell(39)

    @property
    def focus_in_ranged_range(self) -> bool:
        return self.readBooleanCell(40)

    @property
    def focus_in_interrupt_range(self) -> bool:
        return self.readBooleanCell(41)

    @property
    def spell_cd_global_cooldown(self) -> float:
        return self.readSpellCDCell(42)

    @property
    def spell_cd_cleanse(self) -> float:
        return self.readSpellCDCell(43)

    @property
    def spell_cd_lay_on_hands(self) -> float:
        return self.readSpellCDCell(44)

    @property
    def spell_cd_holy_shock(self) -> float:
        return self.readSpellCDCell(45)

    @property
    def spell_cd_judgment(self) -> float:
        return self.readSpellCDCell(46)

    @property
    def spell_cd_beacon_of_virtue(self) -> float:
        return self.readSpellCDCell(47)

    @property
    def spell_cd_divine_toll(self) -> float:
        return self.readSpellCDCell(48)

    @property
    def power_mana_pct(self) -> float:
        return self.readPercentCell(49)

    @property
    def spell_charges_holy_shock(self) -> int:
        return int(self.readNumberCell(50) + 0.5)

    @property
    def spell_recharge_holy_shock(self) -> float:
        return self.readSpellCDCell(51)

    @property
    def player_buff_duration_divine_purpose(self) -> float:
        return self.readAuraDurationCell(52)

    @property
    def player_buff_duration_infusion_of_light(self) -> float:
        return self.readAuraDurationCell(53)

    @property
    def player_buff_duration_hand_of_divinity(self) -> float:
        return self.readAuraDurationCell(54)

    @property
    def player_buff_duration_awakening(self) -> float:
        return self.readAuraDurationCell(55)

    @property
    def auto_cleanse_enabled(self) -> bool:
        return self.readBooleanCell(56)

    @property
    def auto_trinket_enabled(self) -> bool:
        return self.readBooleanCell(57)

    @property
    def concentrated_potion_high_ready(self) -> bool:
        return self.readBooleanCell(58)

    @property
    def concentrated_potion_ready(self) -> bool:
        return self.readBooleanCell(59)

    @property
    def player_cast_state(self) -> int:
        return int(self.readNumberCell(60) + 0.5)

    @property
    def player_cast_remaining(self) -> float:
        return self.readSpellCDCell(61)

    @property
    def player_cast_kind(self) -> int:
        return int(self.readNumberCell(62) + 0.5)

    @property
    def encounter_index(self) -> int:
        return int(self.readNumberCell(64) + 0.5)

    @property
    def target_is_boss1(self) -> bool:
        return self.readBooleanCell(67)

    @property
    def target_in_healing_range(self) -> bool:
        return self.readBooleanCell(68)

    @property
    def target_dispellable_magic(self) -> bool:
        return self.readBooleanCell(69)

    @property
    def target_dispellable_disease(self) -> bool:
        return self.readBooleanCell(70)

    @property
    def target_dispellable_poison(self) -> bool:
        return self.readBooleanCell(71)

    @property
    def target_in_hammer_of_justice_range(self) -> bool:
        return self.readBooleanCell(29)

    @property
    def focus_in_hammer_of_justice_range(self) -> bool:
        return self.readBooleanCell(39)

    @property
    def player_cast_target(self) -> str | None:
        index = int(self.readNumberCell(63) + 0.5)
        units = ("player", "party1", "party2", "party3", "party4")
        return units[index - 1] if 1 <= index <= 5 else None

    @property
    def boss1_cast_elapsed(self) -> float:
        return self.readNumberCell(65) / 10

    @property
    def boss2_cast_elapsed(self) -> float:
        return self.readNumberCell(66) / 10

    @cached_property
    def party(self) -> dict[str, PartyMember]:
        members: dict[str, PartyMember] = {}
        # 玩家沿用基础状态格，队友同类属性连续排列。
        for index, unit in enumerate(("player", "party1", "party2", "party3", "party4")):
            offset = index - 1
            def position(player: int, first_party: int) -> int:
                return player if index == 0 else first_party + offset

            exist = self.readBooleanCell(position(72, 84))
            def boolean(player: int, first_party: int) -> bool:
                return exist and self.readBooleanCell(position(player, first_party))

            health = self.readPercentCell(position(5, 100)) if exist else 0.0
            absorb = self.readValueBarCell(148 + index * 6, 5, 100) if exist else 0.0
            members[unit] = {
                "unit": unit,
                "exist": exist,
                "alive": boolean(4, 88),
                "connected": boolean(73, 92),
                "can_assist": boolean(74, 96),
                "health_pct": health,
                "role": int(self.readNumberCell(position(75, 104)) + 0.5) if exist else 0,
                "class_id": int(self.readNumberCell(position(76, 108)) + 0.5) if exist else 0,
                "in_healing_range": boolean(77, 112),
                "has_damage_absorb": boolean(19, 116),
                "has_heal_absorb": boolean(18, 120),
                "heal_absorb_pct": absorb,
                "dispellable_magic": boolean(78, 124),
                "dispellable_disease": boolean(79, 128),
                "dispellable_poison": boolean(80, 132),
                "has_beacon": boolean(81, 136),
                "has_eternal_flame": boolean(82, 140),
                "has_spirit_of_redemption": boolean(83, 144),
                "health_score": health - absorb,
            }
        return members

    @property
    def player_cast_icon(self) -> str | None:
        return self.readIconTile(1)

    @property
    def assisted_combat_icon(self) -> str | None:
        return self.readIconTile(2)

    @property
    def target_cast_icon(self) -> str | None:
        return self.readIconTile(3)

    @property
    def focus_cast_icon(self) -> str | None:
        return self.readIconTile(4)

    @property
    def interrupt_blacklist(self) -> list[str]:
        return [icon for x in range(5, 20) if (icon := self.readIconTile(x)) is not None]

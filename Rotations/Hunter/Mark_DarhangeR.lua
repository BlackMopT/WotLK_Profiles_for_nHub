local data = {"DarhangeR.lua"}
local popup_shown = false;
local enemies = { };
local function ActiveEnemies()
	table.wipe(enemies);
	enemies = ni.unit.enemiesinrange("target", 7);
	for k, v in ipairs(enemies) do
		if ni.player.threat(v.guid) == -1 then
			table.remove(enemies, k);
		end
	end
	return #enemies;
end
local items = {
	settingsfile = "DarhangeR_Marksman.xml",
	{ type = "title", text = "Marksmanship Hunter by DarhangeR" },
	{ type = "separator" },
	{ type = "title", text = "Main Settings" },
	{ type = "separator" },	
	{ type = "entry", text = "Aspect of the Dragonhawk (Mana cup)", value = 85, key = "dragon" },
	{ type = "entry", text = "Aspect of the Viper (Mana threshold)", value = 15, key = "viper" },
	{ type = "entry", text = "Mend Pet", enabled = true, value = 80, key = "mendpet" },
	{ type = "entry", text = "Auto Interrupt", enabled = true, key = "autointerrupt" },	
	{ type = "separator" },
	{ type = "title", text = "Defensive Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Feign Death", enabled = true, key = "feign" },	
	{ type = "entry", text = "Deterrence", enabled = true, value = 25, key = "deterrence" },
	{ type = "entry", text = "Healthstone", enabled = true, value = 35, key = "healthstoneuse" },
	{ type = "entry", text = "Heal Potion", enabled = true, value = 30, key = "healpotionuse" },
	{ type = "entry", text = "Mana Potion", enabled = true, value = 25, key = "manapotionuse" },
};
local function GetSetting(name)
    for k, v in ipairs(items) do
        if v.type == "entry"
         and v.key ~= nil
         and v.key == name then
            return v.value, v.enabled
        end
        if v.type == "dropdown"
         and v.key ~= nil
         and v.key == name then
            for k2, v2 in pairs(v.menu) do
                if v2.selected then
                    return v2.value
                end
            end
        end
        if v.type == "input"
         and v.key ~= nil
         and v.key == name then
            return v.value
        end
    end
end;

local queue = {
	"Window",
	"Cancel Deterrence",	
	"Universal pause",
	"AutoTarget",
	"Trueshot Aura",
	"Aspect of the Dragonhawk",
	"Aspect of the Viper",
	"Pet:Heart of the Phoenix",
	"Mend Pet",
	"Hunter's Mark",
	"Combat specific Pause",
	"Pet Attack/Follow",
	"Healthstone (Use)",
	"Heal Potions (Use)",
	"Mana Potions (Use)",
	"Racial Stuff",
	"Use enginer gloves",
	"Trinkets",
	"Silencing Shot (Interrupt)",
	"Deterrence",
	"Wing Clip",
	"Volley",
	"Freezing Arrow",
	"Rapid Fire",
	"Pet:Call of the Wild",
	"Readiness",
	"Kill Command",
	"Misdirection",
	"Feign Death",
	"Mongoose Bite",
	"Raptor Strike",
	"Tranquilizing Shot",
	"Kill Shot",
	"Multi-Shot (AoE)",
	"Serpent Sting",
	"Chimera Shot",
	"Aimed Shot",
	"Arcane Shot",
	"Steady Shot",
}
local abilities = {
-----------------------------------
	["Universal pause"] = function()
		if ni.data.darhanger.UniPause() then
			return true
		end
	end,
-----------------------------------
	["AutoTarget"] = function()
		if UnitAffectingCombat("player")
		 and ((ni.unit.exists("target")
		 and UnitIsDeadOrGhost("target")
		 and not UnitCanAttack("player", "target")) 
		 or not ni.unit.exists("target")) then
			ni.player.runtext("/targetenemy")
		end
	end,
-----------------------------------
	["Trueshot Aura"] = function()
		if not ni.player.buff(19506)
		 and ni.spell.isinstant(19506)
		 and ni.spell.available(19506) then
			ni.spell.cast(19506)
			return true
		end
	end,
-----------------------------------
	["Aspect of the Dragonhawk"] = function()
		local value = GetSetting("dragon");
		if not ni.player.buff(61847)
		 and ni.spell.available(61847)
		 and ni.spell.isinstant(61847)
		 and ni.player.power() > value then
			ni.spell.cast(61847)
			return true
		end
	end,
-----------------------------------
	["Aspect of the Viper"] = function()
		local value = GetSetting("viper");
		if not ni.player.buff(34074)
		 and ni.spell.available(34074)
		 and ni.spell.isinstant(61847)
		 and ni.player.power() < value then
			ni.spell.cast(34074)
			return true
		end
	end,
-----------------------------------
	["Pet Attack/Follow"] = function()
		if ni.unit.hp("playerpet") < 20
		 and ni.unit.exists("playerpet")
		 and ni.unit.exists("target")
		 and UnitIsUnit("target", "pettarget")
		 and ni.unit.buff("pet", 48990)
		 and not UnitIsDeadOrGhost("playerpet") then
			ni.data.darhanger.petFollow()
		 else
		if UnitAffectingCombat("player")
		 and ni.unit.exists("playerpet")
		 and ni.unit.hp("playerpet") > 60
		 and ni.unit.exists("target")
		 and not UnitIsUnit("target", "pettarget")
		 and not UnitIsDeadOrGhost("playerpet") then 
			ni.data.darhanger.petAttack()
			end
		end
	end,
-----------------------------------
	["Mend Pet"] = function()
		local value, enabled = GetSetting("mendpet");
		if enabled
		 and ni.unit.hp("playerpet") < value
		 and not ni.unit.buff("pet", 48990)
		 and ni.unit.exists("playerpet")
		 and UnitInRange("playerpet")
		 and ni.spell.isinstant(48990)
		 and ni.spell.available(48990)
		 and not UnitIsDeadOrGhost("playerpet") then
			ni.spell.cast(48990)
			return true
		end
	end,
-----------------------------------
	["Hunter's Mark"] = function()
		if ( ni.vars.combat.cd or ni.unit.isboss("target") ) 
		 and not ni.unit.debuff("target", 53338)
		 and ni.spell.available(53338)
		 and ni.spell.isinstant(53338)		 
		 and ni.spell.valid("target", 53338, true, true) then
			ni.spell.cast(53338)
			return true
		end
	end,
-----------------------------------
	["Cancel Deterrence"] = function()
		local p="player" for i = 1,40 
		do local _,_,_,_,_,_,_,u,_,_,s=ni.player.buff(p,i)
		 if ni.player.hp() > 45
		 and u==p and s==19263 then
				CancelUnitBuff(p,i)
				break 
			end
		end
	end,
-----------------------------------
	["Combat specific Pause"] = function()
		if ni.data.darhanger.meleeStop("target")
		 or ni.data.darhanger.PlayerDebuffs("player")
		 or UnitCanAttack("player","target") == nil
		 or (UnitAffectingCombat("target") == nil 
		 and ni.unit.isdummy("target") == nil 
		 and UnitIsPlayer("target") == nil) then 
			return true
		end
	end,
-----------------------------------
	["Healthstone (Use)"] = function()
		local value, enabled = GetSetting("healthstoneuse");
		local hstones = { 36892, 36893, 36894 }
		for i = 1, #hstones do
			if enabled
			 and ni.player.hp() < value
			 and ni.player.hasitem(hstones[i]) 
			 and ni.player.itemcd(hstones[i]) == 0 then
				ni.player.useitem(hstones[i])
				return true
			end
		end	
	end,
-----------------------------------
	["Heal Potions (Use)"] = function()
		local value, enabled = GetSetting("healpotionuse");
		local hpot = { 33447, 43569, 40087, 41166, 40067 }
		for i = 1, #hpot do
			if enabled
			 and ni.player.hp() < value
			 and ni.player.hasitem(hpot[i])
			 and ni.player.itemcd(hpot[i]) == 0 then
				ni.player.useitem(hpot[i])
				return true
			end
		end
	end,
-----------------------------------
	["Mana Potions (Use)"] = function()
		local value, enabled = GetSetting("manapotionuse");
		local mpot = { 33448, 43570, 40087, 42545, 39671 }
		for i = 1, #mpot do
			if enabled
			 and ni.player.power() < value
			 and ni.player.hasitem(mpot[i])
			 and ni.player.itemcd(mpot[i]) == 0 then
				ni.player.useitem(mpot[i])
				return true
			end
		end
	end,
-----------------------------------
	["Racial Stuff"] = function()
		local hracial = { 33697, 20572, 33702, 26297 }
		local alracial = { 20594, 28880 }
		--- Undead
		if ni.data.darhanger.forsaken("player")
		 and IsSpellKnown(7744)
		 and ni.spell.available(7744) then
				ni.spell.cast(7744)
				return true
		end
		--- Horde race
		for i = 1, #hracial do
		if ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and IsSpellKnown(hracial[i])
		 and ni.spell.available(hracial[i])
		 and ni.data.darhanger.CDsaverTTD("target")
		 and ni.spell.valid("target", 49052) then 
					ni.spell.cast(hracial[i])
					return true
			end
		end
		--- Ally race
		for i = 1, #alracial do
		if ni.spell.valid("target", 49052)
		 and ni.player.hp() < 20
		 and IsSpellKnown(alracial[i])
		 and ni.spell.available(alracial[i]) then 
					ni.spell.cast(alracial[i])
					return true
				end
			end
		end,
-----------------------------------
	["Use enginer gloves"] = function()
		if ni.player.slotcastable(10)
		 and ni.player.slotcd(10) == 0
		 and ni.data.darhanger.CDsaverTTD("target")
		 and ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and ni.spell.valid("target", 49052) then
			ni.player.useinventoryitem(10)
			return true
		end
	end,
-----------------------------------
	["Trinkets"] = function()
		if ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and ni.player.slotcastable(13)
		 and ni.player.slotcd(13) == 0
		 and ni.data.darhanger.CDsaverTTD("target")
		 and ni.spell.valid("target", 49052) then
			ni.player.useinventoryitem(13)
		else
		 if ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and ni.player.slotcastable(14)
		 and ni.player.slotcd(14) == 0 
		 and ni.data.darhanger.CDsaverTTD("target")
		 and ni.spell.valid("target", 49052) then
			ni.player.useinventoryitem(14)
			return true
			end
		end
	end,
-----------------------------------
	["Deterrence"] = function()
		local value, enabled = GetSetting("deterrence");
		if enabled
		 and ni.player.hp() < value
		 and ni.spell.isinstant(19263)
		 and ni.spell.available(19263) then
			ni.spell.cast(19263)
			return true
		end
	end,
-----------------------------------
	["Wing Clip"] = function()
		if ni.player.distance("target") < 2
		 and not ni.unit.debuff("target", 2974)
		 and ni.spell.isinstant(2974)
		 and ni.spell.available(2974)
		 and ni.spell.valid("target", 53339, true, true) then
			ni.spell.cast(2974, "target")
			return true
		end
	end,
-----------------------------------
	["Volley"] = function()
		if ni.vars.combat.aoe
		 and not ni.player.ismoving()
		 and ni.spell.available(58434) then
			ni.spell.castat(58434, "target")
			return true
		end
	end,
-----------------------------------
	["Freezing Arrow"] = function()
		if ni.rotation.custommod()
		 and ni.spell.isinstant(60192)
		 and ni.spell.available(60192) then
			ni.spell.castat(60192, "target")
			return true
		end
	end,
-----------------------------------
	["Rapid Fire"] = function()
		if ( ni.vars.CD or ni.unit.isboss("target") )
		 and not ni.player.buff(3045)
		 and ni.player.buff(61847)
		 and ni.spell.available(3045)
		 and ni.spell.isinstant(3045)
		 and ni.data.darhanger.CDsaverTTD("target")
		 and ni.spell.valid("target", 49045) then
			ni.spell.cast(3045)
			return true
		end
	end,
-----------------------------------
	["Pet:Call of the Wild"] = function()
		if ( ni.vars.CD or ni.unit.isboss("target") )
		 and IsSpellKnown(53434, true)
		 and ni.data.darhanger.CDsaverTTD("target")
		 and GetSpellCooldown(53434) == 0 then
			ni.spell.cast(53434)
			return true
		end
	end,
-----------------------------------
	["Pet:Heart of the Phoenix"] = function()
		if ( ni.vars.CD or ni.unit.isboss("target") )
		 and IsSpellKnown(55709, true)
		 and GetSpellCooldown(55709) == 0 then
			ni.spell.cast(55709)
			return true
		end
	end,
-----------------------------------
	["Readiness"] = function()
		if ( ni.vars.CD or ni.unit.isboss("target") )
		 and not ni.player.buff(3045)
		 and ni.spell.cd(3045) ~= 0
		 and ni.spell.cd(3045) >= 10
		 and ni.spell.cd(53209) ~= 0
		 and ni.spell.cd(49050) ~= 0
		 and ni.player.buff(61847)
		 and ni.spell.isinstant(23989)
		 and ni.spell.available(23989)
		 and ni.data.darhanger.CDsaverTTD("target")
		 and ni.spell.valid("target", 49052, true, true) then
			ni.spell.cast(23989)
			return true
		end
	end,
-----------------------------------
	["Kill Command"] = function()
		if ( ni.vars.CD or ni.unit.isboss("target") )
		 and ni.unit.exists("playerpet")
		 and ni.spell.isinstant(34026)
		 and ni.spell.available(34026)
		 and ni.spell.valid("target", 49045) then
			ni.spell.cast(34026)
			return true
		end
	end,
-----------------------------------
	["Misdirection"] = function()
		local tank = ni.tanks()
		if ( ni.unit.threat("player") >= 2
		 or ni.vars.CD or ni.unit.isboss("target") )
		 and ni.spell.available(34477) then
		if ni.unit.exists("focus")		 
		 and not UnitIsDeadOrGhost("focus")
		 and ni.spell.valid("focus", 34477, false, true, true) then
			ni.spell.cast(34477, "focus")
			ni.data.darhanger.hunter.LastMD = GetTime()
			return true
		else 
		if not ni.unit.exists("focus")
		 and not ni.unit.exists(tank)
		 and ni.unit.exists("playerpet")
		 and not UnitIsDeadOrGhost("playerpet")
		 and ni.spell.valid("playerpet", 34477, false, true, true) then
			ni.spell.cast(34477, "playerpet")
			ni.data.darhanger.hunter.LastMD = GetTime()
			return true
		else
		if ni.unit.exists(tank)
		 and ni.data.darhanger.youInInstance() 
		 and ni.spell.valid(tank, 34477, false, true, true) then
			ni.spell.cast(34477, tank)
			ni.data.darhanger.hunter.LastMD = GetTime()
			return true
					end
				end
			end
		end
	end,
-----------------------------------
	["Feign Death"] = function()
		local _, enabled = GetSetting("feign");
		if enabled
		 and ni.unit.threat("player", "target") >= 2
		 and ni.unit.exists("focus")
		 and ni.spell.isinstant(5384)
		 and ni.spell.available(5384)
		 and not ni.spell.available(34477)
		 and GetTime() - ni.data.darhanger.hunter.LastMD > 3
		 and ni.spell.available(5384) then
			ni.spell.cast(5384)
			return true
		end
	end,
-----------------------------------
	["Mongoose Bite"] = function()
		if ni.spell.available(53339)
		 and ni.spell.isinstant(48996)
		 and ni.spell.available(48996)
		 and ni.spell.valid("target", 53339, true, true) then
			ni.spell.cast(53339, "target")
			return true
		end
	end,
-----------------------------------
	["Raptor Strike"] = function()
		if ni.spell.available(48996, true)
		 and ni.spell.valid("target", 53339, true, true) then
			ni.spell.cast(48996, "target")
			return true
		end
	end,
-----------------------------------
	["Kill Shot"] = function()
		if (ni.unit.hp("target") <= 20
		 or IsUsableSpell(GetSpellInfo(61006)))
		 and ni.player.buff(61847)
		 and ni.spell.available(61006)
		 and ni.spell.valid("target", 61006, true, true) then
			ni.spell.cast(61006, "target")
			return true
		end
	end,
-----------------------------------
	["Multi-Shot (AoE)"] = function()
		if ActiveEnemies() >= 2
		 and ni.spell.available(49048)
		 and ni.spell.valid("target", 49048, true, true) then
			ni.spell.cast(49048, "target")
			return true
		end
	end,
-----------------------------------
	["Serpent Sting"] = function()
		local serpstring = ni.data.darhanger.hunter.serpstring()
		if (serpstring == nil or (serpstring - GetTime() <= 2))	 
		 and ni.spell.available(49001)
		 and ni.spell.valid("target", 49001, true, true) then
			ni.spell.cast(49001, "target")
			return true
		end
	end,
-----------------------------------
	["Chimera Shot"] = function()
		local serpstring = ni.data.darhanger.hunter.serpstring()
		local viperstring = ni.data.darhanger.hunter.viperstring()
		local scorpstring = ni.data.darhanger.hunter.scorpstring()
		if ni.spell.available(53209)
		 and ( serpstring or viperstring or scorpstring )
		 and ni.spell.valid("target", 53209, true, true) then
			ni.spell.cast(53209, "target")
			return true
		end
	end,
-----------------------------------
	["Aimed Shot"] = function()
		if ni.spell.available(49050)
		 and ni.spell.valid("target", 49050, true, true) then
			ni.spell.cast(49050, "target")
			return true
		end
	end,
-----------------------------------
	["Arcane Shot"] = function()
		if GetCombatRating(25) < 350
		 and ni.spell.available(49045)
		 and ni.spell.valid("target", 49045, true, true) then
			ni.spell.cast(49045, "target")
			return true
		end
	end,
-----------------------------------
	["Steady Shot"] = function()
		if not ni.player.ismoving()
		 and ni.spell.cd(53209)
		 and ni.spell.cd(49050)
		 and ni.spell.available(49052)
		 and ni.spell.valid("target", 49052, true, true) then
			ni.spell.cast(49052, "target")
			return true
		end
	end,
-----------------------------------	
	["Silencing Shot (Interrupt)"] = function()
		local _, enabled = GetSetting("autointerrupt")
		if enabled
		 and ni.spell.shouldinterrupt("target")
		 and ni.spell.available(34490)
		 and GetTime() -  ni.data.darhanger.LastInterrupt > 9
		 and ni.spell.valid("target", 34490, true, true)  then
			ni.spell.castinterrupt("target")
			ni.data.darhanger.LastInterrupt = GetTime()
			return true
		end
	end,
-----------------------------------	
	["Tranquilizing Shot"] = function()
		if ni.unit.bufftype("target", "Enrage|Magic")
		 and ni.spell.available(19801)
		 and ni.spell.valid("target", 19801, true, true) then
			ni.spell.cast(19801, "target")
			return true
		end
	end,
-----------------------------------
	["Window"] = function()
		if not popup_shown then
		 ni.debug.popup("Marksmanship Hunter by DarhangeR for 3.3.5a", 
		 "Welcome to Marksmanship Hunter Profile! Support and more in Discord > https://discord.gg/TEQEJYS.\n\n--Profile Function--\n-For use Volley configure AoE Toggle key.\n-Focus target for use Misdirection & Feign Death.\n-For use Freezing Arrow configure Custom Key Modifier and hold it for use it.\n-For better experience make Pet passive.")		
		popup_shown = true;
		end 
	end,
}

ni.bootstrap.rotation("Mark_DarhangeR", queue, abilities, data, { [1] = "Marksmanship Hunter by DarhangeR", [2] = items });
local target_hp = '';
local target_mana = '';
local player_hp = '';
local player_mana = '';
local rog_combo = 0;
local pal_power = 0;
local Tick = {};
local function pal_power()
	return UnitPower("player",9);
end

print('Hallo to TheRyuzaki Addon');
local playerClass, englishClass = UnitClass("player");
local currentSpec = GetSpecialization()
local currentSpecName = currentSpec and select(2, GetSpecializationInfo(currentSpec)) or "None"
print('Your player is a : ' .. playerClass .. '; ' .. englishClass .. '.');
print("Your current spec:", currentSpecName)

SLASH_TR1 = '/tr'; 
function SlashCmdList.TR(msg, editbox) 
	print("I work!");
end

function A_GetCollDown(name)
	local start, duration, enabled = GetSpellCooldown(name);
	if enabled == 0 then
		return -1;
	elseif ( start > 0 and duration > 0) then
		return (start + duration - GetTime());
	else
		return 0;
	end
end

function A_GetStackBuff(name, target, my)
	if not target then target = 'player'; end
	for i=1,40 do 
		local D, arg2, arg3, count, arg5, arg6, arg7, arg8, arg9, arg10 = UnitBuff(target,i);
		if (D and D == name) then
			if ((arg8 == 'player' and my) or not my) then
				return count;
			end
		end 
	end
	return 0;
end

function A_GetStackDeBuff(name, target, my)
	if not target then target = 'player'; end
	for i=1,40 do 
		local D, arg2, arg3, count, arg5, arg6, arg7, arg8, arg9, arg10 = UnitDebuff(target,i);
		if (D and D == name) then
			if ((arg8 == 'player' and my) or not my) then
				return count;
			end
		end 
	end
	return 0;
end

function A_CastForTarget(name, target)
	if (target == 'player') then TargetUnit('player'); end
	Cooldown = GetSpellCooldown(name);
	if (Cooldown == 0) then
		RunMacroText('/cast '..name);
	end
	if (target == 'player') then TargetLastTarget() end
end

function A_IsCasting(name, target)
	if not target then target = 'player'; end
	local spell, _, _, _, _, endTime = UnitCastingInfo(target)
	local spell2, _, _, _, _, endTime2 = UnitChannelInfo(target)
	if (spell or spell2) then 
		 if (not name or name == spell or name == spell2) then return true; end
	end
	return false;
end
function A_IsBuf(name, target, my)
	if not target then target = 'player'; end
	for i=1,40 do 
		local D, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10 = UnitBuff(target,i);
		if (D and D == name) then
			if ((arg8 == 'player' and my) or not my) then
				return true;
			end
		end 
	end
	return false;
end

function A_IsDeBuf(name, target, my)
	if not target then target = 'player'; end
	for i=1,40 do 
		local D, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10 = UnitDebuff(target,i);
		if (D and D == name) then 
			if ((arg8 == 'player' and my) or not my) then
				return true;
			end
		end 
	end
	return false;
end

function Split(str, sep)
	local li = 0;
	local arr = {};
	for word in string.gmatch(str, '([^'..sep..']+)') do
		arr[li] = word;
		li = li + 1;
	end
	return arr;
end

local i_OnUpdate = 0;
local i_interval = 0.25;
local lastint = 0;
local function OnUpdate(self,elapsed)
    i_OnUpdate = i_OnUpdate + elapsed
    if i_OnUpdate >= i_interval then
		ChekData();
		i_OnUpdate = 0;
		Update();
    end
end
local f = CreateFrame("frame");
f:SetScript("OnUpdate", OnUpdate);

function ChekData() 
	target_hp = UnitHealth('target') / (UnitHealthMax('target') / 100);
	target_mana = UnitMana('target') / (UnitManaMax('target') / 100);
	player_hp = UnitHealth('player') / (UnitHealthMax('player') / 100);
	player_mana = UnitMana('player') / (UnitManaMax('player') / 100);
	rog_combo = GetComboPoints('target');
end
local Cron = {};
local tmp_Cron = {};
function SetTimeout(name, timeout)
	Cron[name] = timeout;
	tmp_Cron[name] = 0;
end
function DelTimeout(name)
	Cron[name] = nil;
	tmp_Cron[name] = nil;
end
function Update()
	local GC = true;
	for i, v in pairs(Cron) do
		if (Cron[i] == nil) then
		else 
			if (Cron[i] == tmp_Cron[i]) then
				Cron[i] = nil;
				tmp_Cron[i] = nil;
				_G[i]();
			else
				GC = false;
			end
			tmp_Cron[i] = tmp_Cron[i] + 0.25;
		end
	end
	for i, v in pairs(Cron) do
		if (Cron[i] == nil) then else
		GC = false;
		end
	end
	if (GC) then
		Cron = {};
		tmp_Cron = {};
	end
end

local MacroID = 0;
function AutoCombo(id)
	SetTimeout('AutoCombo',0.5);
	if not id then else MacroID = id; end
	A_Atack(MacroID);
end
function A_Atack(id)
	if not id then
		print('Error! Not id functions.');
	else 
		if (_G['Attack_'..id]) then
			_G['Attack_'..id]();
		else
			print('Error! Undefind function id:'..id);
		end
	end
end


-- ~~~~ CUSTOM SCRIPTS ~~~~



function Attack_1() -- ФростДК (bulid 3)
	-- ~~~~Макросы~~~~~
	-- 1. "/script A_Atack(1)" - Макрос для атаки вручную о при нажатии на него.
	-- 2. "/script AutoCombo(1)" - Макрос включения автоматического режима боя.
	-- 3. "/script DelTimeout('AutoCombo')" - Макрос для выключение автоматического режима боя.
	-- ~~~~~~~~~~~~~~~~~
	A_CastForTarget('Ледяной столп'); -- В первую очередь если не в КД то юзаем Ледяной столп
	if (target_hp <= 35) then 
		A_CastForTarget('Жнец душ');  -- если у противника мение или ровно 35% здаровья то юзаем Жнец душ
	end	
	if (A_IsDeBuf('Кровавая чума', 'target', true)) then 
		A_CastForTarget('Уничтожение'); -- Если на противнике есть кровавая чума то пытаемся юзать Уничтожение
	else
		A_CastForTarget('Вспышка болезни'); -- Если на противнике нету Кровавой чумы то пытаемся вешать сначало Вспышка болезни
		A_CastForTarget('Нечестивая порча'); -- Если на противнике нету Кровавой чумы и не сработала Вспышка болезни то юзаем Нечестивая порча
		A_CastForTarget('Мор'); -- Если на противнике нету Кровавой чумы и не сработала Вспышка болезни и нету Нечестивая порча то используем МОР
	end
	if (A_IsBuf('Морозная дымка') and A_IsBuf('Машина для убийств') == false) then
		A_CastForTarget('Воющий ветер'); -- если есть морозная дымка и и нету машины для убийств то юзаем воющий ветер
	end
	
	A_CastForTarget('Ледяной удар'); -- Если выше действия пропущены то пытаемся использовать Ледяной удар
	A_CastForTarget('Воющий ветер'); -- Если нету на ледяной удар рун то используем Воющий ветер
	A_CastForTarget('Усиление рунического оружия'); -- Если все руны КД и нету рунической силы то пытаемся использовать Усиление рунического оружия
	A_CastForTarget('Зимний горн'); -- Если мало рунической энергии то используем Зимний горн(+20 к энергии)
	A_CastForTarget('Удар чумы'); -- Если вобще не чо нет то пытаемся использовать руны нечестивости с помощью Удар чумы
end

function Attack_2() -- Ретрик (bulid 5 Глориан)
	-- ~~~~Макросы~~~~~
	-- 1. "/script A_Atack(2)" - Макрос для атаки вручную о при нажатии на него.
	-- 2. "/script AutoCombo(2)" - Макрос включения автоматического режима боя.
	-- 3. "/script DelTimeout('AutoCombo')" - Макрос для выключение автоматического режима боя.
	-- ~~~~~~~~~~~~~~~~~
	if A_IsCasting(nil, 'target') then A_CastForTarget('Кулак Правосудия'); A_CastForTarget('Укор'); end
	if IsMounted() then A_CastForTarget('Кулак Правосудия'); end
	if A_GetStackBuff("Самоотверженный целитель") == 3 then A_CastForTarget('Вспышка света'); end
	A_CastForTarget('Удар воина Света');
	A_CastForTarget('Правосудие');
	A_CastForTarget('Экзорцизм');
	A_CastForTarget('Смертный приговор');
	A_CastForTarget('Гнев карателя');
	if (A_IsBuf('Гнев карателя')) then A_CastForTarget('Молот гнева'); end
	if (target_hp <= 20) then A_CastForTarget('Молот гнева'); end
	if (player_hp <= 80) then A_CastForTarget('Божественная защита'); end
	if (player_hp <= 50) then A_CastForTarget('Божественный щит'); end
	if (player_hp <= 15) then A_CastForTarget('Возложение рук'); end
	if (player_hp <= 60) and pal_power() >= 3 then A_CastForTarget('Торжество'); end
	if not A_IsBuf('Дознание') and pal_power() >= 3 then  A_CastForTarget('Дознание'); end
	if pal_power() >= 3 and A_IsBuf('Дознание') then A_CastForTarget('Вердикт храмовника'); end
	if (A_IsBuf('Дознание')) then A_CastForTarget('Защитник древних королей'); end
end


local A3_ManaFull = true;
function Attack_3() -- БМ Хант (bulid 1) (by sher)
	-- ~~~~Макросы~~~~~
	-- 1. "/script A_Atack(3)" - Макрос для атаки вручную о при нажатии на него.
	-- 2. "/script AutoCombo(3)" - Макрос включения автоматического режима боя.
	-- 3. "/script DelTimeout('AutoCombo')" - Макрос для выключение автоматического режима боя.
	-- ~~~~~~~~~~~~~~~~~
	if (A_IsBuf('Дух ястреба') or A_IsBuf('Дух железного ястреба')) then else A_CastForTarget('Дух железного ястреба'); A_CastForTarget('Дух ястреба'); end
	if (A_IsCasting()) then return true; end
	if (player_mana > 95) then A3_ManaFull = true; end
	A_CastForTarget('Звериный гнев');
	A_CastForTarget('Звериный натиск');
	A_CastForTarget('Команда "Взять!"');
	if (target_hp <= 20) then A_CastForTarget('Убийственный выстрел'); end
	if (A_IsDeBuf('Укус змеи', 'target', true)) then else A_CastForTarget('Укус змеи'); end
	A_CastForTarget('Шквал');
	if (A_IsBuf('Охотничий азарт') and A3_ManaFull) then 
		if (A_IsBuf('Удар зверя', 'pet')) then A_CastForTarget('Чародейский выстрел'); else A_CastForTarget('Залп'); end 
	end
	if ((UnitMana('player') < 10 and A_IsBuf('Охотничий азарт')) or (UnitMana('player') < 30)) then A_CastForTarget('Быстрая стрельба');  A3_ManaFull = false;  end
	if (A3_ManaFull) then
		if ((A_IsBuf('Охотничий азарт') and player_mana >= 10) or player_mana >= 30) then A_CastForTarget('Чародейский выстрел'); end
	else
		A_CastForTarget('Выстрел кобры');
	end
end


function Interval_DefinesDK()
	SetTimeout('Interval_DefinesDK',0.5);
	DefinesDK();
end
function DefinesDK() -- БлудДК (bulid 3)
	-- ~~~~Макросы~~~~~
	-- 1. "/script Interval_DefinesDK()" - Макрос для атаки вручную о при нажатии на него.
	-- ~~~~~~~~~~~~~~~~~
	if (player_hp <= 90) then 
		A_CastForTarget('Захват рун'); 
	end
	if (player_hp <= 85) then 
		A_CastForTarget('Костяной щит');
	end
	if (player_hp <= 50) then 
		A_CastForTarget('Воскрешение мертвых'); 
		A_CastForTarget('Смертельный союз'); 
		A_CastForTarget('Кровь вампира');
	end
	if (player_hp <= 30) then 
		A_CastForTarget('Незыблемость льда'); 
		A_CastForTarget('Антимагический панцирь'); 
	end
	if (A_IsBuf('Зимний горн')) then
		A_CastForTarget('Зимний горн'); 
	end
end

	-- counts the number of party members having a significant health loss
		local unitsBelow70 = 0
		local unitsBelow50 = 0
		local unitsBelow30 = 0
		for unit,index in pairs(jps.RaidStatus) do
			--Only check the relevant units
			if (index["inrange"] == true) then
				local thisHP = jps.hp(unit)
				-- Number of people below x%
				if thisHP < 0.3 then unitsBelow30 = unitsBelow30 + 1 end
				if thisHP < 0.5 then unitsBelow50 = unitsBelow50 + 1 end
				if thisHP < 0.7 then unitsBelow70 = unitsBelow70 + 1 end
			end
	end
	
-- aoe heal
		{ "Circle of Healing", unitsBelow70  > 3, Priest_Target },
		{ "Circle of Healing", unitsBelow70  > 3, "player" },
		{ "Prayer of Healing", unitsBelow50  > 3, "player" },
		{ "Prayer of Healing", unitsBelow50  > 3, Priest_Target },	

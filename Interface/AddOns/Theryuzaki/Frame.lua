local target_hp = '';
local target_mana = '';
local player_hp = '';
local player_mana = '';
local rog_combo = 0;
local Tick = {};
local holyPower = UnitPower('player',9);
-- проверка -- /script print(UnitPower('player',9))

print('Hallo to TheRyuzaki Addon');

SLASH_TR1 = '/tr'; 
function SlashCmdList.TR(msg, editbox) 
	print("I work!");
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
	local spell, _, _, _, _, endTime = UnitCastingInfo("target")
	if spell then 
		 if (not name or name == spell) then return true; end
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
	holyPower = UnitPower('player',9);
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



function Attack_1() -- ФростДК (bulid 1)
	-- ~~~~Макросы~~~~~
	-- 1. "/script A_Atack(1)" - Макрос для атаки вручную о при нажатии на него.
	-- 2. "/script AutoCombo(1)" - Макрос включения автоматического режима боя.
	-- 3. "/script DelTimeout('AutoCombo')" - Макрос для выключение автоматического режима боя.
	-- ~~~~~~~~~~~~~~~~~
	if (target_hp <= 35) then A_CastForTarget('Жнец душ'); end -- Жнец душ если хп у противника меньше или ровно 35%
	if (A_IsBuf('Машина для убийств')) then A_CastForTarget('Уничтожение'); end -- Уничтожение если баф машина для убийств
	if (A_IsBuf('Машина для убийств') and player_mana >= 20) then A_CastForTarget('Ледяной удар'); end -- Ледяной удар если баф машина для убийств и маны 20+
	A_CastForTarget('Вспышка болезни'); -- Вспышка болезни по кд
	A_CastForTarget('Усиление рунического оружия'); -- Усиление рунического оружия по кд
	A_CastForTarget('Ледяной столп'); -- Ледяной столп по кд
	if (player_mana >= 80) then A_CastForTarget('Ледяной удар'); end -- Ледяной удар если маны 20+
	A_CastForTarget('Воющий ветер');
	if (player_mana >= 20) then A_CastForTarget('Ледяной удар'); end -- Ледяной удар если маны 20+
	A_CastForTarget('Зимний горн');
	A_CastForTarget('Удар чумы');
	A_CastForTarget('Вытягивание чумы');
end

function Attack_2() -- Ретрик (bulid 1 Глориан)
	-- ~~~~Макросы~~~~~
	-- 1. "/script A_Atack(2)" - Макрос для атаки вручную о при нажатии на него.
	-- 2. "/script AutoCombo(2)" - Макрос включения автоматического режима боя.
	-- 3. "/script DelTimeout('AutoCombo')" - Макрос для выключение автоматического режима боя.
	-- ~~~~~~~~~~~~~~~~~
	A_CastForTarget('Удар воина Света');
	A_CastForTarget('Правосудие');
	A_CastForTarget('Экзорцизм');
	A_CastForTarget('Божественная призма');
	A_CastForTarget('Защитник древних королей');
	A_CastForTarget('Укор');
	A_CastForTarget('Гнев Карателя');
	if (A_IsBuf('Гнев Карателя')) then A_CastForTarget('Молот Гнева'); end
	if (target_hp <= 20) then A_CastForTarget('Молот Гнева'); end
	if (holyPower => 3) then A_CastForTarget('Вердикт храмовника'); end
	end


function Attack_3() -- БМ Хант (bulid 1) (by sher)
	-- ~~~~Макросы~~~~~
	-- 1. "/script A_Atack(3)" - Макрос для атаки вручную о при нажатии на него.
	-- 2. "/script AutoCombo(3)" - Макрос включения автоматического режима боя.
	-- 3. "/script DelTimeout('AutoCombo')" - Макрос для выключение автоматического режима боя.
	-- ~~~~~~~~~~~~~~~~~
	A_CastForTarget('Звериный гнев');
	A_CastForTarget('Команда "Взять!"');
	if (A_IsDeBuf('Укус змеи', 'target', true)) then else A_CastForTarget('Укус змеи'); end
	if (A_IsBuf('Охотничий азарт')) then 
		if (A_IsBuf('Удар зверя', 'pet')) then A_CastForTarget('Чародейский выстрел'); else A_CastForTarget('Залп'); end 
	end
end

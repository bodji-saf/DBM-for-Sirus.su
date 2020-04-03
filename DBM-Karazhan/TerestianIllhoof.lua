local mod	= DBM:NewMod("TerestianIllhoof", "DBM-Karazhan")
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 183 $"):sub(12, -3))
mod:SetCreatureID(15688)

mod:SetBossHealthInfo(
	15688, L.name
)

--mod:RegisterCombat("yell", L.DBM_TI_YELL_PULL)
mod:RegisterCombat("combat", 15688)
--17229--imp, for future use

mod:RegisterEvents(
	"SPELL_AURA_APPLIED",
	"SPELL_CAST_START",
    "SPELL_CAST_SUCCESS",
    "SPELL_CAST_FAILED"
)

-- local warningWeakened	= mod:NewTargetAnnounce(30065, 2)
-- local warningImpSoon	= mod:NewSoonAnnounce(30066, 2)
-- local warningImp		= mod:NewSpellAnnounce(30066, 3)
-- local warningSacSoon	= mod:NewSoonAnnounce(30115, 3)
-- local warningSacrifice	= mod:NewTargetAnnounce(30115, 4)
--
-- local specWarnSacrifice	= mod:NewSpecialWarningYou(30115)
--
-- local timerWeakened		= mod:NewBuffActiveTimer(31, 30065)
-- local timerSacrifice	= mod:NewTargetTimer(30, 30115)
-- local timerSacrificeCD	= mod:NewNextTimer(43, 30115)

local warningHandCast			= mod:NewCastAnnounce(305345, 3)
local timerHandCD				= mod:NewCDTimer(15, 305345)
local timerMarkCD			    = mod:NewCDTimer(33, 305351)
local WarnMark		            = mod:NewTargetAnnounce(305351, 3)
local specWarnMark			    = mod:NewSpecialWarningYou(305351)
local specWarnSeed	            = mod:NewSpecialWarningSpell(305360, mod:IsTank())
local specWarnDart		        = mod:NewSpecialWarningStack(305367, nil, 7)

local berserkTimer		        = mod:NewBerserkTimer(600)

local tolik = true

mod:AddBoolOption("HealthFrame", true)

-- function mod:OnCombatStart(delay)
-- 	berserkTimer:Start(-delay)
-- end
--
-- function mod:SPELL_AURA_APPLIED(args)
-- 	if args:IsSpellID(30115) then
-- 		DBM.BossHealth:AddBoss(17248, L.DChains)
-- 		warningSacrifice:Show(args.destName)
-- 		timerSacrifice:Start(args.destName)
-- 		timerSacrificeCD:Start()
-- 		warningSacSoon:Cancel()
-- 		warningSacSoon:Schedule(38)
-- 		if args:IsPlayer() then
-- 			specWarnSacrifice:Show()
-- 		end
-- 	elseif args:IsSpellID(30065) then
-- 		warningWeakened:Show(args.destName)
-- 		timerWeakened:Start()
-- 		warningImpSoon:Schedule(26)
-- 	end
-- end
--
-- function mod:SPELL_AURA_REMOVED(args)
-- 	if args:IsSpellID(30115) then
-- 		timerSacrifice:Cancel(args.destName)
-- 	end
-- end
--
-- function mod:SPELL_CAST_SUCCESS(args)
-- 	if args:IsSpellID(30066) then
-- 		warningImpSoon:Cancel()
-- 		warningImp:Show()
-- 		DBM.BossHealth:AddBoss(17229, L.Kilrek)
-- 	end
-- end
--
-- function mod:UNIT_DIED(args)
-- 	local cid = self:GetCIDFromGUID(args.destGUID)
-- 	if cid == 17229 then--Kil'rek
-- 		DBM.BossHealth:RemoveBoss(cid)
-- 	elseif cid == 17248 then--Demon Chains
-- 		DBM.BossHealth:RemoveBoss(cid)
-- 	end
-- end
function mod:resetTolik()
    tolik = true
end

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 15688, "Terestian Illhoof")
    if mod:IsDifficulty("normal10") then
    elseif mod:IsDifficulty("heroic10") then
        tolik = true
        timerHandCD:Start()
        timerMarkCD:Start()
    end
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 15688, "Terestian Illhoof", wipe)
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(305345) then
        if args:IsPlayer() then
            self:PlaySound("fireinthe")           -- CS 1.6 (couter_terorrists_voice)
        end
		warningHandCast:Show()
		timerHandCD:Start()
    end
end

function mod:SPELL_AURA_APPLIED(args)
    if args:IsSpellID(305351) then
        if args.sourceName == L.name then
            timerMarkCD:Start()
            WarnMark:Show(args.destName)
        elseif tolik then
            tolik = false
            self:PlaySound("tolik")              -- Толик-Еболик, первый день на работе.
            self:ScheduleMethod(2, "resetTolik")
        end
		if args:IsPlayer() then
			specWarnMark:Show()
		end
    elseif args:IsSpellID(305367) then
		if args:IsPlayer() and ((args.amount or 1) >= 7) then
            specWarnDart:Show(args.amount)
		end
    elseif args:IsSpellID(305360) then
        if args:IsPlayer() then
            specWarnSeed:Show()
        end
	end
end

function mod:SPELL_CAST_FAILED(args)
    if args.sourceName == L.name then
        self:PlaySound("noice")                  -- Slurp.Klick.Noice
    end
end

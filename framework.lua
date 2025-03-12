local Effects = {
    EFFECT_SPSUMMON_SELF_FROMHAND = 0
}

local Events = {
    EVENT_IGNITION = 0
}
local Count = {
    SOFT_ONCEPER_TURN = 0,
    HARD_ONCEPER_TURN = 1
}
Call = {}

function Call.Condition(str)
end

function Call.Target(str)
    local lists = {
        ["special-summon"] = function(e,tp,eg,ep,ev,re,r,rp,chk)
            if chk==0 then
                return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
            end
            Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
        end
    }
    local target = lists[str]
    return target
end

function Call.Operation(str)
    local lists = {
        ["special-summon"] = function(e,tp,eg,ep,ev,re,r,rp)
            local c=e:GetHandler()
            if c:IsRelateToEffect(e) then
                Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
            end
        end
    }
    local op = lists[str]
    return op
end

Create = {
    count = 0,
    PlainEffect = function(self, card, id, event, effect, countlimit, condition)
        local eff = Effect.CreateEffect(card)
        eff:SetDescription(aux.Stringid(id, self.count))
        self.count = self.count + 1
        if event == Events.EVENT_IGNITION then
            eff:SetType(EFFECT_TYPE_IGNITION)
        end 
        if effect == Effects.EFFECT_SPSUMMON_SELF_FROMHAND then
            eff:SetCategory(CATEGORY_SPECIAL_SUMMON)
            eff:SetRange(LOCATION_HAND)
            eff:SetTarget(Call.Target("special-summon"))
            eff:SetOperation(Call.Operation("special-summon"))
        end
        if countlimit then
            if countlimit == Count.SOFT_ONCEPER_TURN then
                eff:SetCountLimit(1)
            elseif countlimit == Count.HARD_ONCEPER_TURN then
                eff:SetCountLimit(1, {id, self.count})
            end
        end
        card:RegisterEffect(eff)
        return self.count
    end
}

local s, id = GetID()
function s.initial_effect(c)
    Create:PlainEffect(c, id, Events.EVENT_IGNITION, Effects.EFFECT_SPSUMMON_SELF_FROMHAND)
end

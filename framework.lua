oncreate = {
    card_effect = function(self, card, datas)
        datas = datas or {}
        local eff = Effect.CreateEffect(card)
        if datas.category then eff:SetCategory(datas.category) end
        if datas.efftype then eff:SetType(datas.efftype) end
        if datas.range then eff:SetRange(datas.range) end
        if datas.opt then eff:SetCountLimit(datas.opt) end
        if datas.target then eff:SetTarget(datas.target) end
        if datas.operation then eff:SetOperation(datas.operation) end
        card:RegisterEffect(eff)
    end
}
function sp_target(access, check, opinfo)
    local dataSets = {
        ["selfsp-target"] = function(e,tp,eg,ep,ev,re,r,rp,chk)
            if chk == 0 then
                return Duel.GetLocationCount(tp,LOCATION_MZONE) > 0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
            end
            Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
        end,
        ["sp-target"] = function(e,tp,eg,ep,ev,re,r,rp,chk)
            if chk == 0 then
                for _, v in ipairs(check or {}) do
                    if v then return true end
                end
                return false
            end
            if opinfo then
                for _, info in ipairs(opinfo) do
                    Duel.SetOperationInfo(0, table.unpack(info))
                end
            end
        end
    }
    return dataSets[access] or function() end
end

function sp_operation(access)
    local dataSets = {
        ["selfsp-operation"] = function(e,tp,eg,ep,ev,re,r,rp,chk)
            local c=e:GetHandler()
            if c:IsRelateToEffect(e) then
                Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
            end
        end
    }
    local res = dataSets[access]
    return res
end

put = {
    TOHAND = 0,
    TOGRAVE = 1,
    TODECK = 2,
    REMOVE = 3
}

onCreate={
    CardEffect=function(self,card,datasets) 
        local effectMethods={
            description="SetDescription",
            category="SetCategory",
            type="SetType",
            range="SetRange",
            count="SetCountLimit",
            condition="SetCondition",
            target="SetTarget",
            operation="SetOperation",
        }
        for _,datas in ipairs(datasets) do
            local eff=Effect.CreateEffect(card)
            for key,method in pairs(effectMethods) do
                if datas[key] then
                    eff[method](eff,datas[key])
                end
            end
            card:RegisterEffect(eff)
        end
    end
}
condition={
    check=function(self,check)
        return function(e,tp,eg,ep,ev,re,r,rp)
            for _,v in pairs(check) do
                if type(v) == "function" then
                    if v(e,tp,eg,ep,ev,re,r,rp) then return true end
                elseif v then
                    return true
                end
            end
            return false
        end
    end,
}
target={
    check=function(self, check, opinfo)
        return function(e,tp,eg,ep,ev,re,r,rp,chk)
            if chk == 0 then
                for _, v in pairs(check) do
                    if type(v) == "function" then
                        if v(e,tp,eg,ep,ev,re,r,rp) then return true end
                    elseif v then
                        return true
                    end
                end
                return false
            end
            if opinfo and type(opinfo) == "table" then
                for _, v in ipairs(opinfo) do
                    local info = type(v) == "function" and v(e,tp,eg,ep,ev,re,r,rp) or v
                    if type(info) == "table" then
                        Duel.SetOperationInfo(0, table.unpack(info))
                    end
                end
            end
        end
    end
}
--special summon--
selfsp={
    --operation--
    activation=function(self, next, nextbreak)
        return function(e,tp,eg,ep,ev,re,r,rp)
            local c=e:GetHandler()
            if c:IsRelateToEffect(e) then
                local res=Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
                if res>0 then
                    if nextbreak == true then Duel.BreakEffect() end
                    if next then next(e,tp,eg,ep,ev,re,r,rp) end
                end
            end
        end
    end
}
--search--
search={
    activation=function(self, query, types, y, o, min, max, next, nextbreak)
        return function(e,tp,eg,ep,ev,re,r,rp)
            dynamic_search(query, types, y, o, min, max)(e, tp, eg, ep, ev, re, r, rp)
            if nextbreak == true then Duel.BreakEffect() end
            if next then next(e,tp,eg,ep,ev,re,r,rp) end
        end
    end
}
--common effects--
function dynamic_search(query, types, y, o, min, max)
    return function(e, tp, eg, ep, ev, re, r, rp)
        local maps = {
            [put.TOHAND] = HINTMSG_ATOHAND,
            [put.TOGRAVE] = HINTMSG_TOGRAVE,
            [put.TODECK] = HINTMSG_TODECK,
            [put.REMOVE] = HINTMSG_REMOVE
        }
        if type(types) ~= "table" then
            types = {types} 
        end
        local getMSG = nil
        for _, v in ipairs(types) do
            if maps[v] then
                getMSG = maps[v]
                break
            end
        end
        Duel.Hint(HINT_SELECTMSG,tp,getMSG)
        local g=Duel.SelectMatchingCard(tp,query,tp,y,o,min,max,nil)
        if #g>0 then
            local action = types[1]
            if action==put.TOHAND then
                Duel.SendtoHand(g,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,g)
            elseif action==put.TOGRAVE then
                Duel.SendtoGrave(g,REASON_EFFECT)
            elseif action==put.TODECK then
                Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
            elseif action==put.REMOVE then
                Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
            end
        end
    end
end

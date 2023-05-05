-- ================================================================================
-- some functions for table operating
-- ================================================================================


local TableModule = {}

function TableModule.Choices(t:table, num:number)
    t = table.clone(t)
    num = num or 1
    if t[1] then  -- indicates that 't' is a number table
        if #t <= num then return t end

        local results = {}
        for i = 1, num do
            results[i] = t[math.random(1, #t)]
            table.remove(t, i)
        end

        return results
    else  -- 't' is a key-value type table
        local totalWeight = 0
        for key, weight in pairs(t) do
            totalWeight = totalWeight + weight
        end
    
        local results = {}
        for i = 1, num do
            local randomValue = math.random(0, totalWeight)
            local weightSum = 0
            for key, weight in pairs(t) do
                weightSum = weightSum + weight
                if randomValue <= weightSum then
                    table.insert(results, key)
                    totalWeight = totalWeight - weight
                    t[key] = nil
                    break
                end
            end
        end

        return results
    end
end


return TableModule

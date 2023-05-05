-- ================================================================================
-- pet cls --> server side
-- ================================================================================

---- modules ----

---- main ----
local PetServerClass = {}
PetServerClass.__index = PetServerClass

function PetServerClass.new(player)
    local petIns = setmetatable({}, PetServerClass)
    petIns.owner = player
    petIns.skillId = 10001
    petIns.skillCd = 10
    return petIns
end


function PetServerClass:StartFight()
    
end

function PetServerClass:UseSkill()
    
end

function PetServerClass:DestroyIns()
    for key, value in pairs(self) do
        self[key] = nil
    end
    self[{}] = nil
end



return PetServerClass

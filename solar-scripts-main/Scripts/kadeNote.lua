function opponentNoteHit(id, direction, noteType, isSustainNote)
if version > '0.6' then
runHaxeCode([[game.opponentStrums.members[]]..direction..[[].playAnim('static', true)]]);
end
end

function goodNoteHit(id, direction, noteType, isSustainNote)
if version > '0.6' and getProperty('cpuControlled') == true then
runHaxeCode([[game.playerStrums.members[]]..direction..[[].playAnim('static', true)]]);
end
end
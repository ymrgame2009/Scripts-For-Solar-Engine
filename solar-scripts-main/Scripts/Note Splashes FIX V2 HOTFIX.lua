--script by Mr YMR (@ymrgame2009)

function opponentNoteHit(id, direction, noteType, isSustainNote)
end

function goodNoteHit(id, direction, noteType, isSustainNote)
    if not isSustainNote then
        runTimer('fixSplashOrder', 0.01)
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'fixSplashOrder' then
        local splashCount = getProperty('grpNoteSplashes.length')
        if splashCount > 0 then
            setObjectOrder('grpNoteSplashes', getObjectOrder('strumLineNotes') + 20)
        end
    end
end
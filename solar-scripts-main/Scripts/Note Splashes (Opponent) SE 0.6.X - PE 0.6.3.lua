--script by Mr YMR (@ymrgame2009)
--SE 0.6.X | PE 0.6.3

function opponentNoteHit(id, noteData, noteType, isSustainNote)
    if not isSustainNote then
        runTimer('fixSplashOrder', 0.01)
        local noteSplashDisabled = false
        pcall(function()
            noteSplashDisabled = getPropertyFromGroup('notes', id, 'noteSplashData.disabled')
        end)
        
        if not noteSplashDisabled then

            runHaxeCode([[
                var noteId = ]]..id..[[;
                var noteData = ]]..noteData..[[;
                var note = game.notes.members[noteId];
                var strum = game.opponentStrums.members[noteData];
                
                if (strum != null && note != null) {

                    game.spawnNoteSplash(strum.x, strum.y, noteData, note);
                    

                    if(game.grpNoteSplashes.length > 0) {
                        var splash = game.grpNoteSplashes.members[game.grpNoteSplashes.length - 1];
                        if(splash != null && splash.rgbShader != null && strum.rgbShader != null) {
                            splash.rgbShader.parent.r = strum.rgbShader.parent.r;
                            splash.rgbShader.parent.g = strum.rgbShader.parent.g;
                            splash.rgbShader.parent.b = strum.rgbShader.parent.b;
                        }
                    }
                }
            ]])
        end
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
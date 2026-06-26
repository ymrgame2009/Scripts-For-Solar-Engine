local dadHasMiss = {
    singLEFTmiss = false,
    singDOWNmiss = false,
    singUPmiss = false,
    singRIGHTmiss = false
}
local function dadMissCheck()
    for n, anim in pairs(getProperty('dad.animationsArray')) do
        if dadHasMiss[anim.anim] ~= nil then
            dadHasMiss[anim.anim] = true
        end
    end
end


local notes = {}
local nextNote = 0
function onCountdownStarted()
    for n = 0, getProperty('unspawnNotes.length')-1 do
        notes[n] = {
            mustPress = getPropertyFromGroup('unspawnNotes', n, 'mustPress'),
            noAnimation = getPropertyFromGroup('unspawnNotes', n, 'noAnimation'),
            noMissAnimation = getPropertyFromGroup('unspawnNotes', n, 'noMissAnimation')
        }
        
        setPropertyFromGroup('unspawnNotes', n, 'noAnimation', true)
        setPropertyFromGroup('unspawnNotes', n, 'noMissAnimation', true)
        setPropertyFromGroup('unspawnNotes', n, 'mustPress', not getPropertyFromGroup('unspawnNotes', n, 'mustPress'))
    end

    createInstance('iconP1L', 'objects.HealthIcon', {getProperty('dad.healthIcon'), true})
    callMethod('iconP1L.set_camera', {instanceArg('camHUD')})
    addInstance('iconP1L')
    setProperty('iconP1L.x', getProperty('iconP2.x'))
    setProperty('iconP1L.y', getProperty('iconP2.y'))
    setProperty('iconP1L.flipX', true)
    setObjectOrder('iconP1L', getObjectOrder('uiGroup')+getObjectOrder('iconP2', 'uiGroup'))

    createInstance('iconP2L', 'objects.HealthIcon', {getProperty('boyfriend.healthIcon'), false})
    callMethod('iconP2L.set_camera', {instanceArg('camHUD')})
    addInstance('iconP2L')

    setProperty('iconP2L.x', getProperty('iconP1.x'))
    setProperty('iconP2L.y', getProperty('iconP1.y'))
    setProperty('iconP2L.flipX', true)
    setObjectOrder('iconP2L', getObjectOrder('uiGroup')+getObjectOrder('iconP1', 'uiGroup'))
end

function onCountdownTick(counter)
    if counter == 2 then
        local pos = {}
        for n = 0, 7 do
            pos[n] = getPropertyFromGroup('strumLineNotes', n+(n > 3 and -4 or 4), 'x')
        end
        for n = 0, 7 do
            noteTweenX('note'..n, n, pos[n], -getSongPosition()/1000, 'quadInOut')
        end
        doTweenX('healthBarSqueeze1', 'healthBar.scale', 1, (-getSongPosition()/1000)/2, 'quadIn')

        dadMissCheck()
    end
end

function goodNoteHit(id, dir, type, sustain)
    if notes[nextNote].noAnimation == false then
        cancelTimer('resetDadColour')
        setProperty('dadGroup.color', getColorFromHex('ffffff'))
        triggerEvent('Play Animation', getProperty('singAnimations')[dir+1], 'Dad')
    end

    nextNote = nextNote + 1
end

function noteMiss(id, dir, type, sustain)
    local anim = getProperty('singAnimations')[dir+1]
    if notes[nextNote].noMissAnimation == false then
        triggerEvent('Play Animation', anim..(dadHasMiss[anim..'miss'] == true and 'miss' or ''), 'Dad')
        cancelTimer('resetDadColour')
        if dadHasMiss[anim..'miss'] == false then
            setProperty('dadGroup.color', getColorFromHex('565694'))
            runTimer('resetDadColour', getProperty('dadGroup.singDuration'))
        end
    end

    nextNote = nextNote + 1
end

function opponentNoteHit(id, dir, type, sustain)
    if notes[nextNote].noAnimation == false then
        triggerEvent('Play Animation', getProperty('singAnimations')[dir+1], 'BF')
    end

    nextNote = nextNote + 1
end

function onTweenCompleted(tag)
    if tag == 'healthBarSqueeze1' then
        setProperty('healthBar.flipX', true)
        setHealthBarColors(callMethodFromClass('StringTools', 'hex', {getProperty('healthBar.rightBar.color')}):sub(3, -1), callMethodFromClass('StringTools', 'hex', {getProperty('healthBar.leftBar.color')}):sub(3, -1))
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'resetDadColour' then
        setProperty('dad.color', getColorFromHex('FFFFFF'))
    end
end

function onEvent(name, val1, val2)
    if name == 'Change Character' then
        if val1 == 'Dad' then
            callMethod('iconP1L.changeIcon', {getProperty('dad.healthIcon')})
            dadHasMiss = {
                singLEFTmiss = false,
                singDOWNmiss = false,
                singUPmiss = false,
                singRIGHTmiss = false
            }
            dadMissCheck()
        elseif val1 == 'BF' then
            callMethod('iconP2L.changeIcon', {getProperty('boyfriend.healthIcon')})
        end
        local leftSide = getProperty('boyfriend.healthColorArray')
        local rightSide = getProperty('dad.healthColorArray')
        leftSide = string.format('%02X%02X%02X', leftSide[1], leftSide[2], leftSide[3])
        rightSide = string.format('%02X%02X%02X', rightSide[1], rightSide[2], rightSide[3])
        setHealthBarColors(leftSide, rightSide)
    end
end

function onUpdatePost(elapsed)
    setProperty('iconP1L.x', getProperty('iconP2.x'))
    setProperty('iconP1L.y', getProperty('iconP2.y'))
    setProperty('iconP1L.scale.x', getProperty('iconP2.scale.x'))
    setProperty('iconP1L.scale.y', getProperty('iconP2.scale.y'))
    setProperty('iconP1L.animation.curAnim.curFrame', getProperty('iconP1.animation.curAnim.curFrame'))
    setProperty('iconP1L.offset.x', (1-getHealth())*591)
    setProperty('iconP2.visible', false)

    setProperty('iconP2L.x', getProperty('iconP1.x'))
    setProperty('iconP2L.y', getProperty('iconP1.y'))
    setProperty('iconP2L.scale.x', getProperty('iconP1.scale.x'))
    setProperty('iconP2L.scale.y', getProperty('iconP1.scale.y'))
    setProperty('iconP2L.animation.curAnim.curFrame', getProperty('iconP2.animation.curAnim.curFrame'))
    setProperty('iconP2L.offset.x', (1-getHealth())*591)
    setProperty('iconP1.visible', false)
end
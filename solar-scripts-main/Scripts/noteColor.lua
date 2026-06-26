local noteTypeGroup = {'', 'Alt Animation'}

charTagOpp = 'dad'
charTagPly = 'boyfriend'

function to_hex(rgb)
    return string.format("%02x%02x%02x", math.floor(rgb[1]), math.floor(rgb[2]), math.floor(rgb[3]))
end

function getLuminance(rgb)
    return (0.299 * rgb[1]) + (0.587 * rgb[2]) + (0.114 * rgb[3])
end

function isVeryBright(rgb)
    return getLuminance(rgb) > 220
end

function getIconColorForNoteRGB(tag, color)
    local rgb
    if tag == 'dad' then
        rgb = getProperty('dad.healthColorArray')
    elseif tag == 'gf' then
        rgb = getProperty('gf.healthColorArray')
    elseif tag == 'boyfriend' then
        rgb = getProperty('boyfriend.healthColorArray')
    else
        return {255,255,255}
    end

    if color == 'green' then
        for i = 1, 3 do rgb[i] = math.min(rgb[i] * 2, 255) end
    elseif color == 'blue' then
        for i = 1, 3 do rgb[i] = math.max(rgb[i] * 0.5, 0) end
    end
    return rgb
end

function onSpawnNote(id, noteData, noteType, isSustainNote)
    if noteData >= 0 and noteData <= 3 then
        local tag = 'dad'
        if getPropertyFromGroup('notes', id, 'mustPress') then
            tag = 'boyfriend'
        end
        local rgb_red   = getIconColorForNoteRGB(tag, 'red')
        local rgb_blue  = getIconColorForNoteRGB(tag, 'blue')
        local g_rgb = isVeryBright(rgb_red) and {0,0,0} or {255,255,255}

        setPropertyFromGroup('notes', id, 'rgbShader.r', getColorFromHex(to_hex(rgb_red)))
        setPropertyFromGroup('notes', id, 'rgbShader.g', getColorFromHex(to_hex(g_rgb)))
        setPropertyFromGroup('notes', id, 'rgbShader.b', getColorFromHex(to_hex(rgb_blue)))

        if getPropertyFromGroup('notes', id, 'mustPress') then
            setPropertyFromGroup('notes', id, 'noteSplashData.r', getColorFromHex(to_hex(rgb_red)))
            setPropertyFromGroup('notes', id, 'noteSplashData.g', getColorFromHex(to_hex(g_rgb)))
            setPropertyFromGroup('notes', id, 'noteSplashData.b', getColorFromHex(to_hex(rgb_blue)))
        end

        if getPropertyFromGroup('notes', id, 'gfNote') then
            local gfRed = getIconColorForNoteRGB('gf', 'red')
            local gfBlue = getIconColorForNoteRGB('gf', 'blue')
            local g_gf = isVeryBright(gfRed) and {0,0,0} or {255,255,255}

            setPropertyFromGroup('notes', id, 'rgbShader.r', getColorFromHex(to_hex(gfRed)))
            setPropertyFromGroup('notes', id, 'rgbShader.g', getColorFromHex(to_hex(g_gf)))
            setPropertyFromGroup('notes', id, 'rgbShader.b', getColorFromHex(to_hex(gfBlue)))

            if getPropertyFromGroup('notes', id, 'mustPress') then
                setPropertyFromGroup('notes', id, 'noteSplashData.r', getColorFromHex(to_hex(gfRed)))
                setPropertyFromGroup('notes', id, 'noteSplashData.g', getColorFromHex(to_hex(g_gf)))
                setPropertyFromGroup('notes', id, 'noteSplashData.b', getColorFromHex(to_hex(gfBlue)))
            end
        end
    end
end

function opponentNoteHit(id, noteData, noteType, isSustainNote)
    if noteData >= 0 and noteData <= 3 then
        local tag = (noteType == 'GF Sing') and 'gf' or 'dad'
        charTagOpp = tag

        local rgb_red   = getIconColorForNoteRGB(tag, 'red')
        local rgb_blue  = getIconColorForNoteRGB(tag, 'blue')
        local g_rgb = isVeryBright(rgb_red) and {0,0,0} or {255, 255, 255}

        setPropertyFromGroup('opponentStrums', noteData, 'rgbShader.r', getColorFromHex(to_hex(rgb_red)))
        setPropertyFromGroup('opponentStrums', noteData, 'rgbShader.g', getColorFromHex(to_hex(g_rgb)))
        setPropertyFromGroup('opponentStrums', noteData, 'rgbShader.b', getColorFromHex(to_hex(rgb_blue)))
    end
end

function goodNoteHit(id, noteData, noteType, isSustainNote)
    if noteData >= 0 and noteData <= 3 then
        local tag = (noteType == 'GF Sing') and 'gf' or 'boyfriend'
        charTagPly = tag

        local rgb_red   = getIconColorForNoteRGB(tag, 'red')
        local rgb_blue  = getIconColorForNoteRGB(tag, 'blue')
        local g_rgb = isVeryBright(rgb_red) and {0,0,0} or {255, 255, 255}

        setPropertyFromGroup('playerStrums', noteData, 'rgbShader.r', getColorFromHex(to_hex(rgb_red)))
        setPropertyFromGroup('playerStrums', noteData, 'rgbShader.g', getColorFromHex(to_hex(g_rgb)))
        setPropertyFromGroup('playerStrums', noteData, 'rgbShader.b', getColorFromHex(to_hex(rgb_blue)))
    end
end

function onUpdatePost(elapsed)
    local rgb_baseOpp  = getIconColorForNoteRGB(charTagOpp, 'green')
    local rgb_basePly  = getIconColorForNoteRGB(charTagPly, 'green')
    local colorOff  = getColorFromHex('FFFFFF')

    for i = 0, 3 do
        local animOpp = getPropertyFromGroup('opponentStrums', i, 'animation.curAnim.name')
        local animPly = getPropertyFromGroup('playerStrums', i, 'animation.curAnim.name')

        setPropertyFromGroup('opponentStrums', i, 'color', (animOpp == 'static' or animOpp == 'pressed') and getColorFromHex(to_hex(rgb_baseOpp)) or colorOff)
        setPropertyFromGroup('playerStrums',   i, 'color', (animPly == 'static' or animPly == 'pressed') and getColorFromHex(to_hex(rgb_basePly)) or colorOff)
    end
end


function onEvent(name, v1, v2)
    if name == 'Change Character' then
        if v1 == '0' then charTagOpp = v2 end
        if v1 == '1' then charTagPly = v2 end

        for i = 0, getProperty('notes.length')-1 do
            local mustPress = getPropertyFromGroup('notes', i, 'mustPress')
            local noteType = getPropertyFromGroup('notes', i, 'noteType')
            local tag = mustPress and 'boyfriend' or 'dad'
            if getPropertyFromGroup('notes', id, 'gfNote') then tag = 'gf' end

            local rgb_red  = getIconColorForNoteRGB(tag, 'red')
            local rgb_blue = getIconColorForNoteRGB(tag, 'blue')
            local g_rgb = isVeryBright(rgb_red) and {0,0,0} or {255, 255, 255}

            setPropertyFromGroup('notes', i, 'rgbShader.r', getColorFromHex(to_hex(rgb_red)))
            setPropertyFromGroup('notes', i, 'rgbShader.g', getColorFromHex(to_hex(g_rgb)))
            setPropertyFromGroup('notes', i, 'rgbShader.b', getColorFromHex(to_hex(rgb_blue)))

            if mustPress then
                setPropertyFromGroup('notes', i, 'noteSplashData.r', getColorFromHex(to_hex(rgb_red)))
                setPropertyFromGroup('notes', i, 'noteSplashData.g', getColorFromHex(to_hex(g_rgb)))
                setPropertyFromGroup('notes', i, 'noteSplashData.b', getColorFromHex(to_hex(rgb_blue)))
            end
        end

        for i = 0, 3 do
            local rgbOppRed   = getIconColorForNoteRGB(charTagOpp, 'red')
            local rgbOppBlue  = getIconColorForNoteRGB(charTagOpp, 'blue')
            local gOpp = isVeryBright(rgbOppRed) and {0,0,0} or {255,255,255}

            setPropertyFromGroup('opponentStrums', i, 'rgbShader.r', getColorFromHex(to_hex(rgbOppRed)))
            setPropertyFromGroup('opponentStrums', i, 'rgbShader.g', getColorFromHex(to_hex(gOpp)))
            setPropertyFromGroup('opponentStrums', i, 'rgbShader.b', getColorFromHex(to_hex(rgbOppBlue)))

            local rgbPlyRed   = getIconColorForNoteRGB(charTagPly, 'red')
            local rgbPlyBlue  = getIconColorForNoteRGB(charTagPly, 'blue')
            local gPly = isVeryBright(rgbPlyRed) and {0,0,0} or {255,255,255}

            setPropertyFromGroup('playerStrums', i, 'rgbShader.r', getColorFromHex(to_hex(rgbPlyRed)))
            setPropertyFromGroup('playerStrums', i, 'rgbShader.g', getColorFromHex(to_hex(gPly)))
            setPropertyFromGroup('playerStrums', i, 'rgbShader.b', getColorFromHex(to_hex(rgbPlyBlue)))
        end
    end
end
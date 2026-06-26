function onCreate()
    -- Unused haxe command for changing the RGB colors of splash notes.
    runHaxeCode([[
        function changeNoteSplashRBG(splashIndex:Int, colorArray:Array) {
            var curNoteSplash = game.grpNoteSplashes.members[splashIndex];
            for (i in 0...3)
			{
				curNoteSplash.rgbShader.shader.r.value[i] = colorArray[i];
                curNoteSplash.rgbShader.shader.g.value[i] = 0xFFFFFF;
                curNoteSplash.rgbShader.shader.b.value[i] = Std.int(colorArray[i] / 2);
			}
            curNoteSplash.rgbShader.shader.mult.value[0] = 1;
            curNoteSplash.rgbShader.shader.uBlocksize.value[0] = 1;
            curNoteSplash.alpha = 0.6;
        }
    ]])
end

local colorRBG = {255, 0, 0} --> Starting Color: Red
local elapsedFactor = 0
function onUpdatePost(elapsed)
    elapsedFactor = elapsedFactor + elapsed
    colorRBG = updateColor(colorRBG, elapsedFactor)
    if elapsedFactor >= 1 then
        elapsedFactor = 0
    end

    local colorHex = toHexString(colorRBG[1], colorRBG[2], colorRBG[3], true)
    local darkColorHex = toHexString(math.floor(colorRBG[1] / 2), math.floor(colorRBG[2] / 2), math.floor(colorRBG[3] / 2), true)
    for i = 0, getProperty('notes.length') - 1 do
        setPropertyFromGroup('notes', i, 'rgbShader.r', tonumber(colorHex))
        setPropertyFromGroup('notes', i, 'noteSplashData.r', tonumber(colorHex))
        setPropertyFromGroup('notes', i, 'rgbShader.g', 0xFFFFFF)
        setPropertyFromGroup('notes', i, 'noteSplashData.g', 0xFFFFFF)
        setPropertyFromGroup('notes', i, 'rgbShader.b', tonumber(darkColorHex))
        setPropertyFromGroup('notes', i, 'noteSplashData.b', tonumber(darkColorHex))
    end

    --[[for i = 0, getProperty('grpNoteSplashes.length') - 1 do
        setPropertyFromGroup('grpNoteSplashes', i, 'config.allowRGB', false)
        runHaxeFunction('changeNoteSplashRBG', {i, colorRBG})
    end]]
    
    for i = 0, getProperty('strumLineNotes.length') - 1 do
        local strumAnim = getPropertyFromGroup('strumLineNotes', i, 'animation.curAnim.name')
        if strumAnim == 'confirm' then
            setPropertyFromGroup('strumLineNotes', i, 'rgbShader.r', tonumber(colorHex))
            setPropertyFromGroup('strumLineNotes', i, 'rgbShader.g', 0xFFFFFF)
            setPropertyFromGroup('strumLineNotes', i, 'rgbShader.b', tonumber(darkColorHex))
        end
        if strumAnim == 'pressed' then
            setPropertyFromGroup('strumLineNotes', i, 'rgbShader.r', 0x87A3AD)
            setPropertyFromGroup('strumLineNotes', i, 'rgbShader.g', 0xFFFFFF)
            setPropertyFromGroup('strumLineNotes', i, 'rgbShader.b', 0x000000)
        end
    end
end

local arrayIndex = 1
function updateColor(arrayRBG, factor)
    local colorIndex1 = arrayIndex
    local colorIndex2 = arrayIndex + 1
    if colorIndex2 > 3 then
        colorIndex2 = 1
    end

    if arrayRBG[colorIndex1] == 255 and arrayRBG[colorIndex2] < 255 then
        arrayRBG[colorIndex2] = math.bound(interpolateInt(0, 255, factor), 0, 255)
    else
        arrayRBG[colorIndex1] = math.bound(interpolateInt(255, 0, factor), 0, 255)
    end

    if arrayRBG[colorIndex1] == 0 then
        arrayIndex = colorIndex2
        if arrayIndex > 3 then
            arrayIndex = 1
        end
    end

    return arrayRBG
end

function toHexString(red, green, blue, addPrefix)
    local prefix = ''
    if addPrefix == true then
        prefix = '0x'
    end

    return prefix..('%.2X'):format(red)..('%.2X'):format(green)..('%.2X'):format(blue)
end

function math.bound(value, min, max)
    return math.max(min, math.min(value, max))
end

function interpolateInt(value1, value2, factor)
    return math.floor((value2 - value1) * factor + value1)
end
-- ╔══════════════════════════════════════════════════════╗
-- ║   Note Splashes (Player) — RGB + Pixel Support       ║
-- ║   Psych Engine 0.6.3  [v4]                           ║
-- ║   Universe Engine 0.5.5	                          ║
-- ║   By Mr YMR (@ymrgame2009)				              ║
-- ╚══════════════════════════════════════════════════════╝

local splashAnims = {
    [0] = 'note splash purple',
    [1] = 'note splash blue',
    [2] = 'note splash green',
    [3] = 'note splash red'
}

local useRGB       = false
local isPixelStage = false

-- نخزن كل الـ splashes النشطة عشان نتحقق من animation.finished
local activeSplashes = {}

function onCreatePost()
    isPixelStage = getPropertyFromClass('states.PlayState', 'isPixelStage')

    useRGB = getPropertyFromClass('backend.ClientPrefs', 'data.noteRGB')
    if useRGB == nil then useRGB = getPropertyFromClass('ClientPrefs', 'data.noteRGB') end
    if useRGB == nil then useRGB = getPropertyFromClass('backend.ClientPrefs', 'noteRGB') end
    if useRGB == nil then useRGB = true end
end

function goodNoteHit(id, direction, noteType, isSustainNote)
    if getPropertyFromGroup('notes', id, 'rating') == 'sick' and not isSustainNote then
        spawnSplash(direction)
    end
end

function spawnSplash(dir)
    -- اختيار السبرايت حسب RGB + Pixel
    local splashTexture
    if isPixelStage then
        splashTexture = useRGB and 'noteSplashes-pixel' or 'noteSplashes-nRGB-pixel'
    else
        splashTexture = useRGB and 'noteSplashes' or 'noteSplashes-nRGB'
    end

    local tag = 'splash' .. getRandomInt(0, 100000)
    local x   = getPropertyFromGroup('playerStrums', dir, 'x') - 120
    local y   = getPropertyFromGroup('playerStrums', dir, 'y') - 120

    makeAnimatedLuaSprite(tag, splashTexture, x, y)

    local variant = getRandomInt(1, 2)
    addAnimationByPrefix(tag, 'splash', splashAnims[dir] .. ' ' .. variant, 24, false)

    setObjectCamera(tag, 'camHUD')
    setProperty(tag..'.visible',      getPropertyFromGroup('playerStrums', dir, 'visible'))
    setProperty(tag..'.alpha',        getPropertyFromGroup('playerStrums', dir, 'alpha'))
    setProperty(tag..'.antialiasing', getPropertyFromGroup('playerStrums', dir, 'antialiasing'))

    addLuaSprite(tag, true)
    objectPlayAnimation(tag, 'splash', true)

    -- RGB
    if useRGB then
        local ids = tostring(dir)
        runHaxeCode(
            'var spr = game.modchartSprites.get("' .. tag .. '");'
         .. 'var strum = game.playerStrums.members[' .. ids .. '];'
         .. 'if (spr != null && strum != null) {'
         ..     'if (spr.shader == null && strum.shader != null)'
         ..         ' spr.shader = strum.shader;'
         ..     'if (spr.rgbShader != null && strum.rgbShader != null) {'
         ..         'spr.rgbShader.parent.r = strum.rgbShader.parent.r;'
         ..         'spr.rgbShader.parent.g = strum.rgbShader.parent.g;'
         ..         'spr.rgbShader.parent.b = strum.rgbShader.parent.b;'
         ..     '} else { spr.color = strum.color; }'
         .. '}'
        )
    end

    -- نضيف للقائمة عشان نراقبه في update
    activeSplashes[tag] = true
end

function onUpdatePost(elapsed)
    for tag, _ in pairs(activeSplashes) do
        -- لما الأنيميشن يخلص نحذف السبرايت
        if getProperty(tag .. '.animation.finished') then
            removeLuaSprite(tag, true)
            activeSplashes[tag] = nil
        end
    end
end
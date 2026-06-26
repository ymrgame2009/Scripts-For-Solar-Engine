--script by Mr YMR (@ymrgame2009)

function onCreate()
	--Iterate over all notes
	for i = 0, getProperty('unspawnNotes.length')-1 do
		--Check if the note is an Instakill Note
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'Hurt Note - Old' then
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'HURTNOTE_assets-Old'); --Change texture
			setPropertyFromGroup('unspawnNotes', i, 'noteSplashData.texture', 'HURTnoteSplashes-Old'); --Change noteSplashes texture
			setPropertyFromGroup('unspawnNotes', i, 'rgbShader.mult', 0.0);
			setPropertyFromGroup('unspawnNotes', i, 'hitCausesMiss', true);
		end
	end
end

-- الحل الجديد: تعديل ترتيب الطبقة بالكامل لكل الـ Splashes في كل إطار بعد التحديث (Post) لضمان عدم تغلب الأسهم عليها
function onUpdatePost(elapsed)
    if getProperty('grpNoteSplashes.length') > 0 then
        -- نقوم برفع المجموعة كاملة في المقدمة بشكل مستمر لمنع المحرك من إخفائها خلف الأسهم
        setObjectOrder('grpNoteSplashes', getObjectOrder('strumLineNotes') + 20)
    end
end
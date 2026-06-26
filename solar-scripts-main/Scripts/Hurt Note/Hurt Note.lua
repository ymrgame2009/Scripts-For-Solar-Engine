--script by Mr YMR (@ymrgame2009)

function onCreate()
	--Iterate over all notes
	for i = 0, getProperty('unspawnNotes.length')-1 do
		--Check if the note is an Instakill Note
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'Hurt Note' then
			setPropertyFromGroup('unspawnNotes', i, 'noteSplashData.texture', 'HURTnoteSplashes'); --Change noteSplashes texture
			setPropertyFromGroup('unspawnNotes', i, 'noteSplashData.r', getColorFromHex('ff0000'));
           	setPropertyFromGroup('unspawnNotes', i, 'noteSplashData.g', getColorFromHex('000000'));
           	setPropertyFromGroup('unspawnNotes', i, 'noteSplashData.b', getColorFromHex('000000'));
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
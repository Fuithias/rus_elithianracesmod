function build(directory, config, parameters, level, seed)
	
	config.tooltipFields = config.tooltipFields or {}
	
	if config.tooltipFields ~= nil then
		--Контейнеры
		if config.tooltipKind == "container" and config.slotCount ~= nil then
			local SC
			if parameters.slotCount == nil then SC = config.slotCount else SC = parameters.slotCount end
			config.tooltipFields.slotCountLabel = "Вмещает предметов: "..SC
			if SC == 1 or SC == 91 then config.tooltipFields.slotCountLabel = "Вмещает "..SC.." предмет" end
			if SC == 9 or SC == 12 or SC == 16 or SC == 40 or SC == 48 or SC == 56 or SC == 60 or SC == 80 or SC == 90 or SC == 100 or SC == 110 or SC == 120 or SC == 130 or SC == 140 or SC == 150 or SC == 160 or SC == 180 or SC == 200 or SC == 300 or SC == 540 or SC == 666 then config.tooltipFields.slotCountLabel = "Вмещает "..SC.." предметов" end
			if SC == 24 or SC == 32 or SC == 64 or SC == 72 then config.tooltipFields.slotCountLabel = "Вмещает "..SC.." предмета" end
		end
		--Набор защиты
		if config.tooltipKind == "baseaugment" or config.tooltipKind == "baseAugment" or config.tooltipKind == "armoraugment" or (parameters ~= nil and (parameters.tooltipKind == "baseaugment" or parameters.tooltipKind == "baseAugment" or parameters.tooltipKind == "armoraugment")) then
		
			--NO AUGMENT INSERTED
			if parameters.currentAugment == nil then
				parameters.currentAugment = {}
				parameters.currentAugment.displayName = "^#6f6f6f;МОДУЛЬ НЕ УСТАНОВЛЕН"
			end
			--
		end
		--Питомцы
		if config.tooltipKind == "filledcapturepod" then
			if parameters.tooltipFields ~= nil then
				if parameters.tooltipFields.subtitle == "Unknown" then parameters.tooltipFields.subtitle = "Неизвестный" end
			end
			--Неизвестный питомец
			if parameters.description == "Some indescribable horror" then parameters.description = "Какой-то неописуемый ужас." end
			--
		end
		
		--Редкость
		if parameters == nil or parameters.rarity == nil then
			if config.rarity == "common" or config.rarity == "Common" then config.tooltipFields.rarityLabel = "Обычный" end
			if config.rarity == "uncommon" or config.rarity == "Uncommon" then config.tooltipFields.rarityLabel = "Необычный" end
			if config.rarity == "rare" or config.rarity == "Rare" then config.tooltipFields.rarityLabel = "Редкий" end
			if config.rarity == "legendary" or config.rarity == "Legendary" then config.tooltipFields.rarityLabel = "Легендарный" end
		else
			if parameters.rarity == "common" or parameters.rarity == "Common" then config.tooltipFields.rarityLabel = "Обычный" end
			if parameters.rarity == "uncommon" or parameters.rarity == "Uncommon" then config.tooltipFields.rarityLabel = "Необычный" end
			if parameters.rarity == "rare" or parameters.rarity == "Rare" then config.tooltipFields.rarityLabel = "Редкий" end
			if parameters.rarity == "legendary" or parameters.rarity == "Legendary" then config.tooltipFields.rarityLabel = "Легендарный" end
		end
		--Тип предмета
		if config.twoHanded then config.tooltipFields.handednessLabel = "2-Ручный" else config.tooltipFields.handednessLabel = "1-Ручный" end

	end
	
	return config,parameters
end
require "/scripts/util.lua"
require "/scripts/versioningutils.lua"
require "/items/buildscripts/abilities.lua"

function build(directory, config, parameters, level, seed)
  local configParameter = function(keyName, defaultValue)
    if parameters[keyName] ~= nil then
      return parameters[keyName]
    elseif config[keyName] ~= nil then
      return config[keyName]
    else
      return defaultValue
    end
  end

  if level and not configParameter("fixedLevel", true) then
    parameters.level = level
  end

  -- select, load and merge abilities
  setupAbility(config, parameters, "alt")
  setupAbility(config, parameters, "primary")

  -- elemental type
  local elementalType = parameters.elementalType or config.elementalType or "physical"
  replacePatternInData(config, nil, "<elementalType>", elementalType)
  if config.altAbility and config.altAbility.elementalConfig then
    util.mergeTable(config.altAbility, config.altAbility.elementalConfig[elementalType])
  end

  -- calculate damage level multiplier
  config.damageLevelMultiplier = root.evalFunction("weaponDamageLevelMultiplier", configParameter("level", 1))

  -- populate tooltip fields
  if config.tooltipKind ~= "base" then
	config.tooltipFields = {}
    config.tooltipFields.levelLabel = util.round(configParameter("level", 1), 1)
	config.tooltipFields.subtitle = parameters.category
	config.tooltipFields.drawTimeLabel = config.primaryAbility.drawTime or 0
	config.tooltipFields.energyPerShotLabel = config.primaryAbility.energyPerShot or 0
	config.tooltipFields.energyPerSecondLabel = config.primaryAbility.holdEnergyUsage or 0
	config.tooltipFields.maxDamageLabel = config.primaryAbility.baseDamage * config.damageLevelMultiplier
	if elementalType ~= "physical" then
	  config.tooltipFields.damageKindImage = "/interface/elements/"..elementalType..".png"
	end
    if config.primaryAbility then
      config.tooltipFields.primaryAbilityTitleLabel = "Основное:"
      config.tooltipFields.primaryAbilityLabel = config.primaryAbility.name or "неизвестно"
    end
    if config.altAbility then
      config.tooltipFields.altAbilityTitleLabel = "Особое:"
      config.tooltipFields.altAbilityLabel = config.altAbility.name or "неизвестно"
    end
	--Custom manufacturer label
	config.tooltipFields.manufacturerLabel = configParameter("manufacturer") or "unknown"
  end

  -- set price
  config.price = (config.price or 0) * root.evalFunction("itemLevelPriceMultiplier", configParameter("level", 1))

  --Редкость
  if config.rarity == "common" or config.rarity == "Common" then config.tooltipFields.rarityLabel = "Обычный" end
  if config.rarity == "uncommon" or config.rarity == "Uncommon" then config.tooltipFields.rarityLabel = "Необычный" end
  if config.rarity == "rare" or config.rarity == "Rare" then config.tooltipFields.rarityLabel = "Редкий" end
  if config.rarity == "legendary" or config.rarity == "Legendary" then config.tooltipFields.rarityLabel = "Легендарный" end
  --Тип предмета
  if config.twoHanded then config.tooltipFields.handednessLabel = "2-Ручный" else config.tooltipFields.handednessLabel = "1-Ручный" end

  return config, parameters
end
require "/scripts/util.lua"
require "/scripts/vec2.lua"
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

  setupAbility(config, parameters, "primary")
  setupAbility(config, parameters, "alt")

  -- elemental type and config (for alt ability)
  local elementalType = configParameter("elementalType", "physical")
  replacePatternInData(config, nil, "<elementalType>", elementalType)
  if config.altAbility and config.altAbility.elementalConfig then
    util.mergeTable(config.altAbility, config.altAbility.elementalConfig[elementalType])
  end

  -- calculate damage level multiplier
  config.damageLevelMultiplier = root.evalFunction("weaponDamageLevelMultiplier", configParameter("level", 1))

  -- palette swaps
  config.paletteSwaps = ""
  if config.palette then
    local palette = root.assetJson(util.absolutePath(directory, config.palette))
    local selectedSwaps = palette.swaps[configParameter("colorIndex", 1)]
    for k, v in pairs(selectedSwaps) do
      config.paletteSwaps = string.format("%s?replace=%s=%s", config.paletteSwaps, k, v)
    end
  end
  if type(config.inventoryIcon) == "string" then
    config.inventoryIcon = config.inventoryIcon .. config.paletteSwaps
  else
    for i, drawable in ipairs(config.inventoryIcon) do
      if drawable.image then drawable.image = drawable.image .. config.paletteSwaps end
    end
  end

  -- gun offsets
  if config.baseOffset then
    construct(config, "animationCustom", "animatedParts", "parts", "middle", "properties")
    config.animationCustom.animatedParts.parts.middle.properties.offset = config.baseOffset
    if config.muzzleOffset then
      config.muzzleOffset = vec2.add(config.muzzleOffset, config.baseOffset)
    end
  end

  -- populate tooltip fields
  if config.tooltipKind ~= "base" then
    config.tooltipFields = {}
    config.tooltipFields.levelLabel = util.round(configParameter("level", 1), 1)
    config.tooltipFields.dpsLabel = util.round((config.primaryAbility.baseDps or 0) * config.damageLevelMultiplier, 1)
    config.tooltipFields.speedLabel = util.round(1 / (config.primaryAbility.fireTime or 1.0), 1)
    config.tooltipFields.roundsPerBurstLabel = config.primaryAbility.burstCount or 1
    config.tooltipFields.damagePerShotLabel = util.round((config.primaryAbility.baseDps or 0) * (config.primaryAbility.fireTime or 1.0) * (config.primaryAbility.burstCount or 1) * config.damageLevelMultiplier, 1)
    config.tooltipFields.energyPerShotLabel = util.round((config.primaryAbility.energyUsage or 0) * (config.primaryAbility.fireTime or 1.0) * (config.primaryAbility.burstCount or 1), 1)
    config.tooltipFields.energyPerSecondLabel = util.round((config.primaryAbility.energyUsage or 0), 1)
    if elementalType ~= "physical" then
      config.tooltipFields.damageKindImage = "/interface/elements/"..elementalType..".png"
    end
    if config.primaryAbility then
      config.tooltipFields.primaryAbilityTitleLabel = "Основной:"
      config.tooltipFields.primaryAbilityLabel = config.primaryAbility.name or "неизвестно"
    end
    if config.altAbility then
      config.tooltipFields.altAbilityTitleLabel = "Особый:"
      config.tooltipFields.altAbilityLabel = config.altAbility.name or "неизвестно"
    end
	--Custom manufacturer label
	config.tooltipFields.manufacturerLabel = configParameter("manufacturer")
  end

  -- set price
  -- TODO: should this be handled elsewhere?
  config.price = (config.price or 0) * root.evalFunction("itemLevelPriceMultiplier", configParameter("level", 1))

  --Редкость
  if config.rarity == "common" or config.rarity == "Common" then config.tooltipFields.rarityLabel = "Обычный" end
  if config.rarity == "uncommon" or config.rarity == "Uncommon" then config.tooltipFields.rarityLabel = "Необычный" end
  if config.rarity == "rare" or config.rarity == "Rare" then config.tooltipFields.rarityLabel = "Редкий" end
  if config.rarity == "legendary" or config.rarity == "Legendary" then config.tooltipFields.rarityLabel = "Легендарный" end
  if config.rarity == "essential" or config.rarity == "Essential" then config.tooltipFields.rarityLabel = "Важный" end
  --Тип предмета
  if config.twoHanded then config.tooltipFields.handednessLabel = "2-Ручный" else config.tooltipFields.handednessLabel = "1-Ручный" end

  return config, parameters
end
require "/scripts/util.lua"

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

  -- load and merge combo finisher
  local comboFinisherSource = configParameter("comboFinisherSource")
  if comboFinisherSource then
    local comboFinisherConfig = root.assetJson(comboFinisherSource)
    util.mergeTable(config, comboFinisherConfig)
  end

  -- calculate damage level multiplier
  config.damageLevelMultiplier = root.evalFunction("weaponDamageLevelMultiplier", configParameter("level", 1))

  config.tooltipFields = {}
  config.tooltipFields.levelLabel = util.round(configParameter("level", 1), 1)
  config.tooltipFields.subtitle = parameters.category
  config.tooltipFields.speedLabel = util.round(1 / config.primaryAbility.fireTime, 1)
  config.tooltipFields.damagePerShotLabel = util.round(config.primaryAbility.baseDps * config.primaryAbility.fireTime * config.damageLevelMultiplier, 1)
  if config.comboFinisher then
    config.tooltipFields.comboFinisherTitleLabel = "Добивание:"
    config.tooltipFields.comboFinisherLabel = config.comboFinisher.name or "неизвестно"
  end
  --Custom manufacturer label
  config.tooltipFields.manufacturerLabel = configParameter("manufacturer")

  -- set price
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
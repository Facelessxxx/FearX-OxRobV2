Config = {}

Config.Framework = 'auto'
Config.RobCooldown = 10
Config.RobDistance = 2.0
Config.AntiSpam = 5
Config.ProgressBar = 'ox_lib'
Config.RequireHandsUp = true

Config.RobMode = 'both' -- 'alive'(only rob while alive) 'dead' (only rob while dead) 'both'(rob while dead and alive)

Config.RobTimer = {
    min = 5,
    max = 5
}

Config.Animations = {
    {dict = 'anim@mugging@mugger@catch_1h_gun@', anim = 'catch_object_pistol_male', flag = 49},
    {dict = 'anim@mugging@mugger@catch_1h_gun@', anim = 'catch_object_pistol_female', flag = 49},
    {dict = 'anim@mugging@mugger@catch_1h_gun@', anim = 'catch_object_pistol_male', flag = 1},
    {dict = 'anim@mugging@mugger@catch_1h_gun@', anim = 'catch_object_pistol_female', flag = 1}
}

Config.Locales = {
    ['hands_not_up'] = 'Target must have their hands up',
    ['rob_cooldown'] = 'You must wait before robbing again',
    ['target_cooldown'] = 'This person was recently robbed',
    ['rob_cancelled'] = 'Robbery cancelled',
    ['no_target'] = 'No target found',
    ['cant_rob_self'] = 'You cannot rob yourself',
    ['target_in_vehicle'] = 'Target is in a vehicle',
    ['robber_in_vehicle'] = 'You cannot rob while in a vehicle',
    ['anti_cheat'] = 'Anti-cheat violation detected',
    ['robbing_in_progress'] = 'Robbing in progress...',
    ['robbery_started'] = 'Someone is robbing you!',
    ['exploit_attempt'] = 'Someone is trying to trigger the event to rob you from far - make a report',
    ['target_not_dead'] = 'Target must be dead to rob',
    ['target_is_dead'] = 'Target must be alive to rob'
}
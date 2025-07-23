local scriptVersion = "2.0.0"
local scriptName = "FearX-OxRobV2"

CreateThread(function()
    Wait(2000)
    print(string.format("^0======================================^0"))
    print(string.format("^2%s ^0- ^3Version %s^0", scriptName, scriptVersion))
    print(string.format("^2Author: ^0Fearx"))
    print(string.format("^2Rob Mode: ^3%s^0", Config.RobMode))
    print(string.format("^2Framework: ^3%s^0", Config.Framework))
    print(string.format("^0======================================^0"))
end)
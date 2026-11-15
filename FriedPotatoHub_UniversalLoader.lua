local GameLoaders = {
    [131490353122580] = "https://your-script-link-here",
    [1234567890] = "https://another-script-link-here",
}

local ScriptURL = GameLoaders[game.PlaceId]

if ScriptURL then
    loadstring(game:HttpGet(ScriptURL))()
else
    warn("[FriedPotatoHub] This game is not supported.")
end

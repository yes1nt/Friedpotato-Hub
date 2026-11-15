local GameLoaders = {
    [131490353122580] = "https://your-script-link-here",
    [1234567890] = "https://another-script-link-here",
}

local StarterGui = game:GetService("StarterGui")
local function Notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 6,
        })
    end)
end
if not game:IsLoaded() then
    game.Loaded:Wait()
end
repeat task.wait() until game.PlaceId ~= 0
local ScriptURL = GameLoaders[game.PlaceId]
if not ScriptURL then
    Notify("FriedPotato Hub", "This game is not supported.")
    return
end
local fetched, source = pcall(game.HttpGet, game, ScriptURL)
if not fetched then
    Notify("FriedPotato Hub", "Could not download the script.")
    return
end
local compiled, chunk = pcall(loadstring, source)
if not (compiled and chunk) then
    Notify("FriedPotato Hub", "The script failed to compile.")
    return
end

local ran, err = pcall(chunk)
if not ran then
    Notify("FriedPotato Hub", "The script errored while loading.")
    warn("[FriedPotatoHub] " .. tostring(err))
end

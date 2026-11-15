local GameLoaders = getgenv().GameLoaders or {
    [000001] = "https://your-script-link-here",
    [000002] = "https://another-script-link-here",
}
getgenv().GameLoaders = nil

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- ========================================
-- FriedPotato notifications
-- ========================================
local Notify = getgenv().FriedPotatoNotify or (function()
    local Notify = {}

    local Theme = {
        Background = Color3.fromRGB(10, 16, 28),
        SubText = Color3.fromRGB(137, 158, 183),
        Info = Color3.fromRGB(72, 145, 225),
        Success = Color3.fromRGB(80, 200, 120),
        Warning = Color3.fromRGB(240, 180, 60),
        Error = Color3.fromRGB(235, 80, 80),
    }
    local FontTitle = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Bold)
    local FontBody = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)

    local holder

    local function create(className, properties, children)
        local instance = Instance.new(className)
        for property, value in properties do
            instance[property] = value
        end
        for _, child in children or {} do
            child.Parent = instance
        end
        return instance
    end

    local function ensureHolder()
        if holder and holder.Parent then
            return holder
        end
        local gui = create("ScreenGui", {
            Name = "FriedPotatoNotifications",
            ResetOnSpawn = false,
            IgnoreGuiInset = true,
            DisplayOrder = 1000,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        })
        gui.Parent = gethui()
        holder = create("Frame", {
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -16, 1, -16),
            Size = UDim2.new(0, 290, 1, -32),
            Parent = gui,
        }, {
            create("UIListLayout", {
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
            }),
        })
        return holder
    end

    -- Notify.Send(title, content, duration, kind)
    -- kind: "Info" (default), "Success", "Warning" or "Error". Clicking a notification closes it.
    function Notify.Send(title, content, duration, kind)
        local color = Theme[kind or "Info"] or Theme.Info
        local card = create("TextButton", {
            Text = "",
            AutoButtonColor = false,
            BackgroundColor3 = Theme.Background,
            BackgroundTransparency = 0.05,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
        }, {
            create("UICorner", { CornerRadius = UDim.new(0, 12) }),
            create("UIStroke", { Color = color, Transparency = 0.3, Thickness = 1 }),
            create("UIPadding", {
                PaddingTop = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 10),
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12),
            }),
            create("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }),
            create("TextLabel", {
                Text = tostring(title or "FriedPotato Hub"),
                FontFace = FontTitle,
                TextSize = 15,
                TextColor3 = color,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 18),
                LayoutOrder = 1,
            }),
            content and content ~= "" and create("TextLabel", {
                Text = tostring(content),
                FontFace = FontBody,
                TextSize = 14,
                TextColor3 = Theme.SubText,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = 2,
            }) or nil,
        })
        card.Parent = ensureHolder()
        card.Activated:Connect(function()
            card:Destroy()
        end)
        task.delay(tonumber(duration) or 5, function()
            if card.Parent then
                card:Destroy()
            end
        end)
    end

    getgenv().FriedPotatoNotify = Notify
    return Notify
end)()

-- ========================================
-- Execution logger
-- ========================================
local WEBHOOK_URL = "https://yellow-dream-8afe.friedpotato0922.workers.dev"

-- Locale-independent game name (GetProductInfo localizes it per player language).
local function getGameName()
    local ok, response = pcall(request, {
        Url = "https://games.roblox.com/v1/games?universeIds=" .. game.GameId,
        Method = "GET",
        Headers = { ["Accept-Language"] = "en-US" },
    })
    if ok and response and response.StatusCode == 200 then
        local decoded = HttpService:JSONDecode(response.Body)
        local info = decoded and decoded.data and decoded.data[1]
        if info and info.name then
            return info.name
        end
    end
    return "Unknown"
end

local function sendExecutionLog()
    local player = Players.LocalPlayer
    local executorName, executorVersion = identifyexecutor()
    local executor = executorVersion and (executorName .. " " .. executorVersion) or executorName
    local gameName = getGameName()

    local payload = {
        username = "Script Logger",
        embeds = { {
            title = "Script Executed",
            url = "https://www.roblox.com/users/" .. player.UserId .. "/profile",
            color = 0x5865F2,
            thumbnail = {
                url = "https://www.roblox.com/headshot-thumbnail/image?userId="
                    .. player.UserId .. "&width=150&height=150&format=png",
            },
            fields = {
                { name = "👤 Username", value = "`" .. player.Name .. "`", inline = true },
                { name = "📛 Display Name", value = "`" .. player.DisplayName .. "`", inline = true },
                { name = "🆔 User ID", value = "`" .. player.UserId .. "`", inline = true },
                {
                    name = "🎮 Game (click to join)",
                    value = string.format(
                        "[%s](https://www.roblox.com/games/start?placeId=%d&gameInstanceId=%s)",
                        gameName, game.PlaceId, game.JobId
                    ),
                    inline = false,
                },
                {
                    name = "📍 Place ID",
                    value = "[" .. game.PlaceId .. "](https://www.roblox.com/games/" .. game.PlaceId .. ")",
                    inline = true,
                },
                { name = "🌐 Job ID", value = "```" .. game.JobId .. "```", inline = false },
                { name = "⚙️ Executor", value = "`" .. executor .. "`", inline = true },
            },
            footer = { text = "FriedPotato" },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        } },
    }

    pcall(request, {
        Url = WEBHOOK_URL,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode(payload),
    })
end

-- ========================================
-- Loader
-- ========================================
if not game:IsLoaded() then
    game.Loaded:Wait()
end
repeat task.wait() until game.GameId ~= 0

local ScriptURL = GameLoaders[game.GameId]
if not ScriptURL then
    Notify.Send("FriedPotato Hub", "This game is not supported.", 6, "Warning")
    return
end

task.spawn(sendExecutionLog)

local fetched, source = pcall(game.HttpGet, game, ScriptURL)
if not fetched then
    Notify.Send("FriedPotato Hub", "Could not download the script.", 6, "Error")
    return
end

getgenv().SCRIPT_KEY = getgenv().SCRIPT_KEY or "FRIEDPOTATO HUB"

local compiled, chunk = pcall(loadstring, source)
if not (compiled and chunk) then
    Notify.Send("FriedPotato Hub", "The script failed to compile.", 6, "Error")
    return
end


local ran, err = pcall(chunk)
if ran then
    Notify.Send(
        "FriedPotato Hub",
        "Welcome, " .. Players.LocalPlayer.DisplayName .. "! Script loaded successfully.",
        5,
        "Success"
    )
else
    Notify.Send("FriedPotato Hub", "The script errored while loading.", 6, "Error")
    warn("[FriedPotatoHub] " .. tostring(err))
end

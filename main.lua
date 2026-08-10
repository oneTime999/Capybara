local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")

Players.LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

local EGG_WEBHOOK = "https://discord.com/api/webhooks/1535448086875340932/nUW3FzUCxno2gDk9ahnIZZhBtjPHmpt6-JJNsrDZtV0-76Iu219MasTnU3NMplw_urAD"
local GEAR_WEBHOOK = "https://discord.com/api/webhooks/1536512837378244618/HN1AEO6jgkLgiNWF4pav6dxud79izPFHQLZHOJMxLACTfva0ZntDPoYvnCUyjCvd-Z6k"
local WEATHER_WEBHOOK = "https://discord.com/api/webhooks/1536513275167248406/r15ZIm0kiCDTSzr6LbFl2YhyWeKvLoi4t3ssyXRO7IoneAG2hu88KPu7XzaMiBeOQoJQ"
local MERCHANT_WEBHOOK = "https://discord.com/api/webhooks/1536513427650908231/2OAq-mAfkJqfaRkaqht95SXr9oAoSuIokJ5C_3-bM-WpXuN8tWlnMqTO7NNNhTUvdt-v"

local roleMap = {
    ["angel"] = "1535453948662784051",
    ["disco"] = "1535454015331242004",
    ["robot"] = "1535454069500551310",
    ["golem"] = "1535454144381591673",
    ["ghost"] = "1535647401459843134"
}

local emojiMap = {
    ["alpha"] = "<:alphacapybaraegg:1535644980805107732>",
    ["archer"] = "<:archercapybaraegg:1535645073088319618>",
    ["magic"] = "<:magiccapybaraegg:1535645156819083304>",
    ["ghost"] = "<:ghostcapybaraegg:1535645469751910410>",
    ["golem"] = "<:golemcapybaraegg:1535645934271205406>",
    ["robot"] = "<:robotcapybaraegg:1535646117264359545>",
    ["disco"] = "<:discocapybaraegg:1535646170473439242>",
    ["angel"] = "<:angelcapybaraegg:1535646222566555668>"
}

local validWeathers = {
    "Night", "Meteor Shower", "Rain", "Thunder", "Zen", "Snowy", 
    "Blizzard", "Heatwave", "Red Sun", "Glitch", "Taco Rain", "Reverse Sun"
}

local defaultEmoji = "<:capybaraegg:1535644863477846186>"

local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local MainGui = PlayerGui:WaitForChild("MainGui")
local Root = MainGui:WaitForChild("Root")
local Frames = Root:WaitForChild("Frames")
local EggShopList = Frames:WaitForChild("EggShop"):WaitForChild("List")
local GearShopList = Frames:WaitForChild("GearShop"):WaitForChild("List")
local WeatherIconsFolder = Root:WaitForChild("WeatherIcons")

local function getBrasiliaTime()
    local utcTime = os.time()
    local brasiliaTime = utcTime - (3 * 3600)
    return os.date("!%H:%M:%S (BRT)", brasiliaTime)
end

local function getEmojiForEgg(eggName)
    local lowerName = string.lower(eggName)
    for key, emoji in pairs(emojiMap) do
        if string.find(lowerName, key) then
            return emoji
        end
    end
    return defaultEmoji
end

local function sendWebhookRequest(url, data)
    if not httprequest then return end
    httprequest({
        Url = url,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode(data)
    })
end

local function sendEggWebhook()
    local descriptionLines = {}
    local mentions = {}
    
    for _, item in ipairs(EggShopList:GetChildren()) do
        if string.find(string.lower(item.Name), "egg") then
            local stockLabel = item:FindFirstChild("Stock")
            local stockText = stockLabel and stockLabel.Text or "Unknown"
            
            if stockText ~= "Unknown" and not string.find(string.upper(stockText), "NO STOCK") then
                local cleanStock = string.match(stockText, "x%d+") or string.gsub(stockText, "\n", " ")
                local eggEmoji = getEmojiForEgg(item.Name)
                
                table.insert(descriptionLines, eggEmoji .. " **" .. item.Name .. "**\n> 📦 Stock: `" .. cleanStock .. "`\n")
                
                for key, roleId in pairs(roleMap) do
                    if string.find(string.lower(item.Name), key) then
                        table.insert(mentions, "<@&" .. roleId .. ">")
                    end
                end
            end
        end
    end

    local finalDescription = table.concat(descriptionLines, "\n")
    if finalDescription == "" then finalDescription = "❌ *No eggs currently in stock.*" end
    
    local uniqueMentions = ""
    local seen = {}
    for _, m in ipairs(mentions) do
        if not seen[m] then
            uniqueMentions = uniqueMentions .. m .. " "
            seen[m] = true
        end
    end
    
    local data = {
        ["content"] = uniqueMentions ~= "" and uniqueMentions or nil,
        ["embeds"] = {{
            ["title"] = "🏪 Egg Shop Restock",
            ["description"] = finalDescription,
            ["color"] = 65280,
            ["footer"] = { ["text"] = "Updated at " .. getBrasiliaTime() }
        }}
    }
    sendWebhookRequest(EGG_WEBHOOK, data)
end

local function sendGearWebhook()
    local descriptionLines = {}
    
    for _, item in ipairs(GearShopList:GetChildren()) do
        local stockLabel = item:FindFirstChild("Stock")
        if stockLabel then
            local stockText = stockLabel.Text
            if not string.find(string.upper(stockText), "NO STOCK") then
                local cleanStock = string.match(stockText, "x%d+") or string.gsub(stockText, "\n", " ")
                table.insert(descriptionLines, "⚒️ **" .. item.Name .. "**\n> 📦 Stock: `" .. cleanStock .. "`\n")
            end
        end
    end

    local finalDescription = table.concat(descriptionLines, "\n")
    if finalDescription == "" then finalDescription = "❌ *No gears currently in stock.*" end
    
    local data = {
        ["embeds"] = {{
            ["title"] = "⚙️ Gear Shop Restock",
            ["description"] = finalDescription,
            ["color"] = 3447003,
            ["footer"] = { ["text"] = "Updated at " .. getBrasiliaTime() }
        }}
    }
    sendWebhookRequest(GEAR_WEBHOOK, data)
end

local function sendWeatherWebhook()
    local activeWeathers = {}
    
    for _, icon in ipairs(WeatherIconsFolder:GetChildren()) do
        if table.find(validWeathers, icon.Name) then
            table.insert(activeWeathers, "🌤️ **" .. icon.Name .. "**")
        end
    end
    
    local finalDescription = table.concat(activeWeathers, "\n")
    if finalDescription == "" then finalDescription = "☁️ *No special weather events active.*" end
    
    local data = {
        ["embeds"] = {{
            ["title"] = "🌦️ Weather Status",
            ["description"] = finalDescription,
            ["color"] = 16776960,
            ["footer"] = { ["text"] = "Updated at " .. getBrasiliaTime() }
        }}
    }
    sendWebhookRequest(WEATHER_WEBHOOK, data)
end

local function sendMerchantWebhook()
    local merchantName = "Unknown"
    local mapFolder = Workspace:FindFirstChild("World") and Workspace.World:FindFirstChild("Map")
    local npcsFolder = mapFolder and mapFolder:FindFirstChild("NPCs")
    local merchantNpc = npcsFolder and npcsFolder:FindFirstChild("MerchantNPC")
    
    if merchantNpc then
        local attr = merchantNpc:GetAttribute("MerchantName")
        local childVal = merchantNpc:FindFirstChild("MerchantName")
        
        if attr then
            merchantName = tostring(attr)
        elseif childVal and childVal:IsA("StringValue") then
            merchantName = childVal.Value
        end
    end
    
    local data = {
        ["embeds"] = {{
            ["title"] = "🧑‍💼 Merchant Status",
            ["description"] = "🏷️ **Current Merchant:** `" .. merchantName .. "`",
            ["color"] = 15105570,
            ["footer"] = { ["text"] = "Updated at " .. getBrasiliaTime() }
        }}
    }
    sendWebhookRequest(MERCHANT_WEBHOOK, data)
end

sendEggWebhook()
sendGearWebhook()
sendWeatherWebhook()
sendMerchantWebhook()

local lastMinute5 = -1

task.spawn(function()
    while task.wait(1) do
        local currentMinute = tonumber(os.date("!%M", os.time()))
        
        if currentMinute % 5 == 0 then
            if currentMinute ~= lastMinute5 then
                lastMinute5 = currentMinute
                task.wait(2)
                sendEggWebhook()
                sendGearWebhook()
                sendWeatherWebhook()
                sendMerchantWebhook()
            end
        end
    end
end)

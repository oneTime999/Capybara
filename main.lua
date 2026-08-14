local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BuyMerchantItem = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("BuyMerchantItem")
local BuyItem = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("BuyItem")

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
    "Night", "Meteor Shower", "Rain", "Thunder", "Zen", "Snowy", "Snow",
    "Blizzard", "Heatwave", "Red Sun", "Glitch", "Taco Rain", "Reverse Sun"
}

local weatherMutations = {
    ["Thunder"] = "Shocked",
    ["Zen"] = "Tranquil",
    ["Night"] = "Moonlight",
    ["Snow"] = "Chilly",
    ["Blizzard"] = "Permafrost",
    ["Heatwave"] = "Toasty",
    ["Glitch"] = "Glitched",
    ["Meteor Shower"] = "Celestial",
    ["Rain"] = "+25% Faster Plant Spawnrate",
    ["Red Sun"] = "Scorched"
}

local weatherRoles = {
    ["Chilly"] = "1537689307614027958",
    ["Glitched"] = "1537221727535370321",
    ["Toasty"] = "1537221683667279914",
    ["Permafrost"] = "1537221644391551066",
    ["Tranquil"] = "1537221598313058304",
    ["Shocked"] = "1537221553031221328",
    ["Celestial"] = "1537231135552311358",
    ["+25% Faster Plant Spawnrate"] = "1537231219572473928",
    ["Scorched"] = "1537231281731928146"
}

local merchantItemRoles = {
    ["Gilded Hatch Hammer"] = "1537226549689065605",
    ["Gold Scroll"] = "1537226610430713886",
    ["Totem Of Status"] = "1537226662863831100",
    ["Raygun"] = "1537226801049509929",
    ["Alien Tesla"] = "1537226928959000758",
    ["Totem Of Stars"] = "1537226952287723571",
    ["Totem Of Might"] = "1537227181107970168",
    ["Totem Of Marrow"] = "1537227221536608266",
    ["Rainbow Scroll"] = "1537227245238878318",
    ["Moonlit Scroll"] = "1537227098186580038",
    ["Chilly Scroll"] = "1537227678854418492",
    ["Toasty Scroll"] = "1537227446766800906",
    ["Tranquil Scroll"] = "1537227539980750888",
    ["Shocked Scroll"] = "1537227413849776138",
    ["Glitched Scroll"] = "1537227387412942909"
}

local merchantItemsToBuy = {
    "Gilded Hatch Hammer",
    "Gold Scroll",
    "Totem Of Status",
    "Raygun",
    "Alien Tesla",
    "Totem Of Stars",
    "Totem Of Might",
    "Totem Of Marrow",
    "Rainbow Scroll",
    "Moonlit Scroll",
    "Chilly Scroll",
    "Toasty Scroll",
    "Tranquil Scroll",
    "Shocked Scroll",
    "Glitched Scroll"
}

local targetEggsToBuy = {
    "Angel Capybara Egg",
    "Disco Capybara Egg"
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
local MerchantShop = Frames:WaitForChild("MerchantShop")

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
    local readyToBuyEggs = {} 
    
    for _, item in ipairs(EggShopList:GetChildren()) do
        if string.find(string.lower(item.Name), "egg") then
            local stockLabel = item:FindFirstChild("Stock")
            local stockText = stockLabel and stockLabel.Text or "Unknown"
            
            if stockText ~= "Unknown" and not string.find(string.upper(stockText), "NO STOCK") then
                local cleanStock = string.match(stockText, "x%d+") or string.gsub(stockText, "\n", " ")
                local eggEmoji = getEmojiForEgg(item.Name)
                
                table.insert(descriptionLines, eggEmoji .. " **" .. item.Name .. "**\n> 📦 Stock: `" .. cleanStock .. "`\n")
                
                if table.find(targetEggsToBuy, item.Name) then
                    table.insert(readyToBuyEggs, item.Name)
                end
                
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
            ["color"] = 16711680,
            ["image"] = {
                ["url"] = "https://cdn.discordapp.com/attachments/1537331988720123935/1537334893397282896/ChatGPT_Image_13_de_ago._de_2026_02_39_49_1.png?ex=6a7eaa30&is=6a7d58b0&hm=8459ab8db1d21cbff1f8aedda35902f521a524c822933c87afcfc5c49f714d89&"
            },
            ["footer"] = { ["text"] = "Updated" },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }
    
    sendWebhookRequest(EGG_WEBHOOK, data)
    
    for _, eggName in ipairs(readyToBuyEggs) do
        BuyItem:FireServer(eggName)
    end
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
            ["color"] = 16711680,
            ["image"] = {
                ["url"] = "https://cdn.discordapp.com/attachments/1537331988720123935/1537334893846204416/ChatGPT_Image_13_de_ago._de_2026_02_39_49_2.png?ex=6a7eaa30&is=6a7d58b0&hm=f217b1699c4a3c3a6ccaf89d57e3f8d48ce48002bf71338b17cc73cfeac36757&"
            },
            ["footer"] = { ["text"] = "Updated" },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }
    
    sendWebhookRequest(GEAR_WEBHOOK, data)
end

local function sendWeatherWebhook()
    local activeWeathers = {}
    local mentions = {}
    
    for _, icon in ipairs(WeatherIconsFolder:GetChildren()) do
        if table.find(validWeathers, icon.Name) then
            local mutationName = weatherMutations[icon.Name]
            local displayName = icon.Name
            local roleKey = icon.Name
            
            if mutationName then
                displayName = icon.Name .. " -> " .. mutationName
                roleKey = mutationName
            end
            
            table.insert(activeWeathers, "🌤️ **" .. displayName .. "**")
            
            if weatherRoles[roleKey] then
                table.insert(mentions, "<@&" .. weatherRoles[roleKey] .. ">")
            end
        end
    end
    
    local finalDescription = table.concat(activeWeathers, "\n")
    if finalDescription == "" then finalDescription = "☁️ *No special weather events active.*" end
    
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
            ["title"] = "🌦️ Weather Status",
            ["description"] = finalDescription,
            ["color"] = 16711680,
            ["image"] = {
                ["url"] = "https://cdn.discordapp.com/attachments/1537331988720123935/1537334892818604053/ChatGPT_Image_13_de_ago._de_2026_02_39_49_4.png?ex=6a7eaa30&is=6a7d58b0&hm=0fb53641115bf847c2c20b23b6748242ba06ec417c5b04e1f0c7e105fc2ae870&"
            },
            ["footer"] = { ["text"] = "Updated" },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }
    
    sendWebhookRequest(WEATHER_WEBHOOK, data)
end

local function trimText(value)
    if value == nil then
        return nil
    end

    local text = tostring(value):match("^%s*(.-)%s*$")
    if text == "" then
        return nil
    end

    return text
end

local function readTextObject(object)
    if not object then
        return nil
    end

    if object:IsA("StringValue") then
        return trimText(object.Value)
    end

    if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
        return trimText(object.Text)
    end

    return nil
end

local function isGenericMerchantName(name)
    if not name then
        return true
    end

    local lowerName = string.lower(trimText(name) or "")
    return lowerName == ""
        or lowerName == "merchant"
        or lowerName == "merchantnpc"
        or lowerName == "merchant npc"
        or lowerName == "merchant shop"
end

local function findMerchantNpc()
    local world = Workspace:FindFirstChild("World")
    local map = world and world:FindFirstChild("Map")
    local npcs = map and map:FindFirstChild("NPCs")

    if not npcs then
        return nil
    end

    local merchantNpc = npcs:FindFirstChild("MerchantNPC")

    if merchantNpc and merchantNpc:IsDescendantOf(Workspace) then
        return merchantNpc
    end

    return nil
end

local function getMerchantName(merchantNpc)
    if not merchantNpc or not merchantNpc:IsDescendantOf(Workspace) then
        return nil
    end

    local attr = trimText(merchantNpc:GetAttribute("MerchantName"))
    if attr and not isGenericMerchantName(attr) then
        return attr
    end

    local merchantNameObject = merchantNpc:FindFirstChild("MerchantName", true)
    local merchantName = readTextObject(merchantNameObject)

    if merchantName and not isGenericMerchantName(merchantName) then
        return merchantName
    end

    local nameCandidates = {
        "NPCName",
        "DisplayName",
        "NameLabel",
        "Title"
    }

    for _, candidateName in ipairs(nameCandidates) do
        local object = merchantNpc:FindFirstChild(candidateName, true)
        local value = readTextObject(object)

        if value and not isGenericMerchantName(value) then
            return value
        end
    end

    for _, descendant in ipairs(merchantNpc:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") then
            local value = trimText(descendant.ObjectText)

            if value and not isGenericMerchantName(value) then
                return value
            end
        end
    end

    -- The NPC model is the source of truth for whether the Merchant is spawned.
    -- A missing display name must never make an active Merchant look despawned.
    return "Merchant"
end

local function getMerchantItemName(item)
    local itemName = trimText(item.Name)

    local genericNames = {
        ["item"] = true,
        ["template"] = true,
        ["frame"] = true,
        ["slot"] = true
    }

    if itemName and not genericNames[string.lower(itemName)] and not tonumber(itemName) then
        return itemName
    end

    local candidates = {
        "ItemName",
        "Name",
        "Title"
    }

    for _, candidateName in ipairs(candidates) do
        local label = item:FindFirstChild(candidateName, true)
        local value = readTextObject(label)

        if value then
            return value
        end
    end

    return nil
end

local function waitForMerchantList(merchantNpc, timeoutSeconds)
    local deadline = os.clock() + timeoutSeconds

    repeat
        if not merchantNpc or not merchantNpc:IsDescendantOf(Workspace) then
            return nil
        end

        local list = MerchantShop:FindFirstChild("List")

        if list then
            for _, item in ipairs(list:GetChildren()) do
                if item:IsA("GuiObject") then
                    local stock = item:FindFirstChild("Stock", true)

                    if stock and (stock:IsA("TextLabel") or stock:IsA("TextButton") or stock:IsA("TextBox")) then
                        return list
                    end
                end
            end
        end

        task.wait(0.25)
    until os.clock() >= deadline

    return nil
end

local function sendMerchantWebhook()
    local merchantNpc = findMerchantNpc()

    -- MerchantNPC is the only spawn check.
    if not merchantNpc then
        return false
    end

    local merchantName = getMerchantName(merchantNpc)

    -- Wait for the Merchant stock UI while continuously confirming
    -- that the actual MerchantNPC still exists in Workspace.
    local merchantShopList = waitForMerchantList(merchantNpc, 15)

    if not merchantShopList or not findMerchantNpc() then
        return false
    end

    local itemsList = {}
    local mentions = {}
    local readyToBuyMerchant = {}

    for _, item in ipairs(merchantShopList:GetChildren()) do
        if item:IsA("GuiObject") then
            local stockLabel = item:FindFirstChild("Stock", true)

            if stockLabel and (stockLabel:IsA("TextLabel") or stockLabel:IsA("TextButton") or stockLabel:IsA("TextBox")) then
                local stockText = trimText(stockLabel.Text)
                local itemName = getMerchantItemName(item)

                if itemName
                    and stockText
                    and not string.find(string.upper(stockText), "NO STOCK", 1, true)
                then
                    local cleanStock = string.match(stockText, "x%d+")
                        or string.gsub(stockText, "\n", " ")

                    table.insert(
                        itemsList,
                        "📦 **" .. itemName .. "**\n> 📦 Stock: `" .. cleanStock .. "`\n"
                    )

                    if table.find(merchantItemsToBuy, itemName) then
                        table.insert(readyToBuyMerchant, itemName)
                    end

                    if merchantItemRoles[itemName] then
                        table.insert(mentions, "<@&" .. merchantItemRoles[itemName] .. ">")
                    end
                end
            end
        end
    end

    -- If MerchantNPC disappeared while reading the UI, never send stale data.
    merchantNpc = findMerchantNpc()
    if not merchantNpc then
        return false
    end

    -- The Merchant is active but the UI may still be populating.
    -- Returning false makes the monitor retry instead of marking this spawn as handled.
    if #itemsList == 0 then
        return false
    end

    merchantName = getMerchantName(merchantNpc) or "Merchant"

    local itemsDescription = table.concat(itemsList, "\n")

    local uniqueMentions = ""
    local seen = {}

    for _, mention in ipairs(mentions) do
        if not seen[mention] then
            uniqueMentions = uniqueMentions .. mention .. " "
            seen[mention] = true
        end
    end

    -- One final model check immediately before the HTTP request.
    if not findMerchantNpc() then
        return false
    end

    local data = {
        ["content"] = uniqueMentions ~= "" and uniqueMentions or nil,
        ["embeds"] = {{
            ["title"] = "🧑‍💼 Merchant Status",
            ["description"] = "🏷️ **Current Merchant:** `" .. merchantName .. "`\n\n**Items in Stock:**\n" .. itemsDescription,
            ["color"] = 16711680,
            ["image"] = {
                ["url"] = "https://cdn.discordapp.com/attachments/1537331988720123935/1537334892382388244/ChatGPT_Image_13_de_ago._de_2026_02_39_49_3.png?ex=6a7eaa30&is=6a7d58b0&hm=7e466c54c9b946d2906bfc68be8d3f2cce3b166c4d4c755400b297b778b72a40&"
            },
            ["footer"] = { ["text"] = "Updated" },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }

    sendWebhookRequest(MERCHANT_WEBHOOK, data)

    -- Buy only while the real MerchantNPC is still spawned.
    for _, itemName in ipairs(readyToBuyMerchant) do
        if not findMerchantNpc() then
            break
        end

        BuyMerchantItem:FireServer(itemName)
        task.wait(0.5)
    end

    return true
end

GuiService.ErrorMessageChanged:Connect(function(errorMessage)
    if errorMessage and errorMessage ~= "" then
        local data = {
            ["embeds"] = {{
                ["title"] = "⚠️ Disconnected",
                ["description"] = "The player has been disconnected from the game.\n\n**Reason:** `" .. errorMessage .. "`",
                ["color"] = 16711680,
                ["footer"] = { ["text"] = "Disconnected" },
                ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        }
        sendWebhookRequest(EGG_WEBHOOK, data)
    end
end)

task.spawn(sendEggWebhook)
task.spawn(sendGearWebhook)
task.spawn(sendWeatherWebhook)

-- Merchant has its own state monitor.
-- It sends/buys once per spawn and resets as soon as MerchantNPC disappears.
task.spawn(function()
    local merchantWasSpawned = false
    local handledThisSpawn = false

    while task.wait(1) do
        local merchantNpc = findMerchantNpc()

        if merchantNpc then
            if not merchantWasSpawned then
                merchantWasSpawned = true
                handledThisSpawn = false
            end

            if not handledThisSpawn then
                local success = sendMerchantWebhook()

                if success then
                    handledThisSpawn = true
                end
            end
        else
            merchantWasSpawned = false
            handledThisSpawn = false
        end
    end
end)

local lastMinute = -1

task.spawn(function()
    while task.wait(1) do
        local currentMinute = tonumber(os.date("!%M", os.time()))
        
        if currentMinute ~= lastMinute then
            if currentMinute % 5 == 0 then
                lastMinute = currentMinute
                
                task.spawn(sendEggWebhook)
                task.spawn(sendGearWebhook)
                task.spawn(sendWeatherWebhook)
            end
        end
    end
end)

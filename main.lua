local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer

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
    "Night",
    "Meteor Shower",
    "Rain",
    "Thunder",
    "Zen",
    "Snowy",
    "Snow",
    "Blizzard",
    "Heatwave",
    "Red Sun",
    "Glitch",
    "Taco Rain",
    "Reverse Sun"
}

local weatherMutations = {
    ["Thunder"] = "Shocked",
    ["Night"] = "Moonlight",
    ["Zen"] = "Tranquil",
    ["Snowy"] = "Chilly",
    ["Snow"] = "Chilly",
    ["Blizzard"] = "Permafrost",
    ["Heatwave"] = "Toasty",
    ["Glitch"] = "Glitched",
    ["Meteor Shower"] = "Celestial",
    ["Rain"] = "+25% Faster Plant Spawnrate",
    ["Red Sun"] = "Scorched"
}

local weatherRoles = {
    ["Glitched"] = "1537221727535370321",
    ["Toasty"] = "1537221683667279914",
    ["Permafrost"] = "1537221644391551066",
    ["Tranquil"] = "1537221598313058304",
    ["Shocked"] = "1537221553031221328",
    ["Celestial"] = "1537231135552311358",
    ["Moonlight"] = "1537502984450084885",
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

local defaultEmoji = "<:capybaraegg:1535644863477846186>"

local httprequest =
    (syn and syn.request)
    or (http and http.request)
    or http_request
    or (fluxus and fluxus.request)
    or request

if not httprequest then
    warn("HTTP request function was not found.")
end

local PlayerGui = player:WaitForChild("PlayerGui")
local MainGui = PlayerGui:WaitForChild("MainGui")
local Root = MainGui:WaitForChild("Root")
local Frames = Root:WaitForChild("Frames")

local EggShopList = Frames
    :WaitForChild("EggShop")
    :WaitForChild("List")

local GearShopList = Frames
    :WaitForChild("GearShop")
    :WaitForChild("List")

local WeatherIconsFolder = Root
    :WaitForChild("WeatherIcons")

local MerchantShop = Frames
    :WaitForChild("MerchantShop")

local MerchantShopList = MerchantShop
    :WaitForChild("List")

local function getCurrentTime()
    return DateTime.now().UnixTimestampMillis / 1000
end

local function getEmojiForEgg(eggName)
    local lowerName = string.lower(eggName)

    for key, emoji in pairs(emojiMap) do
        if string.find(lowerName, key, 1, true) then
            return emoji
        end
    end

    return defaultEmoji
end

local function getUniqueMentions(mentions)
    local output = {}
    local seen = {}

    for _, mention in ipairs(mentions) do
        if not seen[mention] then
            seen[mention] = true
            table.insert(output, mention)
        end
    end

    return table.concat(output, " ")
end

local function sendWebhookRequest(url, data)
    if not httprequest then
        return
    end

    if not url or url == "" or string.find(url, "PASTE_", 1, true) then
        return
    end

    local body = HttpService:JSONEncode(data)

    task.spawn(function()
        local success, result = pcall(function()
            return httprequest({
                Url = url,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = body
            })
        end)

        if not success then
            warn("Webhook request failed:", result)
            return
        end

        if result and result.StatusCode then
            if result.StatusCode < 200 or result.StatusCode >= 300 then
                warn(
                    "Webhook returned HTTP status:",
                    result.StatusCode
                )
            end
        end
    end)
end

local function sendEggWebhook()
    local descriptionLines = {}
    local mentions = {}

    for _, item in ipairs(EggShopList:GetChildren()) do
        if string.find(string.lower(item.Name), "egg", 1, true) then
            local stockLabel = item:FindFirstChild("Stock")
            local stockText = stockLabel and stockLabel.Text or "Unknown"

            if
                stockText ~= "Unknown"
                and not string.find(
                    string.upper(stockText),
                    "NO STOCK",
                    1,
                    true
                )
            then
                local cleanStock =
                    string.match(stockText, "x%d+")
                    or string.gsub(stockText, "\n", " ")

                local eggEmoji = getEmojiForEgg(item.Name)

                table.insert(
                    descriptionLines,
                    eggEmoji
                        .. " **"
                        .. item.Name
                        .. "**\n> 📦 Stock: `"
                        .. cleanStock
                        .. "`\n"
                )

                local lowerName = string.lower(item.Name)

                for key, roleId in pairs(roleMap) do
                    if string.find(lowerName, key, 1, true) then
                        table.insert(
                            mentions,
                            "<@&" .. roleId .. ">"
                        )
                    end
                end
            end
        end
    end

    local finalDescription =
        table.concat(descriptionLines, "\n")

    if finalDescription == "" then
        finalDescription =
            "❌ *No eggs currently in stock.*"
    end

    local uniqueMentions =
        getUniqueMentions(mentions)

    local data = {
        content = uniqueMentions ~= ""
                and uniqueMentions
            or nil,

        allowed_mentions = {
            parse = {
                "roles"
            }
        },

        embeds = {
            {
                title = "🏪 Egg Shop Restock",

                description = finalDescription,

                color = 16711680,

                image = {
                    url = "https://cdn.discordapp.com/attachments/1537331988720123935/1537334893397282896/ChatGPT_Image_13_de_ago._de_2026_02_39_49_1.png"
                },

                footer = {
                    text = "Updated"
                },

                timestamp =
                    os.date(
                        "!%Y-%m-%dT%H:%M:%SZ"
                    )
            }
        }
    }

    sendWebhookRequest(
        EGG_WEBHOOK,
        data
    )
end

local function sendGearWebhook()
    local descriptionLines = {}

    for _, item in ipairs(GearShopList:GetChildren()) do
        local stockLabel = item:FindFirstChild("Stock")

        if stockLabel then
            local stockText = stockLabel.Text

            if
                not string.find(
                    string.upper(stockText),
                    "NO STOCK",
                    1,
                    true
                )
            then
                local cleanStock =
                    string.match(stockText, "x%d+")
                    or string.gsub(stockText, "\n", " ")

                table.insert(
                    descriptionLines,
                    "⚒️ **"
                        .. item.Name
                        .. "**\n> 📦 Stock: `"
                        .. cleanStock
                        .. "`\n"
                )
            end
        end
    end

    local finalDescription =
        table.concat(descriptionLines, "\n")

    if finalDescription == "" then
        finalDescription =
            "❌ *No gears currently in stock.*"
    end

    local data = {
        embeds = {
            {
                title = "⚙️ Gear Shop Restock",

                description = finalDescription,

                color = 16711680,

                image = {
                    url = "https://cdn.discordapp.com/attachments/1537331988720123935/1537334893846204416/ChatGPT_Image_13_de_ago._de_2026_02_39_49_2.png"
                },

                footer = {
                    text = "Updated"
                },

                timestamp =
                    os.date(
                        "!%Y-%m-%dT%H:%M:%SZ"
                    )
            }
        }
    }

    sendWebhookRequest(
        GEAR_WEBHOOK,
        data
    )
end

local function sendWeatherWebhook()
    local activeWeathers = {}
    local mentions = {}

    for _, icon in ipairs(
        WeatherIconsFolder:GetChildren()
    ) do
        if table.find(validWeathers, icon.Name) then
            local mutationName =
                weatherMutations[icon.Name]

            local displayName =
                icon.Name

            local roleKey =
                icon.Name

            if mutationName then
                displayName =
                    icon.Name
                    .. " -> "
                    .. mutationName

                roleKey =
                    mutationName
            end

            table.insert(
                activeWeathers,
                "🌤️ **"
                    .. displayName
                    .. "**"
            )

            local roleId =
                weatherRoles[roleKey]

            if roleId then
                table.insert(
                    mentions,
                    "<@&"
                        .. roleId
                        .. ">"
                )
            end
        end
    end

    local finalDescription =
        table.concat(
            activeWeathers,
            "\n"
        )

    if finalDescription == "" then
        finalDescription =
            "☁️ *No special weather events active.*"
    end

    local uniqueMentions =
        getUniqueMentions(mentions)

    local data = {
        content =
            uniqueMentions ~= ""
                and uniqueMentions
            or nil,

        allowed_mentions = {
            parse = {
                "roles"
            }
        },

        embeds = {
            {
                title = "🌦️ Weather Status",

                description =
                    finalDescription,

                color = 16711680,

                image = {
                    url = "https://cdn.discordapp.com/attachments/1537331988720123935/1537334892818604053/ChatGPT_Image_13_de_ago._de_2026_02_39_49_4.png"
                },

                footer = {
                    text = "Updated"
                },

                timestamp =
                    os.date(
                        "!%Y-%m-%dT%H:%M:%SZ"
                    )
            }
        }
    }

    sendWebhookRequest(
        WEATHER_WEBHOOK,
        data
    )
end

local function getMerchantName()
    local world =
        Workspace:FindFirstChild("World")

    local mapFolder =
        world
        and world:FindFirstChild("Map")

    local npcsFolder =
        mapFolder
        and mapFolder:FindFirstChild("NPCs")

    local merchantNpc =
        npcsFolder
        and npcsFolder:FindFirstChild(
            "MerchantNPC"
        )

    if not merchantNpc then
        return "Unknown"
    end

    local attribute =
        merchantNpc:GetAttribute(
            "MerchantName"
        )

    if attribute then
        return tostring(attribute)
    end

    local value =
        merchantNpc:FindFirstChild(
            "MerchantName"
        )

    if
        value
        and value:IsA("StringValue")
    then
        return value.Value
    end

    return "Unknown"
end

local function sendMerchantWebhook()
    local merchantName =
        getMerchantName()

    local itemsList = {}
    local mentions = {}

    if merchantName ~= "Unknown" then
        for _, item in ipairs(
            MerchantShopList:GetChildren()
        ) do
            if
                item:IsA("Frame")
                or item:IsA("TextLabel")
                or item:IsA("ImageLabel")
            then
                local itemName =
                    item.Name

                if
                    itemName ~= "UIListLayout"
                    and itemName ~= "UIPadding"
                then
                    local stockLabel =
                        item:FindFirstChild("Stock")

                    local stockText =
                        stockLabel
                            and stockLabel.Text
                        or "Unknown"

                    if
                        stockText ~= "Unknown"
                        and not string.find(
                            string.upper(stockText),
                            "NO STOCK",
                            1,
                            true
                        )
                    then
                        local cleanStock =
                            string.match(
                                stockText,
                                "x%d+"
                            )
                            or string.gsub(
                                stockText,
                                "\n",
                                " "
                            )

                        table.insert(
                            itemsList,
                            "📦 **"
                                .. itemName
                                .. "**\n> 📦 Stock: `"
                                .. cleanStock
                                .. "`\n"
                        )

                        local roleId =
                            merchantItemRoles[
                                itemName
                            ]

                        if roleId then
                            table.insert(
                                mentions,
                                "<@&"
                                    .. roleId
                                    .. ">"
                            )
                        end
                    end
                end
            end
        end
    end

    local itemsDescription

    if merchantName == "Unknown" then
        itemsDescription =
            "*No merchant currently active.*"
    else
        itemsDescription =
            table.concat(
                itemsList,
                "\n"
            )

        if itemsDescription == "" then
            itemsDescription =
                "*No items currently available.*"
        end
    end

    local uniqueMentions =
        getUniqueMentions(
            mentions
        )

    local data = {
        content =
            uniqueMentions ~= ""
                and uniqueMentions
            or nil,

        allowed_mentions = {
            parse = {
                "roles"
            }
        },

        embeds = {
            {
                title =
                    "🧑‍💼 Merchant Status",

                description =
                    "🏷️ **Current Merchant:** `"
                    .. merchantName
                    .. "`\n\n"
                    .. "**Items in Stock:**\n"
                    .. itemsDescription,

                color =
                    16711680,

                image = {
                    url = "https://cdn.discordapp.com/attachments/1537331988720123935/1537334892382388244/ChatGPT_Image_13_de_ago._de_2026_02_39_49_3.png"
                },

                footer = {
                    text = "Updated"
                },

                timestamp =
                    os.date(
                        "!%Y-%m-%dT%H:%M:%SZ"
                    )
            }
        }
    }

    sendWebhookRequest(
        MERCHANT_WEBHOOK,
        data
    )
end

local eggRevision = 0
local gearRevision = 0
local weatherRevision = 0
local merchantRevision = 0

local watchedStocks = {}
local watchedItems = {}

local function isTextObject(instance)
    return
        instance:IsA("TextLabel")
        or instance:IsA("TextButton")
        or instance:IsA("TextBox")
end

local function watchStock(
    stock,
    revisionCallback
)
    if not stock then
        return
    end

    if watchedStocks[stock] then
        return
    end

    if not isTextObject(stock) then
        return
    end

    watchedStocks[stock] = true

    stock
        :GetPropertyChangedSignal("Text")
        :Connect(function()
            revisionCallback()
        end)
end

local function watchShopItem(
    item,
    revisionCallback
)
    if watchedItems[item] then
        return
    end

    watchedItems[item] = true

    watchStock(
        item:FindFirstChild("Stock"),
        revisionCallback
    )

    item.ChildAdded:Connect(function(child)
        if child.Name == "Stock" then
            watchStock(
                child,
                revisionCallback
            )

            revisionCallback()
        end
    end)
end

local function watchShopList(
    list,
    revisionCallback
)
    for _, item in ipairs(
        list:GetChildren()
    ) do
        watchShopItem(
            item,
            revisionCallback
        )
    end

    list.ChildAdded:Connect(function(item)
        watchShopItem(
            item,
            revisionCallback
        )

        revisionCallback()
    end)

    list.ChildRemoved:Connect(function()
        revisionCallback()
    end)
end

watchShopList(
    EggShopList,
    function()
        eggRevision += 1
    end
)

watchShopList(
    GearShopList,
    function()
        gearRevision += 1
    end
)

watchShopList(
    MerchantShopList,
    function()
        merchantRevision += 1
    end
)

WeatherIconsFolder.ChildAdded:Connect(function()
    weatherRevision += 1
end)

WeatherIconsFolder.ChildRemoved:Connect(function()
    weatherRevision += 1
end)

local function watchWeatherIcon(icon)
    icon:GetPropertyChangedSignal(
        "Name"
    ):Connect(function()
        weatherRevision += 1
    end)
end

for _, icon in ipairs(
    WeatherIconsFolder:GetChildren()
) do
    watchWeatherIcon(icon)
end

WeatherIconsFolder.ChildAdded:Connect(function(icon)
    watchWeatherIcon(icon)
end)

local watchedMerchantNPCs = {}

local function watchMerchantNPC(npc)
    if not npc then
        return
    end

    if watchedMerchantNPCs[npc] then
        return
    end

    if npc.Name ~= "MerchantNPC" then
        return
    end

    watchedMerchantNPCs[npc] = true

    npc:GetAttributeChangedSignal(
        "MerchantName"
    ):Connect(function()
        merchantRevision += 1
    end)

    local merchantNameValue =
        npc:FindFirstChild(
            "MerchantName"
        )

    if
        merchantNameValue
        and merchantNameValue:IsA(
            "StringValue"
        )
    then
        merchantNameValue
            :GetPropertyChangedSignal(
                "Value"
            )
            :Connect(function()
                merchantRevision += 1
            end)
    end

    npc.ChildAdded:Connect(function(child)
        if
            child.Name == "MerchantName"
            and child:IsA("StringValue")
        then
            child
                :GetPropertyChangedSignal(
                    "Value"
                )
                :Connect(function()
                    merchantRevision += 1
                end)

            merchantRevision += 1
        end
    end)
end

local function setupMerchantNPCWatcher()
    task.spawn(function()
        local world =
            Workspace:WaitForChild(
                "World"
            )

        local map =
            world:WaitForChild(
                "Map"
            )

        local npcs =
            map:WaitForChild(
                "NPCs"
            )

        local current =
            npcs:FindFirstChild(
                "MerchantNPC"
            )

        if current then
            watchMerchantNPC(
                current
            )
        end

        npcs.ChildAdded:Connect(function(child)
            if child.Name == "MerchantNPC" then
                watchMerchantNPC(child)

                merchantRevision += 1
            end
        end)

        npcs.ChildRemoved:Connect(function(child)
            if child.Name == "MerchantNPC" then
                merchantRevision += 1
            end
        end)
    end)
end

setupMerchantNPCWatcher()

GuiService.ErrorMessageChanged:Connect(function(errorMessage)
    if
        errorMessage
        and errorMessage ~= ""
    then
        local data = {
            embeds = {
                {
                    title =
                        "⚠️ Disconnected",

                    description =
                        "The player has been disconnected from the game.\n\n"
                        .. "**Reason:** `"
                        .. errorMessage
                        .. "`",

                    color =
                        16711680,

                    footer = {
                        text =
                            "Disconnected"
                    },

                    timestamp =
                        os.date(
                            "!%Y-%m-%dT%H:%M:%SZ"
                        )
                }
            }
        }

        sendWebhookRequest(
            EGG_WEBHOOK,
            data
        )
    end
end)

local function waitForRevisionChange(
    revisionGetter,
    oldRevision,
    timeout
)
    local deadline =
        getCurrentTime()
        + timeout

    while
        getCurrentTime()
        < deadline
    do
        if
            revisionGetter()
            ~= oldRevision
        then
            return true
        end

        task.wait(0.01)
    end

    return false
end

local function sendOnUpdate(
    revisionGetter,
    previousRevision,
    callback
)
    task.spawn(function()
        waitForRevisionChange(
            revisionGetter,
            previousRevision,
            1.5
        )

        callback()
    end)
end

local function sendInitialState()
    task.spawn(
        sendEggWebhook
    )

    task.spawn(
        sendGearWebhook
    )

    task.spawn(
        sendWeatherWebhook
    )

    task.spawn(
        sendMerchantWebhook
    )
end

sendInitialState()

task.spawn(function()
    while true do
        local now =
            getCurrentTime()

        local nextRestock =
            math.floor(
                now / 300
            ) * 300 + 300

        local snapshotTime =
            nextRestock - 0.25

        local waitBeforeSnapshot =
            snapshotTime
            - getCurrentTime()

        if waitBeforeSnapshot > 0 then
            task.wait(
                waitBeforeSnapshot
            )
        end

        local previousEggRevision =
            eggRevision

        local previousGearRevision =
            gearRevision

        local previousWeatherRevision =
            weatherRevision

        local previousMerchantRevision =
            merchantRevision

        local remaining =
            nextRestock
            - getCurrentTime()

        if remaining > 0 then
            task.wait(
                remaining
            )
        end

        local totalMinutes =
            math.floor(
                nextRestock / 60
            )

        local merchantRestock =
            totalMinutes % 10 == 0

        sendOnUpdate(
            function()
                return eggRevision
            end,
            previousEggRevision,
            sendEggWebhook
        )

        sendOnUpdate(
            function()
                return gearRevision
            end,
            previousGearRevision,
            sendGearWebhook
        )

        sendOnUpdate(
            function()
                return weatherRevision
            end,
            previousWeatherRevision,
            sendWeatherWebhook
        )

        if merchantRestock then
            sendOnUpdate(
                function()
                    return merchantRevision
                end,
                previousMerchantRevision,
                sendMerchantWebhook
            )
        end

        task.wait(2)
    end
end)

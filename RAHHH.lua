local choice = getgenv().Build or "Default"
local rfCF = getgenv().ReferenceCF or CFrame.new(146, 640, 16)
local cons = getgenv().Cons
local _types = {"Default", "JJS", "Blox Fruits"}
assert(table.find(_types, choice), "⚠️⚠️ Could not find Build inside types ⚠️⚠️")

--// Feel free to skid, just don't make it a paid script.
local NewLine = ('\n')

local function getspacelinetext(v)
    local result = ""
    for _ = 1, v do result = result .. NewLine end

    return result
end

cons[1]("LuaScript [1]")
print(getspacelinetext(3))
print("OFFICIAL SUPPORTED EXECUTORS"..NewLine.."1. Solara"..NewLine.."2. Argon"..NewLine.."3. Wave"..NewLine.."4. Any other free executor with FireServer, HTTP requests and HttpGet functions"..NewLine..""..NewLine..""..NewLine.."")

local function tsb_hidethemapplease()
    local hidearg = {
        [1] = {
            ["result"] = true,
            ["Goal"] = "VIP Server Power",
            ["power"] = "Hide Map"
        }
    }

    game:GetService("Players").LocalPlayer.Character.Communicate:FireServer(unpack(hidearg))
end

if choice == "Default" then
    cons[1]("[+] Loading default map. [You need to be in TSB to use this one!]")
    local _, isintsb = pcall(function()
        return game:GetService("Players").LocalPlayer.Character.Communicate
    end)
    if not _ and isintsb then
        cons[2](_format("[-] Could not find Communicate event for building, this can happen because you are not in the official TSB game.\n-- DEBUG --\nsuccess: %s\nerror: %s", tostring(_), tostring(isintsb)))
        return
    end

    task.wait(.5)
    local function generateSerial()
        local letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        local nums = "0123456789"
        local format = "%s-%s"

        local letterResult = ""
        for i = 1, 3 do
            local randomIndex = math.random(1, #letters)
            letterResult = letterResult .. letters:sub(randomIndex, randomIndex)
        end

        local numResult = ""
        for i = 1, 10 do
            local randomIndex = math.random(1, #nums)
            numResult = numResult .. nums:sub(randomIndex, randomIndex)
        end

        return string.format(format, letterResult, numResult)
    end

    local usedSerials = {}

    function create(part, isWall)
        local serial
        repeat
            serial = generateSerial()
        until not usedSerials[serial]
        usedSerials[serial] = true

        -- Skip parts like Spirals, Balls, Ornaments, and Unions cus they aint supported
        if part:IsA("UnionOperation") or part.Name:lower():find("spiral") or part.Name:lower():find("ball") or part.Name:lower():find("ornament") then
            return
        end

        if part:IsA("Model") then
            for _, child in ipairs(part:GetChildren()) do
                if child.Name ~= "TreeRoot" then
                    create(child)
                end
            end
            return 
        end

        local color = part.Name ~= "stadiumMesh" and part.Color or Color3.new(118 / 255, 113 / 255, 117 / 255)
        local cf = part.CFrame
        local mat = part.Material
        local size = part.Size

        local args = {
            [1] = {
                ["Color"] = color,
                ["Class"] = "Part",
                ["Todo"] = "Place",
                ["Goal"] = "PS Build",
                ["CFrame"] = cf,
                ["Properties"] = {
                    ["Anchored"] = true,
                    ["Collision"] = true,
                    ["Shadow"] = true
                },
                ["Material"] = mat,
                ["Serial"] = serial,
                ["Size"] = size
            }
        }
        
        game:GetService("Players").LocalPlayer.Character.Communicate:FireServer(unpack(args))

        if isWall then
            task.delay(0.2, function()
                cons[1]("[loadPlaceDebug]: Setting destructible property to True to the part due to it being a Wall.")
                task.wait()
                local args125215125252521 = {
                    [1] = {
                        ["Todo"] = "Property Change",
                        ["Goal"] = "PS Build",
                        ["List"] = {
                            [1] = {
                                ["Serial"] = serial
                            }
                        },
                        ["Property"] = "Destructible",
                        ["New"] = true
                    }
                }
                
                game:GetService("Players").LocalPlayer.Character.Communicate:FireServer(unpack(args125215125252521)) 
            end)
        end
    end

    for _, part in workspace.Map["Floor/Roads"].Stadium:GetChildren() do
        if part:IsA("BasePart") then
            create(part)
        end
    end

    create(workspace.Map.MainPart)
    for _, v in workspace.Map.Trees:GetChildren() do
        create(v)
    end

    for _, v in workspace.Map["Floor/Roads"].Railing:GetChildren() do
        create(v)
    end


    for _, v in workspace.Map.Walls:GetChildren() do 
        create(v) 
    end
    cons[1]("[+] Hiding map so the built one is visible")
    task.spawn(tsb_hidethemapplease)

elseif choice == "Blox Fruits" then
    cons[2]("[-] Blox Fruits' map is currently a W.I.P, this one will have up to the second sea due to third sea being huge [As of now], the map is not built and the script is not done.")
    return;
elseif choice == "JJS" then
    cons[1]("[=] There will be alot of debugging cus its a big map. (Soon this will be same debug level for Blox Fruits Map)")
    cons[1]("[+] Warning messages all uppercase inside of messages like '-- BEGIN DEBUG --' or '-- END DEBUG --' mean the script failed due to executor issue and is now debugging.")
    cons[1]("[?] Alright no more yapping the next message below me is the script getting JJS map metadata")
    cons[1]("[+] Rest of debugging will be logged into roblox real console")
    warn(getspacelinetext(15))
    print("[+] Getting JJS map metadata")

    __mapdataurl = "https://raw.githubusercontent.com/Solzzzz1/loadstrings/refs/heads/main/JJS_map_data.json"
    warn("[+] Making test request for validation to metadata")
    print(getspacelinetext(2))
    local testrequestforvalidation = request({
        Url = __mapdataurl,
        Method = "GET"
    })

    if not testrequestforvalidation.StatusCode == 200 then
        local copied = false
        warn("-- BEGIN DEBUG --")
        warn(_format("-- STATUS CODE '%s' --", tostring(testrequestforvalidation.StatusCode)))
        warn(_format("-- EXECUTOR '%s' --", identifyexecutor()))
        warn("-- END DEBUG --")
        print("[¿] To copy the GITHUB link, press 'K' to set the link to your clipboard. (Your executor needs setclipboard)")
        game:GetService("Players").LocalPlayer:GetMouse().KeyDown:Connect(function(k)
            if k:lower() == "k" and not copied then
                copied = true
                setclipboard(__mapdataurl)
                print("[+] Copied GITHUB link [JJS_map_data.json]")
            end
        end)
        return
    end

    print("[+] Test request for validation has passed and StatusCode is 200 (Success)")
    print("[=] Messages below are referencing to getting map's metadata and writing the data to a .json file")
    local mdata = game:HttpGet(__mapdataurl)
    local mapdatanew = writefile("JJS.json", mdata)
    task.wait(.3)
    warn("[=] Wrote file 'JJS.json' to workspace (" .. tostring(mapdatanew) .. ")")
    warn("[*] Awesomeness. OK.. ☆*: .｡. o(≧▽≦)o .｡.:*☆")
    
    local usedSerials = {}

    local function generateSerial()
        local letters = ""
        for i = 1, 3 do
            letters = letters .. string.char(math.random(65, 90 + (math.random(0, 1) * 32)))
        end
    
        local numbers = ""
        for i = 1, 10 do
            numbers = numbers .. tostring(math.random(0, 9))
        end
    
        return letters .. "-" .. numbers
    end
    
    local function getUniqueSerial()
        local serial
        repeat
            serial = generateSerial()
        until not usedSerials[serial]
        usedSerials[serial] = true
        return serial
    end          

    -- i also need to fix getting shapes
    -- the bug is due to how json saves Enums work, as for material Enum.Material.Wood it would say "null" in .json
    -- so we can convert that shape's name to a string and it'll work, afterwards we can check the shape name and check if its wedge, if it is creates a wedgepart instead of a part

    local HttpService = game:GetService("HttpService")
    local notificationService = game:GetService("StarterGui")
    local player = game.Players.LocalPlayer
    local screenGui = Instance.new("ScreenGui")
    local textLabel = Instance.new("TextLabel")

    screenGui.Parent = player:WaitForChild("PlayerGui")
    textLabel.Size = UDim2.new(0, 300, 0, 50)
    textLabel.Position = UDim2.new(0.5, -150, 0, 20)
    textLabel.BackgroundTransparency = 0.85
    textLabel.BackgroundColor3 = Color3.fromRGB(60,60,60)
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextSize = 18
    textLabel.Text = "Loading Part: None" .. NewLine .. "(made by g3tbytec0de)"
    textLabel.Parent = ScreenGui

    _format = string.format;

    print("[LuaScript.lua]: Everything is fine, created label to reference current created part and defined serial functions.")
    print("[LuaScript.lua]: The script is starting to define load_parts_from_json")
    local function loadPartsFromJson()
        print("[load_parts_from_json]: Loading process started, first step is to read the map's metadata.")
        local _, isintsb = pcall(function()
            return game:GetService("Players").LocalPlayer.Character.Communicate
        end)
        if not _ and isintsb then
            warn("[?] Error detected inside load_parts_from_json")
            print(getspacelinetext(3))
            warn(_format("[-] Could not find Communicate event for building, this can happen because you are not in the official TSB game.\n-- DEBUG --\nsuccess: %s\nerror: %s", tostring(_), tostring(isintsb)))
            return
        end

        local jsonString
        local WriteJsonString, WriteJsonStr1ng = pcall(function()
            jsonString = readfile(mapdatanew)
        end)

        print("[load_parts_from_json] Starting WriteJsonString, WriteJsonStr1ng checks.")
        if not WriteJsonString and WriteJsonStr1ng then
            warn("-- BEGIN DEBUG --")
            warn(_format("-- SUCCESS: '%s' -- (T = True, F = False)", (WriteJsonString == true and "T" or "F")))
            warn(_format("-- ERROR: '%s' --", tostring(WriteJsonStr1ng)))
            warn(_format("-- CURRENT TIME: %s --", tostring(os.time())))
            warn("-- END DEBUG --")
            print("[WriteJson]: Error - Could not read the file of the metadata [mapdatanew], this can be caused by the 'readfile' function being nil.")
            return
        end

        print("[load_parts_from_json] Passed WriteJsonString, WriteJsonStr1ng, no errors were found in the process.")

        print("[load_parts_from_json]: Reached jsonString check, we are now checking for the jsonString being invalid.")
        if not jsonString or jsonString == "" or jsonString == " " or not #jsonString > 0 then
            notificationService:SetCore("SendNotification", {
                Title = "Error",
                Text = "No saved parts data found. [Check console for information]",
                Duration = 5
            })
            warn("-- BEGIN DEBUG --")
            warn(_format("-- JSON STRING: '%s' --", jsonString))
            warn(_format("-- JSON STRING LENGTH IS %s --", tostring(#jsonString)))
            warn("-- BLANK STRING CHECKS --")
            warn(_format("-- IS JSON STRING COMPLETE BLANK: '%s' (t being True, f being False)", (jsonString == "" and "t" or "f")));
            warn(_format("-- IS JSON STRING 1 SPACE BLANK: '%s' (t being True, f being False)", (jsonString == " " and "t" or "f")));
            warn("-- END DEBUG --")
            print("[load_parts_from_json]: Error - No saved parts data found. [Disconnection or bad internet connection can cause this]")
            return
        end
        print("[load_parts_from_json]: Everything is fine with the jsonString, the script will now decode the jsonString and start the build process.")

        local partsData = HttpService:JSONDecode(jsonString)
        local referenceCFrame = CFrame.new(146, 950, 16) -- default

        notificationService:SetCore("SendNotification", {
            Title = "Loading Parts",
            Text = "Parts have been referenced, the script will shortly start to debug and build the map.\nEverything will be debugged into the console including errors.",
            Duration = 5
        })

        print("[LuaScript.lua]: Decoding JSON Data")
        print("[LuaScript.lua]: Loading M_DATA")

        local current_serial = "fuk-1234567890" -- # placeholder

        for _, partData in pairs(partsData) do
            if partData.name == "DebreeRef" then
                warn("[LuaScript.lua]: Skipping DebreeRef part as it is blacklisted. [1]")
            end
            if partData.name ~= "DebreeRef" then
                current_serial = getUniqueSerial()
                textLabel.Text = "Loading Part: " .. partData.name

                local newPart = Instance.new("Part")
                newPart.Name = partData.name
                newPart.Size = Vector3.new(partData.size.x, partData.size.y, partData.size.z)
                newPart.Color = Color3.fromRGB(partData.color.r, partData.color.g, partData.color.b)
                newPart.Material = Enum.Material[partData.material]
                newPart.Transparency = partData.transparency
                newPart.Anchored = partData.anchored
                newPart.CanCollide = partData.canCollide

                local newPosition = referenceCFrame.Position + Vector3.new(partData.position.x, partData.position.y, partData.position.z)
                newPart.Position = newPosition

                local newCFrame = CFrame.new(newPosition, newPosition + Vector3.new(partData.cframe.lookVector.x, partData.cframe.lookVector.y, partData.cframe.lookVector.z))
                newPart.CFrame = newCFrame

                newPart.Parent = workspace

                local args = {
                    [1] = {
                        ["Color"] = Color3.new(partData.color.r / 255, partData.color.g / 255, partData.color.b / 255),
                        ["Class"] = "Part",
                        ["Todo"] = "Place",
                        ["Goal"] = "PS Build",
                        ["CFrame"] = newCFrame,
                        ["Properties"] = {
                            ["Anchored"] = true,
                            ["Collision"] = true,
                            ["Shadow"] = true
                        },
                        ["Material"] = Enum.Material[partData.material],
                        ["Serial"] = current_serial,
                        ["Size"] = Vector3.new(partData.size.x, partData.size.y, partData.size.z)
                    }
                }

                game:GetService("Players").LocalPlayer.Character.Communicate:FireServer(unpack(args))
                local r, g, b
                local mf = math.floor
                local clr = newPart.Color
                r, g, b = mf(clr.R * 255), mf(clr.G * 255), mf(clr.B * 255)

                local targetColor1 = Color3.fromRGB(175, 221, 255)
                local targetColor2 = Color3.fromRGB(152, 193, 255)
                local currentColor = Color3.fromRGB(r, g, b)

                if (math.abs(currentColor.R - targetColor1.R) < 0.01 and
                    math.abs(currentColor.G - targetColor1.G) < 0.01 and
                    math.abs(currentColor.B - targetColor1.B) < 0.01) or
                (math.abs(currentColor.R - targetColor2.R) < 0.01 and
                    math.abs(currentColor.G - targetColor2.G) < 0.01 and
                    math.abs(currentColor.B - targetColor2.B) < 0.01) then
                    print(_format("[loadPlaceDebug]: changed transparency to 0.85 for serial '%s' due to being close to a glass part", current_serial))
                    local args = {
                        [1] = {
                            ["Todo"] = "Property Change",
                            ["Goal"] = "PS Build",
                            ["List"] = {
                                [1] = {
                                    ["Serial"] = current_serial
                                }
                            },
                            ["Property"] = "Transparency",
                            ["New"] = "0.85"
                        }
                    }

                    game:GetService("Players").LocalPlayer.Character.Communicate:FireServer(unpack(args))  
                    task.wait(0.01)
                    print(_format("[loadPlaceDebug]: changed parts material to glass due to being close to a glass part (serial '%s')", current_serial))
                    local args = {
                        [1] = {
                            ["List"] = {
                                [1] = {
                                    ["Serial"] = current_serial
                                }
                            },
                            ["Todo"] = "Change Material",
                            ["Goal"] = "PS Build",
                            ["New"] = "Glass"
                        }
                    }

                    game:GetService("Players").LocalPlayer.Character.Communicate:FireServer(unpack(args))
                end
                


                task.wait(0.01)
                newPart:Destroy()
            end
        end

        print(_format("[loadPlace]: Succesfully loaded, took %s seconds", tostring(begin - os.time())))
        print("[loadPlace]: The original map has been loaded")
        task.spawn(tsb_hidethemapplease)
    end
    local func_bytecode
    pcall(function()
        if getfunctionbytecode then
            local BRUV,BRUVVVVV = pcall(function()
                func_bytecode = getfunctionbytecode(loadPartsFromJson)
            end)
            if not BRUV then
                func_bytecode = "No bytecode found (bytecode function failed)"
            end
        else
            func_bytecode = "No bytecode found (bytecode is nil)"
        end 
    end)

    print("[+] The script has finished referencing the load_parts_from_json function, here's the info below:")
    print(_format("[+] Function hash: %s", string.gsub(tostring(loadPartsFromJson), "function: ", "")))
    print(_format("[+] Function bytecode (if the function exists): %s", tostring(func_bytecode)))
    print("[=] Alright enough yap the load_parts_from_json function is getting called now.")
    print("[=] I will quickly flood the console so you can see other debugs easier.")
    for i=1,50 do 
        print("\n\n\n")
        task.wait()
    end
    loadPartsFromJson()
end

for i=1,50 do 
    print("\n\n\n")
    task.wait()
end

print("[=] To build another map, refresh private server, re-run the .py script and execute the script again.")

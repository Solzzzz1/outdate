local players = game:GetService("Players")
local filename = "day_time_ambiance.mp3"

local audio_data = game:HttpGet("https://github.com/Solzzzz1/outdate/blob/main/day%20time%20ambiance.mp3?raw=true")
writefile(filename, audio_data)

local asset_id = getcustomasset(filename)

local sound = Instance.new("Sound")
sound.Name = "DayTimeAmbiancePlayback"
sound.SoundId = asset_id
sound.Volume = 0.7
sound.PlaybackSpeed = 1
sound.Looped = true -- Set to true so your world ambiance keeps looping smoothly
sound.Parent = players.LocalPlayer:WaitForChild("PlayerGui")

sound:Play()

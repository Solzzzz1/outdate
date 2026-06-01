local players = game:GetService("Players")
local filename = "amongus.mp3"

local audio_data = game:HttpGet("https://github.com/Solzzzz1/outdate/blob/main/%F0%9D%98%BF%F0%9D%99%85%20%F0%9D%99%8D%F0%9D%98%BC%F0%9D%99%90%F0%9D%99%87%F0%9D%99%84%F0%9D%99%8B%F0%9D%99%90%F0%9D%99%80%F0%9D%99%8E%20-%20%F0%9D%98%BC%F0%9D%99%89%F0%9D%98%BC%F0%9D%99%87%F0%9D%99%8A%F0%9D%99%82%20%F0%9D%99%83%F0%9D%99%8A%F0%9D%99%8D%F0%9D%99%8D%F0%9D%99%8A%F0%9D%99%8D%20%F0%9D%99%81%F0%9D%99%90%F0%9D%99%89%F0%9D%99%86%20%F0%9D%99%AD%20%F0%9D%99%8E%F0%9D%99%84%F0%9D%99%93%20%F0%9D%99%8E%F0%9D%99%80%F0%9D%99%91%F0%9D%99%80%F0%9D%99%89%20(67)%20%F0%9D%99%80%F0%9D%98%BF%F0%9D%99%84%F0%9D%99%8F%20%20%F0%9D%99%8F%F0%9D%99%84%F0%9D%99%86%F0%9D%99%8F%F0%9D%99%8A%F0%9D%99%86%20%F0%9D%99%91%F0%9D%99%80%F0%9D%99%8D%F0%9D%99%8E%F0%9D%99%84%C3%93%F0%9D%99%89.mp3?raw=true")
writefile(filename, audio_data)

local asset_id = getcustomasset(filename)

local sound = Instance.new("Sound")
sound.Name = "DayTimeAmbiancePlayback"
sound.SoundId = asset_id
sound.Volume = .5
sound.PlaybackSpeed = 1
sound.Looped = true -- Set to true so your world ambiance keeps looping smoothly
sound.Parent = players.LocalPlayer:WaitForChild("PlayerGui")

sound:Play()

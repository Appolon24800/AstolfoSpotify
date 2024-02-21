local name = 'Spotify'
local prefix = "@"
local skipedtracker
local CheckDelay = 7 -- In seconds, 7 is good
local artistsId, artistsName, artistsUrl
local duration, playing, progress
local track, trackId, trackImage
local oldtrack
local truncatedtext
local elapsedtime = 0 
local url = "http://localhost:3000/spotify/"
local lastfetch = 0
local lasttexttruncated = client.time()
local lastscreenrender = client.time()
local dummydata = '{"Artists":[{"ID":"5K4W6rqBFWDnAN6FQUkS6x","Name":"Kanye West","Url":"https://open.spotify.com/artist/5K4W6rqBFWDnAN6FQUkS6x"}],"Device":{"Name":"APPOLON","Type":"Computer","Volume":100},"Duration":243440,"Playing":true,"Progress":21431,"Track":"I Wonder","TrackID":"7rbECVPkY5UODxoOUVKZnA","TrackImage":"https://i.scdn.co/image/ab67616d0000b27326f7f19c7f0381e56156c94a"}'
local testing = false

function print(str)
    client.print('\194\1672[\194\167aSpotify\194\1672]\194\167r ' .. tostring(str))
end

function handledata(data)
    if not data then
        print('The backend returned nothing')
        player.message(".spotify")
    end

    if data == '{"Track":null}' then
        print('You are listening to nothing')
        player.message(".spotify")
    end

    if data == 'Impossible to fetch informations from spotify' then
        print('Impossible to fetch informations from spotify')
        player.message(".spotify")
    end

    elapsedtime = 0
    
    oldtrack = track
    artistsId, artistsName, artistsUrl = data:match('"ID":"(.-)","Name":"(.-)","Url":"(.-)"')
    duration, playing, progress = data:match('"Duration":(%d+),"Playing":([^,]+),"Progress":(%d+)')
    track, trackId, trackImage = data:match('"Track":"(.-)","TrackID":"(.-)","TrackImage":"(.-)"')
    
    playing = playing == "true" and true or false

    if track ~= oldtrack then
        truncatedtext = track .. "      "

        if module_manager.option(name, "Print (Print informations)") then 
            print("Now listening to \194\167l" .. track .. "\194\167r by \194\167l" .. artistsName) 
        end

    end
    
end

function fiximagecolor()
    if module_manager.is_module_on("array") then
        player.message(".array")
        player.message(".array")
    end
    if module_manager.is_module_on("overlay") then
        player.message(".overlay")
        player.message(".overlay")
    end
    if module_manager.is_module_on("height-indicator") then
        player.message(".height-indicator")
        player.message(".height-indicator")
    end
    if module_manager.is_module_on("blinkindicator") then
        player.message(".blinkindicator")
        player.message(".blinkindicator")
    end
end

function UnicodeDecode(str)
    return (str:gsub("\\u(%x%x%x%x)", function (unicode)
        local codepoint = tonumber(unicode, 16)
        if codepoint <= 0x7F then
            return string.char(codepoint)
        elseif codepoint <= 0x7FF then
            local byte1 = 0xC0 + math.floor(codepoint / 0x40)
            local byte2 = 0x80 + codepoint % 0x40
            return string.char(byte1, byte2)
        elseif codepoint <= 0xFFFF then
            local byte1 = 0xE0 + math.floor(codepoint / 0x1000)
            local byte2 = 0x80 + math.floor((codepoint % 0x1000) / 0x40)
            local byte3 = 0x80 + codepoint % 0x40
            return string.char(byte1, byte2, byte3)
        else
            return string.char(0xEF, 0xBF, 0xBD)
        end
    end):gsub("\\", ""))

end

function fetchapi()
    if client.time() - lastfetch < CheckDelay * 1000 then
        return
    end
    lastfetch = client.time()
    if module_manager.option(name, "debug") then
        print("Data fetched (" .. lastfetch .. ")")
    end

    if testing then
        handledata(UnicodeDecode(dummydata))
        return
    end

    http.get_async(url, { run = function(text)handledata(UnicodeDecode(text)) end })  
end

function formatpd(d, p)

    if not playing then
        return "Paused"
    end

    if not d then
        return "error"
    end

    local duration = d / 1000
    local progress = p / 1000 + elapsedtime
    
    local durationm = math.floor(duration / 60)
    local durations = math.floor(duration % 60)

    local progressm = math.floor(progress / 60)
    local progresss = math.floor(progress % 60)

    if progress >= duration then
        return string.format("%d:%02d - %d:%02d", durationm, durations, durationm, durations)
    end

    return string.format("%d:%02d - %d:%02d", progressm, progresss, durationm, durations)
end


function truncateText(text)
    if client.time() - lasttexttruncated >= 199 then
        lasttexttruncated = client.time()

        if render.get_string_width(text) >= 100 then
            truncatedtext = truncatedtext:sub(2) .. truncatedtext:sub(1, 1)
            return truncatedtext:sub(1, 18)
        end
    end
    return truncatedtext:sub(1, 18)
end


local spotify = {
    on_enable = function()
        fetchapi()
        if module_manager.option(name, "debug") then print('Enabled') end
    end,

    on_send_packet = function(e)

        if module_manager.option(name, "reload") then
            artistsId, artistsName, artistsUrl = nil, nil, nil
            duration, playing, progress = nil, nil, nil
            track, trackId, trackImage = nil, nil, nil
            oldtrack = nil
            elapsedtime = 0
            truncatedtext = nil
            lastfetch = 0
            track = nil
            url = nil
            lasttexttruncated = client.time()
            lastscreenrender = client.time()

            fetchapi()
            print("Reloaded")
            module_manager.set_option(name, "reload", false)
        end

        if module_manager.option(name, "") then module_manager.set_option(name, "", false) end
        if module_manager.option(name, " ") then module_manager.set_option(name, " ", false) end
        if module_manager.option(name, "  ") then module_manager.set_option(name, "  ", false) end
        if module_manager.option(name, "\194\1677Text") then module_manager.set_option(name, "\194\1677Text", false) end
        if module_manager.option(name, "\194\1677General") then module_manager.set_option(name, "\194\1677General", false) end
        if module_manager.option(name, "\194\1677Don't change") then module_manager.set_option(name, "\194\1677Don't change", false) end
        if module_manager.option(name, "\194\1676Spotify overlay by Appolon") then module_manager.set_option(name, "\194\1676Spotify overlay by Appolon", false) end

        if not e.message then return e end
        if not module_manager.option(name, "Chat (Commands like " .. prefix .. "song)") then return e end
        if string.sub(e.message, 1, 1) ~= prefix then return e end
        
        local command = string.gsub(e.message:lower(), "%s", ""):gsub("[^a-z]", "")

        if command == 'pause' then
            if playing then playing = false else playing = true end
            if track then
                print("Paused \194\167l" .. track .. "\194\167r")
            end
            http.get_async(url .. "pause", { run = function(text) end })
        
        elseif command == 'skip' then
            if track then
                print('Skiping \194\167l' .. track .. "\194\167r of \194\167l" .. artistsName .. "\194\167r")
                http.get_async(url .. "skip", { run = function(text) end })
            end
        elseif command == 'rewind' then
            http.get_async(url .. "rewind", { run = function(text) end })
        elseif command == 'trackurl' then
            player.message("https://open.spotify.com/track/" .. tostring(trackId))

        elseif command == 'artisturl' then
            player.message("https://open.spotify.com/artist/" .. tostring(artistsId))

        elseif command == 'track' then
            player.message(track)

        elseif command == 'song' then
            player.message("I am listening to \"" .. tostring(track) .. "\" by " .. tostring(artistsName))

        elseif command == 'artist' then
            player.message(artistsName)
        
        elseif command == 'help' then
            client.print('      ')
            print('      ')
            print('   \194\167aSpotify script\194\167r - \194\1676by appolon\194\167r   ')
            print('      ')
            print('\194\1672' .. prefix .. '\194\167apause\194\167f: Pause the current music')
            print('\194\1672' .. prefix .. '\194\167askip\194\167f: Skip the current music')
            print('\194\1672' .. prefix .. '\194\167arewind\194\167f: Rewind the current track to the beginning')
            print('\194\1672' .. prefix .. '\194\167atrack\194\167f: Send the track name in the chat')
            print('\194\1672' .. prefix .. '\194\167atrackurl\194\167f: Music\'s spotify link')
            print('\194\1672' .. prefix .. '\194\167asong\194\167f: I am listening to ... by ...')
            print('\194\1672' .. prefix .. '\194\167aartist\194\167f: Send the artist name in the chat')
            print('\194\1672' .. prefix .. '\194\167aartisturl\194\167f: Spotify artist\'s link')
        else
            print('Unknown command. Try "' .. prefix .. 'help" for help')
        end

        e.cancel = true
        return e
    end,

    on_render_screen = function(e)
        os.exit()
        if client.time() - lastfetch >= 12000 then
            fetchapi()
        end

        if not module_manager.option(name, "Image (Show the album)") then return end

        if not trackImage or not track or not artistsName or not duration or not progress then return end

        if client.time() - lastscreenrender >= 1000 then
            elapsedtime = elapsedtime + 1
            lastscreenrender = client.time()

            if module_manager.option(name, "debug")  then
                client.print('')
                client.print('\194\1677------------------------------------------\194\167r')
                print("Track: " .. track .. "   (" .. render.get_string_width(track) .. ")")
                --print("TTracker: " .. truncatedtext:sub(1, 18) .. "   (" .. render.get_string_width(truncatedtext:sub(1, 18)) .. ")")
                print("Artist: " .. artistsName .. "  (" .. render.get_string_width(artistsName) .. ")")
                print("Time: " .. formatpd(duration, progress))
                print("Image: " .. trackImage)
                --print("URL: " .. url or "false")
                client.print('\194\1677------------------------------------------\194\167r')
                client.print('')
            end

        end

        local X = module_manager.option(name, "X")
        local Y = module_manager.option(name, "Y")

        fiximagecolor()
        render.draw_image(trackImage, X, Y, 180, 180)
        if module_manager.option(name, "Text Shadow") then
            render.string_shadow(truncateText(track), X + 5, Y + 5, module_manager.option(name, "R"), module_manager.option(name, "G"), module_manager.option(name, "B"), 255)
            render.string_shadow(artistsName, X + 5, Y + 18, module_manager.option(name, "R"), module_manager.option(name, "G"), module_manager.option(name, "B"), 255)
            render.string_shadow(formatpd(duration, progress), X + 5, Y + 95, module_manager.option(name, "R"), module_manager.option(name, "G"), module_manager.option(name, "B"), 255)
        else
            render.string(truncateText(track), X + 5, Y + 5, module_manager.option(name, "R"), module_manager.option(name, "G"), module_manager.option(name, "B"), 255)
            render.string(artistsName, X + 5, Y + 18, module_manager.option(name, "R"), module_manager.option(name, "G"), module_manager.option(name, "B"), 255)
            render.string(formatpd(duration, progress), X + 5, Y + 95, module_manager.option(name, "R"), module_manager.option(name, "G"), module_manager.option(name, "B"), 255)
        end
        fiximagecolor()

        if input.is_mouse_down(0) then
            if client.gui_name() == "chat" then
                if e.mouse_x >= X and e.mouse_x <= X + 112.5 and e.mouse_y >= Y and e.mouse_y <= Y + 112.5 then
                    render.rect(X, Y, X + 112.5, Y + 112.5, 64, 64, 64, 120)

                    render.line(X, Y, X + 112.5, Y, 3, 255, 255, 255, 255)
                    render.line(X + 112.5, Y, X + 112.5, Y + 112.5, 3, 255, 255, 255, 255)
                    render.line(X + 112.5, Y + 112.5, X, Y + 112.5, 3, 255, 255, 255, 255)
                    render.line(X, Y + 112.5, X, Y, 3, 255, 255, 255, 255)

                    player.message('.spotify X ' .. math.floor(e.mouse_x - 45))
                    player.message('.spotify Y ' .. math.floor(e.mouse_y - 45))
                end
            end
        end

    end
} 

module_manager.register(name, spotify)
module_manager.register_boolean(name, "\194\1676Spotify overlay by Appolon", false)
module_manager.register_boolean(name, "", false)
module_manager.register_boolean(name, "\194\1677General", false)
module_manager.register_boolean(name, "Print (Print informations)", true)
module_manager.register_boolean(name, "Chat (Commands like " .. prefix .. "song)", true)
module_manager.register_boolean(name, "Image (Show the album)", false)
module_manager.register_boolean(name, " ", false)
module_manager.register_boolean(name, "\194\1677Text", false)
module_manager.register_boolean(name, "Text Shadow", true)
module_manager.register_number(name, "R", 0, 255, 255)
module_manager.register_number(name, "G", 0, 255, 255)
module_manager.register_number(name, "B", 0, 255, 255)
module_manager.register_boolean(name, "  ", false)
module_manager.register_boolean(name, "\194\1677Don't change", false)
module_manager.register_boolean(name, "reload", false)
module_manager.register_boolean(name, "debug", false)
module_manager.register_number(name, "Y", 0, 1500, 5)
module_manager.register_number(name, "X", 0, 1500, 5)
print('Script made by \194\167lappolon\194\167r | \194\167lhttps://appolon.dev\194\167r')

-- Made by appolon 
-- You can find the backend here: https://github.appolon.dev
-- https://appolon.dev

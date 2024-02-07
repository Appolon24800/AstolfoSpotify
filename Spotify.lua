local name = 'Spotify'
local artistsId, artistsName, artistsUrl
local duration, playing, progress
local track, trackId, trackImage
local oldtrack
local truncatedtext
local elapsedtime = 0
local url
local lastfetch = 0
local lasttexttruncated = client.time()
local lastscreenrender = client.time()


local data_test = '{"Artists":[{"ID":"5K4W6rqBFWDnAN6FQUkS6x","Name":"Kanye West","Url":"https://open.spotify.com/artist/5K4W6rqBFWDnAN6FQUkS6x"}],"Device":{"Name":"APPOLON","Type":"Computer","Volume":100},"Duration":243440,"Playing":true,"Progress":21431,"Track":"I Wonder","TrackID":"7rbECVPkY5UODxoOUVKZnA","TrackImage":"https://i.scdn.co/image/ab67616d0000b27326f7f19c7f0381e56156c94a"}'
local BackendURL_DEV = "http://192.168.0.29:8080/api/index/spotify" 
local BackendURL_HOST = "http://localhost:3000/spotify"
local testing = false

function print(str)
    client.print('\194\1672[\194\167aSpotify\194\1672]\194\167r ' .. tostring(str))
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
    end))
end

function fetchapi()

    if module_manager.option(name, "dev") then
        url = BackendURL_DEV
    else
        url = BackendURL_HOST
    end

    if testing then
        data = UnicodeDecode(data_test)

        oldtrack = track
        artistsId, artistsName, artistsUrl = data:match('"ID":"(.-)","Name":"(.-)","Url":"(.-)"')
        duration, playing, progress = data:match('"Duration":(%d+),"Playing":([^,]+),"Progress":(%d+)')
        track, trackId, trackImage = data:match('"Track":"(.-)","TrackID":"(.-)","TrackImage":"(.-)"')
        
        playing = playing == "true" and true or false

        if track ~= oldtrack or not track then
            truncatedtext = track .. "      "

            if module_manager.option(name, "print (Print informations)") then 
                print("Now listening to \194\167l" .. track .. "\194\167r by \194\167l" .. artistsName) 
            end

        end

        return
    end

    if client.time() - lastfetch <= 10000 then
        return
    end

    lastfetch = client.time()

    http.get_async(url, {
        run = function(text)
            data = UnicodeDecode(text)

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
            if string.find(data, "<title>429 Too Many Requests</title>") then
                if module_manager.option(name, "debug") then print('Rate limited') end
                lastfetch = client.time() + 60
                return
            end
            
            oldtrack = track
            artistsId, artistsName, artistsUrl = data:match('"ID":"(.-)","Name":"(.-)","Url":"(.-)"')
            duration, playing, progress = data:match('"Duration":(%d+),"Playing":([^,]+),"Progress":(%d+)')
            track, trackId, trackImage = data:match('"Track":"(.-)","TrackID":"(.-)","TrackImage":"(.-)"')
            
            playing = playing == "true" and true or false

            if track ~= oldtrack or not track then
                truncatedtext = track .. "      "

                if module_manager.option(name, "print (Print informations)") then 
                    print("Now listening to \194\167l" .. track .. "\194\167r by \194\167l" .. artistsName) 
                end

            end
            
            if module_manager.option(name, "debug") then print('Data fetched') end

        end

    })  
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
        if not module_manager.option(name, "chat (Commands like @song)") then return e end
        if string.sub(e.message, 1, 1) ~= "@" then return e end
        
        local command = e.message:lower()


        if string.find(command, '@pause') then
            -- url .. "/pause"
            print("Pause command is planned")
        elseif string.find(command, '@skip') then
            -- url .. "/skip"
            print("Skip command is planned")
        elseif string.find(command, '@trackurl') then
            player.message("https://open.spotify.com/track/" .. trackId)
        elseif string.find(command, '@artisturl') then
            player.message("https://open.spotify.com/artist/" .. artistsId)
        elseif string.find(command, '@track') then
            player.message(track)
        elseif string.find(command, '@song') then
            player.message("I am listening to \"" .. track .. "\" by " .. artistsName)
        elseif string.find(command, '@artist') then
            player.message(artistsName)
        else
            print('Invalid command')
        end

        e.cancel = true
        return e
    end,

    on_render_screen = function(e)

        if client.time() - lastfetch >= 10000 then
            fetchapi()
        end

        if not module_manager.option(name, "image (Show the album)") then return end

        if not trackImage or not track or not artistsName or not duration or not progress then
            fetchapi()
            return
        end

        if client.time() - lastscreenrender >= 999 then
            elapsedtime = elapsedtime + 1
            lastscreenrender = client.time()

            if module_manager.option(name, "debug")  then
                client.print('')
                client.print('\194\1677------------------------------------------\194\167r')
                print("Track: " .. track .. "   (" .. render.get_string_width(track) .. ")")
                print("Artist: " .. artistsName .. "  (" .. render.get_string_width(artistsName) .. ")")
                print("Time: " .. formatpd(duration, progress))
                print("Image: " .. tostring(not (trackImage == nil)))
                print("URL: " .. url or "false")
                print("Ttrack: " .. truncatedtext:sub(1, 18) .. "   (" .. render.get_string_width(truncatedtext:sub(1, 18)) .. ")")
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
module_manager.register_boolean(name, "print (Print informations)", true)
module_manager.register_boolean(name, "chat (Commands like @song)", true)
module_manager.register_boolean(name, "image (Show the album)", false)
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
module_manager.register_boolean(name, "dev", false)
module_manager.register_number(name, "Y", 0, 1500, 5)
module_manager.register_number(name, "X", 0, 1500, 5)
print('Script made by \194\167lappolon\194\167r | \194\167lhttps://appolon.dev\194\167r')

-- Made by appolon 
-- You can find the backend here: https://github.appolon.dev
-- https://appolon.dev

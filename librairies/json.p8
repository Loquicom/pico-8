pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

function _init()
    debug = "null"
    src = '["plouf",{"tab":["val1",{"test":true,"aaa":{}}]}]'
    res = parse(src)
end

function _update()

end

function _draw()
    cls()
    print(count(res[2].tab[2].aaa),2,2,7)
end

function strlen(str)
    local i = 1
    while str[i] do i += 1 end
    return i-1
end

-- Work only with mimified JSON
function parse(json)
    assert(json[1] == "{" or json[1] == "[", "invalid json - missing { or [ at start")
    if json[1] == "{" then
        return parse_object(json, 2)
    end
    return parse_array(json, 2)
end

function parse_object(json, i)
    if (json[i] == '}') return {}
    assert(json[i] == '"', 'invalid json - missing " before key')
    local obj = {}
    while json[i] != "}" do
        -- Extract key
        i += 1
        local key = ""
        while json[i] != '"' do
            key = key..json[i]
            i += 1
        end
        -- Extract value
        assert(json[i+1] == ":", "invalid json - missing : between key and val ")
        local val = parse_val(json, i+2)
        i = val.i
        val = val.val
        if (json[i] == ",") i += 1
        -- Add value in object
        obj[key] = val
    end
    return obj
end

function parse_array(json, i)
    local array = {}
    while json[i] != "]" do
        local data = parse_val(json, i)
        i = data.i
        add(array, data.val)
        if (json[i] == ",") i += 1
    end
    return array
end

function parse_val(json, i)
    -- Extract value
    local val = ""
    local pos = i
    local first = json[i]
    local open = 0
    while open != 0 or ((first == "{" and json[i] != "}") or (first == "[" and json[i] != "]") or (json[i] != "," and json[i] != "}" and json[i] != "]")) do
        assert(json[i], "invalid json")
        val = val..json[i]
        if (i != pos and ((first == '{' and json[i] == '{') or (first == '[' and json[i] == '['))) open += 1
        if (open != 0 and ((first == '{' and json[i] == '}') or (first == '[' and json[i] == ']'))) open -= 1
        i += 1
    end
    -- Convert value
    if val[1] == "{" then -- Object
        val = parse_object(val.."}", 2)
        i += 1
    elseif val[1] == "[" then -- Array
        val = parse_array(val.."]", 2)
        i += 1
    elseif val == "null" then -- Null value
        val = nil
    elseif val == "true" then -- Boolean true
        val = true
    elseif val == "false" then -- Boolean false
        val = false
    elseif val[1] == '"' then -- String
        val = sub(val, 2, strlen(val) - 1)
    else
        val = tonum(val)
    end
    return {val=val,i=i}
end
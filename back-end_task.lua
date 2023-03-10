function ValidateIP(ip, type1)
    local R = {ERROR = 0, IPV4 = 1, IPV6 = 2}
    if type(ip) ~= "string" then return R.ERROR end
    if type1 == "ipv4" then   
        -- check for format 1.11.111.111 for ipv4
        local chunks = {ip:match("^(%d+)%.(%d+)%.(%d+)%.(%d+)$")}
        if #chunks == 4 then
        for _,v in pairs(chunks) do
            if tonumber(v) > 255 then return R.ERROR end
        end
        return R.IPV4
        end
    elseif type1 == "ipv6" then
        -- check for ipv6 format, should be 8 'chunks' of numbers/letters
        -- without leading/trailing chars
        -- or fewer than 8 chunks, but with only one `::` group
        local chunks = {ip:match("^"..(("([a-fA-F0-9]*):"):rep(8):gsub(":$","$")))}
        if #chunks == 8
        or #chunks < 8 and ip:match('::') and not ip:gsub("::","",1):match('::') then
        for _,v in pairs(chunks) do
            if #v > 0 and tonumber(v, 16) > 65535 then return R.ERROR end
        end
        return R.IPV6
        end
    else
        return R.ERROR
    end
end

function ipToDecimal(ip, checked_ip)
    -- Check if the IP is IPv4 or IPv6
    local isIPv4 = false
    if checked_ip == 1 then
        isIPv4 = true
    end

    if isIPv4 then
        -- Convert IPv4 address to binary
        local binary = ""
        for octet in ip:gmatch("%d+") do
            local octet_binary = ""
            local value = tonumber(octet)
            for i = 7, 0, -1 do
                if value >= 2^i then
                    octet_binary = octet_binary .. "1"
                    value = value - 2^i
                else
                    octet_binary = octet_binary .. "0"
                end
            end
            binary = binary .. octet_binary
        end
        return tonumber(binary, 2)
    else
        -- Convert IPv6 address to binary
        local binary = ""
        for hextet in ip:gmatch("%x+") do
            local hextet_binary = ""
            local value = tonumber(hextet, 16)
            for i = 15, 0, -1 do
                if value >= 2^i then
                    hextet_binary = hextet_binary .. "1"
                    value = value - 2^i
                else
                    hextet_binary = hextet_binary .. "0"
                end
            end
            binary = binary .. hextet_binary
        end
        return tonumber(binary, 2)
    end
end

function main()
    if #arg ~= 3 then
        print("Usage: lua back-end_task.lua <ip type (ipv4 or ipv6)> <first address> <last address>")
        return
    end
    local IPType = {[0] = "Error", "IPv4", "IPv6"}
    --io.write("Enter IP type: ")
    local type1 = arg[1] --io.read()
    if type1 == "ipv4" or type1 == "ipv6" then
        --io.write("Enter first IP address: ")
        local ip1 = arg[2] --io.read()
        --io.write("Enter second IP address: ")
        local ip2 = arg[3] --io.read()
        local checked_ip1 = ValidateIP(ip1, type1)
        local checked_ip2 = ValidateIP(ip2, type1)
        if checked_ip1 == checked_ip2 and (checked_ip1 == 1 or checked_ip1 == 2) then
            local decimal1 = ipToDecimal(ip1,checked_ip1)
            local decimal2 = ipToDecimal(ip2,checked_ip1)
            if decimal1 < decimal2 then
                io.write("The range between ",IPType[checked_ip1]," adresses ", ip1, " and ", ip2, " is ", decimal2 - decimal1, " in decimal format.\n")
            else io.write(IPType[checked_ip1]," second address (",ip2, ") is equal to or smaller than first one (", ip2, ")\n")
            end
        else print("It's not IP address or their types are different")
        end
    else print("Incorrect IP type!")
    end
end
main()
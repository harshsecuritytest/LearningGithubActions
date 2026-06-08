local MACHINE_BASE = tonumber(os.getenv("MACHINE_BASE")) or 0
local THREADS_COUNT = 2
local MACHINE_QUOTA = 250000
local thread_quota = MACHINE_QUOTA / THREADS_COUNT -- 125,000 per thread

local thread_indexer = 0

function setup(thread)
    thread_indexer = thread_indexer + 1
    thread:set("id", thread_indexer)
end

local my_requests_sent = 0
local my_base_id = 0

function init(args)
    local my_thread_id = wrk.thread:get("id")
    my_base_id = MACHINE_BASE + (my_thread_id - 1) * thread_quota
end

request = function()
    my_requests_sent = my_requests_sent + 1

    if my_requests_sent > thread_quota then
        wrk.thread:stop()
        return nil
    end

    local unique_user_id = my_base_id + my_requests_sent

    local headers = {}
    headers["Content-Type"] = "application/json"

    local body = string.format('{"email": "anshuloza@acropolis.in","otp": "%06d","newPassword": "Sorry@1357"}', unique_user_id)
    return wrk.format("POST", "/api/auth/reset-password", headers, body)
end

local ffi = require "ffi"


ffi.cdef[[
typedef struct JSON_checker_struct {
    int valid;
    int state;
    int depth;
    int top;
    int* stack;
} * JSON_checker;

JSON_checker JSON_checker_new(int depth);
void JSON_checker_reset(JSON_checker jc);
void JSON_checker_destory(JSON_checker jc);
int JSON_checker_check(JSON_checker jc, const char *buf, size_t len);
]]


local type = type


local libjc
do
    local function find_shared_obj(cpath, so_name)
        for k in string.gmatch(cpath, "[^;]+") do
            local so_path = string.match(k, "(.*/)")
            so_path = so_path .. so_name

            -- Don't get me wrong, the only way to know if a file exist is
            -- trying to open it.
            local f = io.open(so_path)
            if f ~= nil then
                io.close(f)
                return so_path
            end
        end
    end

    local path = find_shared_obj(package.cpath, "libjsonchecker.so")
    libjc = ffi.load(path)
end

local jc = ffi.gc(libjc.JSON_checker_new(20), libjc.JSON_checker_destory)


local function check_json(s)
    if type(s) ~= "string" then
        return false
    end

    libjc.JSON_checker_reset(jc)
    return libjc.JSON_checker_check(jc, s, #s) == 1
end


return {
    check = check_json
}

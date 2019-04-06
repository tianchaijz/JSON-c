local ffi = require "ffi"
local cjson = require "cjson.safe"


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


local libjc = ffi.load("./libjsonchecker.so")

local jc = ffi.gc(libjc.JSON_checker_new(20), libjc.JSON_checker_destory)


local function check_json(s)
    libjc.JSON_checker_reset(jc)
    return libjc.JSON_checker_check(jc, s, #s) == 1
end


assert(jc)

assert(check_json(cjson.encode({})))
assert(check_json(" { } \n"))
assert(check_json(cjson.encode({["你好"] = "世界"})))
assert(check_json(cjson.encode({"你好", "世界", "Foo © bar 𝌆 baz ☃ qux"})))
assert(check_json(cjson.encode({"\0"})))
assert(check_json('["\\u0000"]'))
assert(cjson.decode('["\\u0000"]')[1] == "\0")
assert(check_json(cjson.encode({"\xe4\xbd\xa0"})))
-- print(cjson.encode({"\0"}))
-- print(cjson.encode({"\xe4\xbd\xa0"}))

assert(not check_json(""))
assert(not check_json(" "))
assert(not check_json("{"))
assert(not check_json("}"))
assert(not check_json("{}{}"))
assert(not check_json("{}\n{}"))
assert(not check_json("1"))
assert(not check_json('"1"'))

print("OK!")

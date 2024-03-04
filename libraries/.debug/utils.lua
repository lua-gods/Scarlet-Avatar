---@diagnostic disable: missing-parameter
local EPSILON = 2.2204460492503131e-16

local deg = math.deg
local atan2 = math.atan2
local sqrt = math.sqrt
local max = math.max
local min = math.min
local abs = math.abs
local floor = math.floor

local dot = vec(0,0,0).dot

local concat = table.concat

local utils = {}

---@param dir Vector3
---@return Vector3 angle
function utils.dirToAngle(dir)
    return vec(-deg(atan2(dir.y, sqrt(dir.x * dir.x + dir.z * dir.z))), deg(atan2(dir.x, dir.z)), 0)
end

---@param model ModelPart
---@param apply? fun(copy: ModelPart, original: ModelPart)
---@return ModelPart
function utils.deepCopy(model, apply)
    local copy = model:copy(model:getName())
    _ = apply and apply(copy, model)
    local children = copy:getChildren()
    for i = 1, #children do
        local child = children[i]
        copy:removeChild(child):addChild(utils.deepCopy(child, apply))
    end
    return copy
end

---@param ray_pos Vector3
---@param ray_dir Vector3
---@param box_pos Vector3
---@param box_min Vector3
---@param box_max Vector3
---@return boolean intersected, Vector3? intersection_point
function utils.intersectBox(ray_pos, ray_dir, box_pos, box_min, box_max)
    local x1, y1, z1 = (box_pos:copy():add(box_min):sub(ray_pos)):div(ray_dir):unpack()
    local x2, y2, z2 = (box_pos:copy():add(box_max):sub(ray_pos)):div(ray_dir):unpack()
    local tmin = max(min(x1, x2), min(y1, y2), min(z1, z2))
    local tmax = min(max(x1, x2), max(y1, y2), max(z1, z2))
    if tmax < 0 or tmin > tmax then return false end
    return true, ray_pos:copy():add(ray_dir:copy():mul(tmin))
end

---@param ray_pos Vector3
---@param ray_dir Vector3
---@param plane_pos Vector3
---@param plane_normal Vector3
---@return boolean intersected, Vector3? intersection_point
function utils.intersectPlane(ray_pos, ray_dir, plane_pos, plane_normal)
    local denom = dot(plane_normal, ray_dir)
    if abs(denom) < EPSILON then return false end
    local d = plane_pos - ray_pos
    local t = dot(d, plane_normal) / denom
    if t < EPSILON then return false end
    return true, ray_pos + ray_dir * t
end

---@param a Vector3
---@param b Vector3
---@return fun():number?,number?,number?
function utils.area(a, b)
    local lx, ux = min(a.x, b.x), max(a.x, b.x)
    local ly, uy = min(a.y, b.y), max(a.y, b.y)
    local lz, uz = min(a.z, b.z), max(a.z, b.z)
    local x, y, z = lx, ly, lz
    return function()
        if x > ux then return nil end
        local cx, cy, cz = x, y, z
        if z < uz then
            z = z + 1
        elseif y < uy then
            y, z = y + 1, lz
        else
            x, y, z = x + 1, ly, lz
        end
        return cx, cy, cz
    end
end

---@type table<string, number>
local cooldowns = {}
---@param key string
---@param next_time integer
---@return boolean ready
function utils.cooldown(key, next_time)
    if not cooldowns[key] or cooldowns[key] < TIME then
        cooldowns[key] = TIME + next_time
        return true
    end
    return false
end

---@param str string
---@param on? string default: " "
---@return string[]
function utils.split(str, on)
    on = on or " "
    local result = {}
    local delimiter = on:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
    for match in (str .. on):gmatch("(.-)" .. delimiter) do
        result[#result+1] = match
    end
    return result
end

---@generic T
---@vararg T[]|T
---@return { [T]: boolean }
function utils.set(...)
    local result = {}
    local args = type(...) == "table" and ... or {...}
    for i = 1, #args do
        result[args[i]] = true
    end
    return result
end

---@generic V
---@param t table<any, V>
---@return V[]
function utils.list(t)
    local result = {}
    for _, v in next, t do
        result[#result+1] = v
    end
    return result
end

---@generic K
---@param t table<K, any>
---@return K[]
function utils.keys(t)
    local result = {}
    for k, _ in next, t do
        result[#result+1] = k
    end
    return result
end

---@generic K, V
---@param t table<K, V>
---@return { k: K, v: V }[]
function utils.pairs(t)
    local result = {}
    for k, v in next, t do
        result[#result+1] = { k = k, v = v }
    end
    return result
end

---@generic K, V
---@param t { [K]: V }
---@return { [V]: K }
function utils.invert(t)
    local result = {}
    for k, v in next, t do
        result[v] = k
    end
    return result
end

---@generic F: fun(...): any
---@param func F
---@return F memoized
function utils.memoize(func)
    local cache = {}
    return function(...)
        local key = concat({...}, ",")
        if not cache[key] then
            cache[key] = func(...)
        end
        return cache[key]
    end
end

---@param number number
---@param precision number
---@return number
function utils.round(number, precision)
    local mult = 10 ^ (precision or 0)
    return floor(number * mult + 0.5) / mult
end

---@generic T: table
---@param tbl T
---@return T copy
function utils.tblCopy(tbl)
    if type(tbl) ~= "table" then return tbl end
    local copy = {}
    for k, v in next, tbl do
        copy[utils.tblCopy(k)] = utils.tblCopy(v)
    end
    return setmetatable(copy, utils.tblCopy(getmetatable(tbl)))
end

---@generic T
---@param tbl table<any, T>
---@param predicate fun(value: T): boolean
---@return T?
function utils.seek(tbl, predicate)
    for _, v in next, tbl do
        if predicate(v) then
            return v
        end
    end
end

---@generic K, V
---@param tbl table<K, V>
---@param predicate fun(key: K, value: V): boolean
---@return table<K, V>
function utils.filter(tbl, predicate)
    local result = {}
    for k, v in next, tbl do
        if predicate(k, v) then
            result[k] = v
        end
    end
    return result
end

_G.utils = utils
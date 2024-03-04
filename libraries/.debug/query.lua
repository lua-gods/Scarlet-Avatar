require(... ..".utils")
---@alias some boolean|string|number|integer|function|table|thread|userdata|lightuserdata

---@class Query
local Query = {}
Query.__index = Query

--#region initializers

---@return Query
function Query.new(tbl)
    return setmetatable(tbl, Query)
end

---@type table<string, any>
local registries = {}

---@param registry "block"|"item"|"entity_type"|"sound_event"
---@return Query
function Query.registry(registry)
    if not registries[registry] then
        local success, result = pcall(client.getRegistry, registry)
        if success then
            registries[registry] = result
        end
    end
    return Query.new(registries[registry] or {})
end

function Query.list(tbl)
    return Query.new(utils.list(tbl))
end

function Query.pairs(tbl)
    return Query.new(utils.pairs(tbl))
end
--#endregion

--#region operations

---@param predicate fun(v: any): boolean
---@return Query
function Query:filter(predicate)
    local filtered = {}
    for i = 1, #self do
        local v = self[i]
        if predicate(v) then
            filtered[#filtered + 1] = v
        end
    end
    return Query.new(filtered)
end

---@param callback fun(v: any, i: number)
---@return Query
function Query:each(callback)
    for i = 1, #self do
        callback(self[i], i)
    end
    return self
end

---@generic T
---@param callback fun(v: any, ...: T): any
---@param ... T
---@return Query
function Query:map(callback, ...)
    local mapped = {}
    for i = 1, #self do
        mapped[i] = callback(self[i], ...)
    end
    return Query.new(mapped)
end

---@generic T
---@param callback fun(v: any, ...: T): any[]
---@param ... T
---@return Query
function Query:flatMap(callback, ...)
    local map = {}
    local n = 1
    for i = 1, #self do
        local result = callback(self[i], ...)
        for j = 1, #result do
            map[n] = result[j]
            n = n + 1
        end
    end
    return Query.new(map)
end

---@param callback fun(acc: any, v: any, i: number): any
---@param initial? some
function Query:reduce(callback, initial)
    local reduced = initial or self[1]
    for i = initial and 1 or 2, #self do
        reduced = callback(reduced, self[i], i)
    end
    return reduced
end

---@param n number
function Query:take(n)
    local taken = {}
    for i = 1, n do
        taken[i] = self[i]
    end
    return Query.new(taken)
end

---@param predicate fun(v: any): boolean
function Query:takeWhile(predicate)
    local taken = {}
    for i = 1, #self do
        local v = self[i]
        if predicate(v) then
            taken[i] = v
        else
            break
        end
    end
    return Query.new(taken)
end

---@param callback fun(a: any, b: any): boolean
function Query:sort(callback)
    local sorted = self:copy()
    table.sort(sorted, callback)
    return Query.new(sorted)
end

---@return Query
function Query:copy()
    local copy = {}
    for i = 1, #self do
        copy[i] = self[i]
    end
    return Query.new(copy)
end

---@generic R
---@param ... fun(v: table): R
---@return R
function Query:apply(...)
    local args = {...}
    local result = self
    for i = 1, #args do
        result = args[i](result)
    end
    return result
end

--#endregion

--#region helpers

---@param val string
---@return fun(v: string)
function Query.find_plain(val)
    return function (v)
        return v:find(val, 1, true)
    end
end

---@generic K, V
---@param ... string
---@return fun(v: { [K]: V }): V
function Query.extract(...)
    local args = {...}
    return function (v)
        for i = 1, #args do
            v = v[args[i]]
        end
        return v
    end
end

---@param acc string
---@param v string
function Query.concat(acc, v)
    return acc .. v
end

---@generic T
---@param v T
---@return T
function Query.identity(v)
    return v
end

---@param val any
---@return fun(v: any): boolean
function Query.ne(val)
    return function (v)
        return v ~= val
    end
end

---@param val any
---@return fun(v: any): boolean
function Query.eq(val)
    return function (v)
        return v == val
    end
end
--#endregion

--#region sorts

---@param a string|number
---@param b string|number
function Query.numerical(a, b)
    return a < b
end

Query.alphabetical = Query.numerical
--#endregion

--#region reductions

---@param a number
---@param b number
function Query.sum(a, b)
    return a + b
end

---@param a number
---@param b number
function Query.product(a, b)
    return a * b
end

--#endregion

---@param n number
---@return fun(v: number): number
function Query.mod(n)
    return function (v)
        return v % n
    end
end

_G.query = setmetatable(Query, {
    __call = function (_, tbl)
        return Query.new(tbl)
    end
})
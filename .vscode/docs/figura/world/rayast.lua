---@meta _
---@diagnostic disable: duplicate-set-field

---==============================================================================================---
---  RAYCAST                                                                                ---
---==============================================================================================---

---@class RaycastAPI
local raycast = {}


---@class Raycast.AABB
---@field [1] Vector3
---@field [2] Vector3


---Casts a ray from the given position to the other given position. The first intersection will return the entity and the exact world position on where the raycast intersected.  
---`predicate` lets you filter entities via functions, Takes in a single EntityAPI, return true for valid, false for invalid
---@overload fun(fromX : number, fromY : number, fromZ : number, to : Vector3 ,predicate : fun(entity : Entity): boolean): ...
---@overload fun(from : Vector3, toX : number, toY : number, toZ : number, predicate : fun(entity : Entity): boolean): ...
---@overload fun(fromX : number, fromY : number, fromZ : number, toX : number, toY : number, toZ : number, predicate : fun(entity : Entity): boolean): ...
---@param from Vector3
---@param to Vector3
---@param predicate function?
---@return Entity?, Vector3?
function raycast:entity(from, to, predicate)
end


---Casts a ray from the given position to the other given position. The first intersection will return the block and the exact world position on where the raycast intersected.  
---`predicate` lets you filter entities via functions, Takes in a single blockAPI, return true for valid, false for invalid
---@overload fun(fromX : number, fromY : number, fromZ : number, to : Vector3 ,predicate : fun(block : BlockState): boolean): ...
---@overload fun(from : Vector3, toX : number, toY : number, toZ : number, predicate : fun(block : BlockState): boolean): ...
---@overload fun(fromX : number, fromY : number, fromZ : number, toX : number, toY : number, toZ : number, predicate : fun(block : BlockState): boolean): ...
---@param from Vector3
---@param to Vector3
---@param predicate function?
---@return BlockState?, Vector3?
function raycast:block(from, to, predicate)
end


---Raycasts based on a from position, an to position, and an array of Axis Aligned Bounding Boxes defined by the player.  
---AABBs are encoded as a table with indicies 1 and 2 being a Vector3.  
---`{vec(0,0,0),vec(1,0.5,1)}` is a valid AABB, with `{ {vec(0,0,0),vec(1,0.5,1)}, {vec(0,0.5,0.5),vec(1,1,1)} }` being avalid AABB array.  
---This function returns the AABB table that was hit, the exact position hit as a Vector3, the side of the AABB hit as astring or nil if inside an AABB, and the index of the AABB that was hit in the array  
---example AABBs: 
---```lua
---{
---  {
---     vec(0, 0, 0)
---     vec(1, 1, 1)
---  },
---  {
---     vec(0.5, 0.5, 0)
---     vec(1,   2,   6)
---  },
---...
---}
---```
---@overload fun(fromX : number, fromY : number, fromZ : number, to : Vector3 ,AABBs : Raycast.AABB[]): ...
---@overload fun(from : Vector3, toX : number, toY : number, toZ : number, AABBs : Raycast.AABB[]): ...
---@overload fun(fromX : number, fromY : number, fromZ : number, toX : number, toY : number, toZ : number, AABBs : Raycast.AABB[]): ...
---@param from Vector3
---@param to Vector3
---@param AABBs Raycast.AABB[]
---@return Vector3?
function raycast:aabb(from, to, AABBs)
end
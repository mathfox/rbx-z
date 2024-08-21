--!native
-- This flag ensures we get the same code optimizations in studio as in the live servers.
-- This also includes inlining the function calls.
--!optimize 2

-- TODO: add (value is T) generics similar to TypeScript, which prolly will never happen
export type check = (value: unknown) -> boolean

export type CheckablePrimitives =
	"nil"
	| "boolean"
	| "string"
	| "number"
	| "table"
	| "userdata"
	| "function"
	| "thread"
	| "vector"
	| "buffer"

export type CheckableTypes =
	CheckablePrimitives
	| "Axes"
	| "BrickColor"
	| "CatalogSearchParams"
	| "CFrame"
	| "Color3"
	| "ColorSequence"
	| "ColorSequenceKeypoint"
	| "DateTime"
	| "DockWidgetPluginGuiInfo"
	| "Enum"
	| "EnumItem"
	| "Enums"
	| "Faces"
	| "FloatCurveKey"
	| "Font"
	| "Instance"
	| "NumberRange"
	| "NumberSequence"
	| "NumberSequenceKeypoint"
	| "OverlapParams"
	| "PathWaypoint"
	| "PhysicalProperties"
	| "Random"
	| "Ray"
	| "RaycastParams"
	| "RaycastResult"
	| "RBXScriptConnection"
	| "RBXScriptSignal"
	| "Rect"
	| "Region3"
	| "Region3int16"
	| "TweenInfo"
	| "UDim"
	| "UDim2"
	| "Vector2"
	| "Vector2int16"
	| "Vector3"
	| "Vector3int16"

local z = {}

function z.type(typeName: CheckablePrimitives)
	return function(value)
		local valueType = type(value)
		if valueType == typeName then
			return true
		else
			return false, `{typeName} expected, got {valueType}`
		end
	end
end

function z.typeof(typeName: CheckableTypes)
	return function(value)
		local valueType = typeof(value)
		if valueType == typeName then
			return true
		else
			return false, `{typeName} expected, got {valueType}`
		end
	end
end

function z.any(value)
	if value ~= nil then
		return true
	else
		return false, "any expected, got nil"
	end
end

-- Luau primitives

z.boolean = z.type("boolean")
z.buffer = z.type("buffer")
z.thread = z.type("thread")
z.callback = z.type("function")
z["function"] = z.callback
z.none = z.type("nil")
z["nil"] = z.none
z.string = z.type("string")
z.table = z.type("table")
z.userdata = z.type("userdata")
-- Checks for Vector3
z.vector = z.type("vector")

-- ensures value is a number and non-NaN
function z.number(value)
	local valueType = type(value)
	if valueType ~= "number" then
		return false, `number expected, got {valueType}`
	elseif value ~= value then
		return false, "unexpected NaN value"
	end

	return true
end

-- ensures value is NaN
function z.nan(value)
	local valueType = type(value)
	if valueType ~= "number" then
		return false, `number expected, got {valueType}`
	elseif value == value then
		return false, "unexpected non-NaN value"
	end

	return true
end

-- Roblox types

z.Axes = z.typeof("Axes")
z.BrickColor = z.typeof("BrickColor")
z.CatalogSearchParams = z.typeof("CatalogSearchParams")
z.CFrame = z.typeof("CFrame")
z.Color3 = z.typeof("Color3")
z.ColorSequence = z.typeof("ColorSequence")
z.ColorSequenceKeypoint = z.typeof("ColorSequenceKeypoint")
z.DateTime = z.typeof("DateTime")
z.DockWidgetPluginGuiInfo = z.typeof("DockWidgetPluginGuiInfo")
z.Enum = z.typeof("Enum")
z.EnumItem = z.typeof("EnumItem")
z.Enums = z.typeof("Enums")
z.Faces = z.typeof("Faces")
z.FloatCurveKey = z.typeof("FloatCurveKey")
z.Font = z.typeof("Font")
z.Instance = z.typeof("Instance")
z.NumberRange = z.typeof("NumberRange")
z.NumberSequence = z.typeof("NumberSequence")
z.NumberSequenceKeypoint = z.typeof("NumberSequenceKeypoint")
z.OverlapParams = z.typeof("OverlapParams")
z.PathWaypoint = z.typeof("PathWaypoint")
z.PhysicalProperties = z.typeof("PhysicalProperties")
z.Random = z.typeof("Random")
z.Ray = z.typeof("Ray")
z.RaycastParams = z.typeof("RaycastParams")
z.RaycastResult = z.typeof("RaycastResult")
z.RBXScriptConnection = z.typeof("RBXScriptConnection")
z.RBXScriptSignal = z.typeof("RBXScriptSignal")
z.Rect = z.typeof("Rect")
z.Region3 = z.typeof("Region3")
z.Region3int16 = z.typeof("Region3int16")
z.TweenInfo = z.typeof("TweenInfo")
z.UDim = z.typeof("UDim")
z.UDim2 = z.typeof("UDim2")
z.Vector2 = z.typeof("Vector2")
z.Vector2int16 = z.typeof("Vector2int16")
z.Vector3 = z.typeof("Vector3")
z.Vector3int16 = z.typeof("Vector3int16")

-- ensures value is any of the given literal value
function z.literal(...)
	local size = select("#", ...)

	if size == 1 then
		local literal = ...

		return function(value)
			if value ~= literal then
				return false, `expected {literal}, got {value}`
			end

			return true
		end
	end

	local literals = {}

	for i = 1, size do
		literals[i] = z.literal(select(i, ...))
	end

	return z.union(unpack(literals, 1, size))
end

-- Returns a z.union of each key in the table as a z.literal
function z.keyOf(keyTable)
	local keys = {}
	local length = 0
	for key in keyTable do
		length += 1
		keys[length] = key
	end

	return z.literal(unpack(keys, 1, length))
end

-- Returns a z.union of each value in the table as a z.literal
function z.valueOf(valueTable)
	local values = {}
	local length = 0
	for _, value in valueTable do
		length += 1
		values[length] = value
	end

	return z.literal(unpack(values, 1, length))
end

-- ensures value is an integer
function z.integer(value)
	local success, errMsg = z.number(value)
	if not success then
		return false, errMsg
	elseif value % 1 ~= 0 then
		return false, `integer expected, got {value}`
	end

	return true
end

-- ensure value is a number and not equals to +inf and -inf
function z.numberFinite(value)
	local success, errMsg = z.number(value)
	if not success then
		return false, errMsg
	elseif value ~= math.huge and value ~= -math.huge then
		return true
	end

	return false, `integer expected, got {value}`
end

-- ensures value is a number where value > min
function z.numberGt(min)
	assert(z.number(min))

	return function(value)
		local success, errMsg = z.number(value)
		if not success then
			return false, errMsg
		elseif value > min then
			return true
		end

		return false, `number > {min} expected, got {value}`
	end
end

-- ensures value is a number where value < max
function z.numberLt(max)
	assert(z.number(max))

	return function(value)
		local success, errMsg = z.number(value)
		if not success then
			return false, errMsg
		elseif value < max then
			return true
		end

		return false, `number < {max} expected, got {value}`
	end
end

-- ensures value is a number where value >= min
function z.numberGte(min)
	assert(z.number(min))

	return function(value)
		local success, errMsg = z.number(value)
		if not success then
			return false, errMsg
		elseif value >= min then
			return true
		end

		return false, `number >= {min} expected, got {value}`
	end
end

-- ensures value is a number where value <= max
function z.numberLte(max)
	assert(z.number(max))

	return function(value)
		local success, errMsg = z.number(value)
		if not success then
			return false, errMsg
		elseif value <= max then
			return true
		end

		return false, `number <= {max} expected, got {value}`
	end
end

-- ensures value is a number where value > 0
z.numberPositive = z.numberGt(0)

-- ensures value is a number where value < 0
z.numberNegative = z.numberLt(0)

-- ensures value is a number where min <= value <= max
function z.numberConstrained(min, max)
	local minCheck = z.numberGte(min)
	local maxCheck = z.numberLte(max)

	return function(value)
		local minSuccess, minErrMsg = minCheck(value)
		if not minSuccess then
			return false, minErrMsg
		end

		local maxSuccess, maxErrMsg = maxCheck(value)
		if not maxSuccess then
			return false, maxErrMsg
		end

		return true
	end
end

-- ensures value is a number where min < value < max
function z.numberConstrainedExclusive(min, max)
	local minCheck = z.numberGt(min)
	local maxCheck = z.numberLt(max)

	return function(value)
		local minSuccess, minErrMsg = minCheck(value)
		if not minSuccess then
			return false, minErrMsg
		end

		local maxSuccess, maxErrMsg = maxCheck(value)
		if not maxSuccess then
			return false, maxErrMsg
		end

		return true
	end
end

-- ensures value matches string pattern
function z.match(pattern)
	assert(z.string(pattern))

	return function(value)
		local stringSuccess, stringErrMsg = z.string(value)
		if not stringSuccess then
			return false, stringErrMsg
		end

		if string.match(value, pattern) == nil then
			return false, string.format("%q failed to match pattern %q", value, pattern)
		end

		return true
	end
end

-- ensures value is either nil or passes check
function z.optional(check)
	assert(z.callback(check))

	return function(value)
		if value == nil then
			return true
		end

		local success, errMsg = check(value)
		if not success then
			return false, `(optional) {errMsg}`
		end

		return true
	end
end

--[[
    Ensures that each tuple element passes all of the checks provided.
]]
function z.tuple(...)
	local check = z.intersection(...)

	return function(...)
		for index = 1, select("#", ...) do
			local success, errMsg = check(select(index, ...))
			if not success then
				return false, `Bad tuple index #{index}:\n\t{errMsg}`
			end
		end

		return true
	end
end

--[[
    Ensures that each tuple element passes the corresponding check provided.
    If elements count does not match, it will also fail.
]]
function z.strictTuple(...)
	local checksLength, checks = select("#", ...), { ... }

	return function(...)
		local length = select("#", ...)
		if length ~= checksLength then
			return false, `Invalid tuple length, expected {checksLength}, got {length}`
		end

		for checkIndex = 1, checksLength do
			local success, errMsg = checks[checkIndex](select(checkIndex, ...))
			if not success then
				return false, `Bad tuple index #{checkIndex}:\n\t{errMsg}`
			end
		end

		return true
	end
end

-- ensures all keys in given table pass check
function z.keys(check)
	assert(z.callback(check))

	return function(value)
		local tableSuccess, tableErrMsg = z.table(value)
		if tableSuccess == false then
			return false, tableErrMsg
		end

		for key in value do
			local success, errMsg = check(key)
			if not success then
				return false, `Bad key {key}:\n\t{errMsg}`
			end
		end

		return true
	end
end

-- ensures all values in given table pass check
function z.values(check)
	assert(z.callback(check))

	return function(value)
		local tableSuccess, tableErrMsg = z.table(value)
		if tableSuccess == false then
			return false, tableErrMsg
		end

		for key, val in value do
			local success, errMsg = check(val)
			if not success then
				return false, `bad value for key {key}:\n\t{errMsg}`
			end
		end

		return true
	end
end

-- ensures value is a table and all keys pass keyCheck and all values pass valueCheck
function z.map(keyCheck, valueCheck)
	assert(z.callback(keyCheck))
	assert(z.callback(valueCheck))

	local keyChecker = z.keys(keyCheck)
	local valueChecker = z.values(valueCheck)

	return function(value)
		local keySuccess, keyErr = keyChecker(value)
		if not keySuccess then
			return false, keyErr
		end

		local valueSuccess, valueErr = valueChecker(value)
		if not valueSuccess then
			return false, valueErr
		end

		return true
	end
end

-- Intenteed for TypeScript usage.
z.record = z.map

-- ensures value is a table and all keys pass valueCheck and all values are true
function z.set(valueCheck)
	return z.map(valueCheck, z.literal(true))
end

-- ensures value is an array and all values of the array match check
function z.array(check)
	assert(z.callback(check))

	local valuesCheck = z.values(check)

	return function(value)
		local valueType = type(value)
		if valueType ~= "table" then
			return false, `array expected, got {valueType}`
		end

		if next(value) == nil then
			-- an empty table is an empty array
			return true
		end

		local length = #value
		if length == 0 then
			return false, `array expected, got a map-like object`
		end

		local sum, count = 0, 0

		for key in value do
			local keyType = type(key)
			if keyType ~= "number" then
				return false, `array expected, got a map-like object with key of type - {keyType}`
			end

			if key % 1 ~= 0 or key < 1 then
				return false, `array expected, got a map-like object with key - {key}`
			end

			count += 1
			sum += key
		end

		local isArray = sum == (count * (count + 1) / 2)
		if not isArray then
			return false, `array expected, got mixed array`
		end

		local valueSuccess, valueErrMsg = valuesCheck(value)
		if not valueSuccess then
			return false, `[array] {valueErrMsg}`
		end

		return true
	end
end

-- ensures value is an array of a strict makeup and size.
function z.strictArray(...)
	local valuesLength, valueTypes = select("#", ...), { ... }
	assert(z.array(z.callback)(valueTypes))

	return function(value)
		local valueType = type(value)
		if valueType ~= "table" then
			return false, `strictArray expected, got {valueType}`
		end

		if next(value) == nil then
			-- an empty table is an empty array

			if valuesLength ~= 0 then
				return false, `strictArray with the size of {valuesLength} elements expected, got an empty array`
			end

			return true
		end

		local length = #value
		if length == 0 then
			return false, `strictArray expected, got a map-like object`
		elseif length ~= valuesLength then
			return false,
				`strictArray with the size of {valuesLength} elements expected, got a table with {length} length`
		end

		local sum, count = 0, 0

		for key, v in value do
			local keyType = type(key)
			if keyType ~= "number" then
				return false, `strictArray expected, got a map-like object with key of type - {keyType}`
			end

			if key % 1 ~= 0 or key < 1 then
				return false, `strictArray expected, got a map-like object with key - {key}`
			end

			-- We rely on the `isArray` check down below to catch the non-iterated values (a.k.a mixed arrays).
			if not valueTypes[key](v) then
				return false, `Invalid element inside of the strictArray at the #{key} index`
			end

			count += 1
			sum += key
		end

		local isArray = sum == (count * (count + 1) / 2)
		if not isArray then
			return false, `strictArray expected, got mixed array`
		end

		return true
	end
end

-- creates a union type
function z.union(...)
	local checks = { ... }
	assert(z.array(z.callback)(checks))

	return function(value)
		for _, check in checks do
			if check(value) then
				return true
			end
		end

		return false, "bad type for union"
	end
end

-- creates an intersection type
function z.intersection(...)
	local checks = { ... }
	assert(z.array(z.callback)(checks))

	return function(value)
		for _, check in checks do
			local success, errMsg = check(value)
			if not success then
				return false, errMsg
			end
		end

		return true
	end
end

-- ensures value matches given interface definition
function z.interface(checkTable)
	assert(z.map(z.any, z.callback)(checkTable))

	return function(value)
		local valueType = type(value)
		if valueType ~= "table" then
			return false, `interface expected, got {valueType}`
		end

		for key, check in checkTable do
			local success, errMsg = check(value[key])
			if not success then
				return false, `[interface] bad value for {key}:\n\t{errMsg}`
			end
		end

		return true
	end
end

-- ensures value matches given interface definition strictly
function z.strictInterface(checkTable)
	assert(z.map(z.any, z.callback)(checkTable))

	return function(value)
		local valueType = type(value)
		if valueType ~= "table" then
			return false, `strictInterface expected, got {valueType}`
		end

		for key, check in checkTable do
			local success, errMsg = check(value[key])
			if not success then
				return false, `[strictInterface] bad value for {key}:\n\t{errMsg}`
			end
		end

		for key in value do
			if not checkTable[key] then
				return false, `[strictInterface] unexpected field {key}`
			end
		end

		return true
	end
end

-- ensure value is an Instance and it's ClassName matches the given ClassName
function z.instanceOf(className, childTable)
	assert(z.string(className))

	local childrenCheck
	if childTable ~= nil then
		childrenCheck = z.children(childTable)
	end

	return function(value)
		local instanceSuccess, instanceErrMsg = z.Instance(value)
		if not instanceSuccess then
			return false, instanceErrMsg
		elseif value.ClassName ~= className then
			return false, `{className} expected, got {value.ClassName}`
		end

		if childrenCheck then
			local childrenSuccess, childrenErrMsg = childrenCheck(value)
			if not childrenSuccess then
				return false, childrenErrMsg
			end
		end

		return true
	end
end

-- ensure value is an Instance and it's ClassName matches the given ClassName by an IsA comparison
function z.instanceIsA(className, childTable)
	assert(z.string(className))

	local childrenCheck
	if childTable ~= nil then
		childrenCheck = z.children(childTable)
	end

	return function(value)
		local instanceSuccess, instanceErrMsg = z.Instance(value)
		if not instanceSuccess then
			return false, instanceErrMsg
		elseif not value:IsA(className) then
			return false, `{className} expected, got {value.ClassName}`
		end

		if childrenCheck then
			local childrenSuccess, childrenErrMsg = childrenCheck(value)
			if not childrenSuccess then
				return false, childrenErrMsg
			end
		end

		return true
	end
end

--[[
    Takes a table where keys are child names and values are functions to check the children againsz.
    Pass an instance tree into the function.
    If at least one child passes each check, the overall check passes.

    Warning! If you pass in a tree with more than one child of the same name, this function will always return false
]]
function z.children(checkTable)
	assert(z.map(z.string, z.callback)(checkTable))

	return function(value)
		local instanceSuccess, instanceErrMsg = z.Instance(value)
		if not instanceSuccess then
			return false, instanceErrMsg
		end

		local childrenByName = {}

		for _, child in value:GetChildren() do
			local name = child.Name
			if checkTable[name] then
				if childrenByName[name] then
					return false, string.format("Cannot process multiple children with the same name %q", name)
				end

				childrenByName[name] = child
			end
		end

		for name, check in checkTable do
			local success, errMsg = check(childrenByName[name])
			if not success then
				return false, `[{value:GetFullName()}.{name}] {errMsg}`
			end
		end

		return true
	end
end

-- ensures value is an enum of the correct type
function z.enum(enum)
	assert(z.Enum(enum))

	return function(value)
		local enumItemSuccess, enumItemErrMsg = z.EnumItem(value)
		if not enumItemSuccess then
			return false, enumItemErrMsg
		elseif value.EnumType ~= enum then
			return false, `enum of {enum} expected, got enum of {value.EnumType}`
		end

		return true
	end
end

-- wraps a callback in an assert with checkArgs
function z.wrap(callback, checkArgs)
	assert(z.tuple(z.callback, z.callback)(callback, checkArgs))

	return function(...)
		assert(checkArgs(...))

		return callback(...)
	end
end

-- asserts a given check
function z.strict(check)
	return function(...)
		assert(check(...))
	end
end

return {
	z = z,
}

return function()
	local z = require(script.Parent)

	it("should support type checking with type()", function()
		assert(z.type("nil")(nil))
		assert(z.type("boolean")(true))
		assert(z.type("string")("foo"))
		assert(z.type("number")(123))
		assert(z.type("table")({}))
		assert(z.type("userdata")(newproxy()))
		assert(z.type("function")(function() end))
		assert(z.type("thread")(coroutine.create(function() end)))

		assert(not z.type("nil")(true))
		assert(not z.type("boolean")("true"))
		assert(not z.type("string")(123))
		assert(not z.type("number")("123"))
		assert(not z.type("table")("{}"))
		assert(not z.type("userdata")(nil))
		assert(not z.type("function")("function"))
		assert(not z.type("thread")("thread"))
	end)

	it("should support basic types", function()
		assert(z.any(""))
		assert(z.boolean(true))
		assert(z.none(nil))
		assert(z.number(1))
		assert(z.string("foo"))
		assert(z.table({}))

		assert(not (z.any(nil)))
		assert(not (z.boolean("true")))
		assert(not (z.none(1)))
		assert(not (z.number(true)))
		assert(not (z.string(true)))
		assert(not (z.table(82)))
	end)

	it("should support special number types", function()
		local maxTen = z.numberMax(10)
		local minTwo = z.numberMin(2)
		local maxTenEx = z.numberMaxExclusive(10)
		local minTwoEx = z.numberMinExclusive(2)
		local constrainedEightToEleven = z.numberConstrained(8, 11)
		local constrainedEightToElevenEx = z.numberConstrainedExclusive(8, 11)

		assert(maxTen(5))
		assert(maxTen(10))
		assert(not (maxTen(11)))
		assert(not (maxTen()))

		assert(minTwo(5))
		assert(minTwo(2))
		assert(not (minTwo(1)))
		assert(not (minTwo()))

		assert(maxTenEx(5))
		assert(maxTenEx(9))
		assert(not (maxTenEx(10)))
		assert(not (maxTenEx()))

		assert(minTwoEx(5))
		assert(minTwoEx(3))
		assert(not (minTwoEx(2)))
		assert(not (minTwoEx()))

		assert(not (constrainedEightToEleven(7)))
		assert(constrainedEightToEleven(8))
		assert(constrainedEightToEleven(9))
		assert(constrainedEightToEleven(11))
		assert(not (constrainedEightToEleven(12)))
		assert(not (constrainedEightToEleven()))

		assert(not (constrainedEightToElevenEx(7)))
		assert(not (constrainedEightToElevenEx(8)))
		assert(constrainedEightToElevenEx(9))
		assert(not (constrainedEightToElevenEx(11)))
		assert(not (constrainedEightToElevenEx(12)))
		assert(not (constrainedEightToElevenEx()))
	end)

	it("should support optional types", function()
		local check = z.optional(z.string)
		assert(check(""))
		assert(check())
		assert(not (check(1)))
	end)

	it("should support tuple types", function()
		local myTupleCheck = z.tuple(z.number, z.string, z.optional(z.number))
		assert(myTupleCheck(1, "2", 3))
		assert(myTupleCheck(1, "2"))
		assert(not (myTupleCheck(1, "2", "3")))
	end)

	it("should support union types", function()
		local numberOrString = z.union(z.number, z.string)
		assert(numberOrString(1))
		assert(numberOrString("1"))
		assert(not (numberOrString(nil)))
	end)

	it("should support literal types", function()
		local checkSingle = z.literal("foo")
		local checkUnion = z.union(z.literal("foo"), z.literal("bar"), z.literal("oof"))

		assert(checkSingle("foo"))
		assert(checkUnion("foo"))
		assert(checkUnion("bar"))
		assert(checkUnion("oof"))

		assert(not (checkSingle("FOO")))
		assert(not (checkUnion("FOO")))
		assert(not (checkUnion("BAR")))
		assert(not (checkUnion("OOF")))
	end)

	it("should support multiple literal types", function()
		local checkSingle = z.literal("foo")
		local checkUnion = z.literal("foo", "bar", "oof")

		assert(checkSingle("foo"))
		assert(checkUnion("foo"))
		assert(checkUnion("bar"))
		assert(checkUnion("oof"))

		assert(not (checkSingle("FOO")))
		assert(not (checkUnion("FOO")))
		assert(not (checkUnion("BAR")))
		assert(not (checkUnion("OOF")))
	end)

	it("should support intersection types", function()
		local integerMax5000 = z.intersection(z.integer, z.numberMax(5000))
		assert(integerMax5000(1))
		assert(not (integerMax5000(5001)))
		assert(not (integerMax5000(1.1)))
		assert(not (integerMax5000("1")))
	end)

	describe("array", function()
		it("should support array types", function()
			local stringArray = z.array(z.string)
			local anyArray = z.array(z.any)
			local stringValues = z.values(z.string)
			assert(not (anyArray("foo")))
			assert(anyArray({ 1, "2", 3 }))
			assert(not (stringArray({ 1, "2", 3 })))
			assert(not (stringArray()))
			assert(not (stringValues()))
			assert(anyArray({ "1", "2", "3" }, z.string))
			assert(not (anyArray({
				foo = "bar",
			})))
			assert(not (anyArray({
				[1] = "non",
				[5] = "sequential",
			})))
		end)

		it("should not be fooled by sparse arrays", function()
			local anyArray = z.array(z.any)

			assert(not (anyArray({
				[1] = 1,
				[2] = 2,
				[4] = 4,
			})))
		end)
	end)

	it("should support map types", function()
		local stringNumberMap = z.map(z.string, z.number)
		assert(stringNumberMap({}))
		assert(stringNumberMap({ a = 1 }))
		assert(not (stringNumberMap({ [1] = "a" })))
		assert(not (stringNumberMap({ a = "a" })))
		assert(not (stringNumberMap()))
	end)

	it("should support set types", function()
		local stringSet = z.set(z.string)
		assert(stringSet({}))
		assert(stringSet({ a = true }))
		assert(not (stringSet({ [1] = "a" })))
		assert(not (stringSet({ a = "a" })))
		assert(not (stringSet({ a = false })))
		assert(not (stringSet()))
	end)

	it("should support interface types", function()
		local IVector3 = z.interface({
			x = z.number,
			y = z.number,
			z = z.number,
		})

		assert(IVector3({
			w = 0,
			x = 1,
			y = 2,
			z = 3,
		}))

		assert(not (IVector3({
			w = 0,
			x = 1,
			y = 2,
		})))
	end)

	it("should support strict interface types", function()
		local IVector3 = z.strictInterface({
			x = z.number,
			y = z.number,
			z = z.number,
		})

		assert(not (IVector3(0)))

		assert(not (IVector3({
			w = 0,
			x = 1,
			y = 2,
			z = 3,
		})))

		assert(not (IVector3({
			w = 0,
			x = 1,
			y = 2,
		})))

		assert(IVector3({
			x = 1,
			y = 2,
			z = 3,
		}))
	end)

	it("should support deep interface types", function()
		local IPlayer = z.interface({
			name = z.string,
			inventory = z.interface({
				size = z.number,
			}),
		})

		assert(IPlayer({
			name = "TestPlayer",
			inventory = {
				size = 1,
			},
		}))

		assert(not (IPlayer({
			inventory = {
				size = 1,
			},
		})))

		assert(not (IPlayer({
			name = "TestPlayer",
			inventory = {},
		})))

		assert(not (IPlayer({
			name = "TestPlayer",
		})))
	end)

	it("should support deep optional interface types", function()
		local IPlayer = z.interface({
			name = z.string,
			inventory = z.optional(z.interface({
				size = z.number,
			})),
		})

		assert(IPlayer({
			name = "TestPlayer",
		}))

		assert(not (IPlayer({
			name = "TestPlayer",
			inventory = {},
		})))

		assert(IPlayer({
			name = "TestPlayer",
			inventory = {
				size = 1,
			},
		}))
	end)

	it("should support Roblox Instance types", function()
		local stringValueCheck = z.instanceOf("StringValue")
		local stringValue = Instance.new("StringValue")
		local boolValue = Instance.new("BoolValue")

		assert(stringValueCheck(stringValue))
		assert(not (stringValueCheck(boolValue)))
		assert(not (stringValueCheck()))
	end)

	it("should support Roblox Instance types inheritance", function()
		local guiObjectCheck = z.instanceIsA("GuiObject")
		local frame = Instance.new("Frame")
		local textLabel = Instance.new("TextLabel")
		local stringValue = Instance.new("StringValue")

		assert(guiObjectCheck(frame))
		assert(guiObjectCheck(textLabel))
		assert(not (guiObjectCheck(stringValue)))
		assert(not (guiObjectCheck()))
	end)

	it("should support Roblox Enum types", function()
		local sortOrderEnumCheck = z.enum(Enum.SortOrder)
		assert(z.Enum(Enum.SortOrder))
		assert(not (z.Enum("Enum.SortOrder")))

		assert(z.EnumItem(Enum.SortOrder.Name))
		assert(not (z.EnumItem("Enum.SortOrder.Name")))

		assert(sortOrderEnumCheck(Enum.SortOrder.Name))
		assert(sortOrderEnumCheck(Enum.SortOrder.Custom))
		assert(not (sortOrderEnumCheck(Enum.EasingStyle.Linear)))
		assert(not (sortOrderEnumCheck()))
	end)

	it("should support Roblox RBXScriptSignal", function()
		assert(z.RBXScriptSignal(game.ChildAdded))
		assert(not (z.RBXScriptSignal(nil)))
		assert(not (z.RBXScriptSignal(Vector3.new())))
	end)

	-- TODO: Add this back when Lemur supports it
	-- it("should support Roblox RBXScriptConnection", function()
	-- 	local conn = game.ChildAdded:Connect(function() end)
	-- 	assert(z.RBXScriptConnection(conn))
	-- 	assert(not (z.RBXScriptConnection(nil)))
	-- 	assert(not (z.RBXScriptConnection(Vector3.new())))
	-- end)

	it("should support wrapping function types", function()
		local checkFoo = z.tuple(z.string, z.number, z.optional(z.string))
		local foo = z.wrap(function(a, b, c)
			local result = string.format("%s %d", a, b)
			if c then
				result = result .. " " .. c
			end
			return result
		end, checkFoo)

		assert(not (pcall(foo)))
		assert(not (pcall(foo, "a")))
		assert(not (pcall(foo, 2)))
		assert(pcall(foo, "a", 1))
		assert(pcall(foo, "a", 1, "b"))
	end)

	it("should support strict types", function()
		local myType = z.strict(z.tuple(z.string, z.number))
		assert(not (pcall(function()
			myType("a", "b")
		end)))
		assert(pcall(function()
			myType("a", 1)
		end))
	end)

	it("should support common OOP types", function()
		local MyClass = {}
		MyClass.__index = MyClass

		function MyClass.new()
			local self = setmetatable({}, MyClass)
			return self
		end

		local function instanceOfClass(class)
			return function(value)
				local tableSuccess, tableErrMsg = z.table(value)
				if not tableSuccess then
					return false, tableErrMsg or ""
				end

				local mt = getmetatable(value)
				if not mt or mz.__index ~= class then
					return false, "bad member of class"
				end

				return true
			end
		end

		local instanceOfMyClass = instanceOfClass(MyClass)

		local myObject = MyClass.new()
		assert(instanceOfMyClass(myObject))
		assert(not (instanceOfMyClass({})))
		assert(not (instanceOfMyClass()))
	end)

	it("should not treat NaN as numbers", function()
		assert(z.number(1))
		assert(not (z.number(0 / 0)))
		assert(not (z.number("1")))
	end)

	it("should not treat numbers as NaN", function()
		assert(not (z.nan(1)))
		assert(z.nan(0 / 0))
		assert(not (z.nan("1")))
	end)

	it("should allow union of number and NaN", function()
		local numberOrNaN = z.union(z.number, z.nan)
		assert(numberOrNaN(1))
		assert(numberOrNaN(0 / 0))
		assert(not (numberOrNaN("1")))
	end)

	it("should support non-string keys for interfaces", function()
		local key = {}
		local myInterface = z.interface({ [key] = z.number })
		assert(myInterface({ [key] = 1 }))
		assert(not (myInterface({ [key] = "1" })))
	end)

	it("should support failing on non-string keys for strict interfaces", function()
		local myInterface = z.strictInterface({ a = z.number })
		assert(not (myInterface({ a = 1, [{}] = 2 })))
	end)

	it("should support children", function()
		local myInterface = z.interface({
			buttonInFrame = z.intersection(
				z.instanceOf("Frame"),
				z.children({
					MyButton = z.instanceOf("ImageButton"),
				})
			),
		})

		assert(not (z.children({})(5)))
		assert(not (myInterface({ buttonInFrame = Instance.new("Frame") })))

		do
			local frame = Instance.new("Frame")
			local button = Instance.new("ImageButton", frame)
			button.Name = "MyButton"
			assert(myInterface({ buttonInFrame = frame }))
		end

		do
			local frame = Instance.new("Frame")
			local button = Instance.new("ImageButton", frame)
			button.Name = "NotMyButton"
			assert(not (myInterface({ buttonInFrame = frame })))
		end

		do
			local frame = Instance.new("Frame")
			local button = Instance.new("TextButton", frame)
			button.Name = "MyButton"
			assert(not (myInterface({ buttonInFrame = frame })))
		end

		do
			local frame = Instance.new("Frame")
			local button1 = Instance.new("ImageButton", frame)
			button1.Name = "MyButton"
			local button2 = Instance.new("ImageButton", frame)
			button2.Name = "MyButton"
			assert(not (myInterface({ buttonInFrame = frame })))
		end
	end)

	it("should support z.instanceOf shorthand", function()
		local myInterface = z.interface({
			buttonInFrame = z.instanceOf("Frame", {
				MyButton = z.instanceOf("ImageButton"),
			}),
		})

		assert(not (z.children({})(5)))
		assert(not (myInterface({ buttonInFrame = Instance.new("Frame") })))

		do
			local frame = Instance.new("Frame")
			local button = Instance.new("ImageButton", frame)
			button.Name = "MyButton"
			assert(myInterface({ buttonInFrame = frame }))
		end

		do
			local frame = Instance.new("Frame")
			local button = Instance.new("ImageButton", frame)
			button.Name = "NotMyButton"
			assert(not (myInterface({ buttonInFrame = frame })))
		end

		do
			local frame = Instance.new("Frame")
			local button = Instance.new("TextButton", frame)
			button.Name = "MyButton"
			assert(not (myInterface({ buttonInFrame = frame })))
		end

		do
			local frame = Instance.new("Frame")
			local button1 = Instance.new("ImageButton", frame)
			button1.Name = "MyButton"
			local button2 = Instance.new("ImageButton", frame)
			button2.Name = "MyButton"
			assert(not (myInterface({ buttonInFrame = frame })))
		end
	end)

	it("should support z.instanceIsA shorthand", function()
		local myInterface = z.interface({
			buttonInFrame = z.instanceIsA("Frame", {
				MyButton = z.instanceIsA("ImageButton"),
			}),
		})

		assert(not (z.children({})(5)))
		assert(not (myInterface({ buttonInFrame = Instance.new("Frame") })))

		do
			local frame = Instance.new("Frame")
			local button = Instance.new("ImageButton", frame)
			button.Name = "MyButton"
			assert(myInterface({ buttonInFrame = frame }))
		end

		do
			local frame = Instance.new("Frame")
			local button = Instance.new("ImageButton", frame)
			button.Name = "NotMyButton"
			assert(not (myInterface({ buttonInFrame = frame })))
		end

		do
			local frame = Instance.new("Frame")
			local button = Instance.new("TextButton", frame)
			button.Name = "MyButton"
			assert(not (myInterface({ buttonInFrame = frame })))
		end

		do
			local frame = Instance.new("Frame")
			local button1 = Instance.new("ImageButton", frame)
			button1.Name = "MyButton"
			local button2 = Instance.new("ImageButton", frame)
			button2.Name = "MyButton"
			assert(not (myInterface({ buttonInFrame = frame })))
		end
	end)

	it("should support z.match", function()
		local check = z.match("%d+")
		assert(check("123"))
		assert(not (check("abc")))
		assert(not (check()))
	end)

	it("should support z.keyOf", function()
		local myNewEnum = {
			OptionA = {},
			OptionB = {},
		}
		local check = z.keyOf(myNewEnum)
		assert(check("OptionA"))
		assert(not (check("OptionC")))
	end)

	it("should support z.valueOf", function()
		local myNewEnum = {
			OptionA = {},
			OptionB = {},
		}
		local check = z.valueOf(myNewEnum)
		assert(check(myNewEnum.OptionA))
		assert(not (check(1010)))
	end)

	it("should support z.strictArray", function()
		local fixedArrayCheck = z.strictArray(z.number, z.number)

		assert(fixedArrayCheck({ 1, 2 }))
		assert(not fixedArrayCheck({ 1, 2, 3 }))
		assert(not fixedArrayCheck({ 10 }))
		assert(not fixedArrayCheck({ "Hello", 10 }))
		assert(not fixedArrayCheck({ Foo = "Bar" }))

		local fixedArrayCheck2 = z.strictArray(z.number, z.number, z.optional(z.string))

		assert(fixedArrayCheck2({ 10, 20 }))
		assert(fixedArrayCheck2({ 10, 20, "Hello" }))
		assert(not fixedArrayCheck2({ 10, 20, 30 }))
	end)
end

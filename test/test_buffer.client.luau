local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tableToBuffer = require(ReplicatedStorage.Packages.TableToBuffer)

local buf = buffer.create(0x1000)
buffer.fill(buf, 0x0, 0xfffffffffffff, 0x1000)
local serializer_1 = tableToBuffer
	.GetDeserializerBuilder()
	.booleanWithName("HelloValue")
	.floatWithName("sickFloat")
	.uint32WithName("This integer is insane")
	.tableWithName(
		"SickNestedTableTwice",
		tableToBuffer.GetSerializerForTable({
			Crooked = true,
			Insanity = false,
			Rapp = "ABBAABABBBABABABABABBABABABABABBABABA",
			Sicka = "BABABABABBABABSUDHIAHDIUASHDIPUAHSDHASDHAS",
			this_is_crazy = 69420,
			testingMoreValues = 0,
			NestedTwice = {
				ne = "sted",
				vec = Vector3.new(6942, 69420, 402342),
				vec3 = Vector3.new(545.1456, 54654.458, -259259.89023489),
				buf = buf,
			},
		})
	)
	.build()

local serializer_2 = tableToBuffer
	.GetDeserializerBuilder()
	.booleanWithName("Test_Value")
	.int32WithName("AmongUs")
	.tableWithName("NestedSerializer", serializer_1)
	.build()

local table_1 = {
	HelloValue = false,
	sickFloat = 0.3784,
	["This integer is insane"] = 69420,
	SickNestedTableTwice = {
		Crooked = false,
		Insanity = true,
		Rapp = "SIGNATUREEEEE",
		Sicka = "UNSIGNATUREEEEEEEE",
		this_is_crazy = 456156168451.11,
		testingMoreValues = 1215.11,
		NestedTwice = {
			ne = "unsted",
			vec = Vector3.new(545.1456, 54654.458, -259259.89023489),
			vec3 = Vector3.new(584545.1456, 121588.458, -2259.890238811),
			buf = buf,
		},
	},
}

local table_2 = {
	Test_Value = true,
	AmongUs = 699999999,
	NestedSerializer = table.clone(table_1),
}

print(buffer.tostring(serializer_1.Serialize(table_1)))
print(serializer_1.Deserialize(serializer_1.Serialize(table_1)))

print(buffer.tostring(serializer_2.Serialize(table_2)))
print(serializer_2.Deserialize(serializer_2.Serialize(table_2)))

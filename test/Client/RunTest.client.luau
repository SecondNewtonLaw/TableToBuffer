local ReplicatedStorage = game:GetService("ReplicatedStorage")

local instanceToBuffer = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("InstanceToBuffer"))

do
	do
		print("--- Testing CFrame serialization ---")
		local cframe = CFrame.new(20.4518, 283.41782389, 24.821789123)
			* CFrame.Angles(math.rad(math.random(0, 360)), math.rad(math.random(0, 360)), math.rad(math.random(0, 360)))

		assert(
			instanceToBuffer.CanBeSerialized(cframe),
			"Test failed: Cannot serialize CFrame, when they should be serializable."
		)
		local success: boolean
		local deserializedCFrame: CFrame | unknown
		success, deserializedCFrame = instanceToBuffer.TryDeserialize(instanceToBuffer.Serialize(cframe))

		assert(success, `Operation was not marked as a success. Error Message: {tostring(deserializedCFrame)}`)
		assert(type(deserializedCFrame) == "userdata", "When deserialized, the CFrame is not of type userdata.")
		assert(deserializedCFrame == cframe, "The serialized and deserialized CFrames are not the same.")
		print("Original: ", cframe)
		print("From Serialized: ", deserializedCFrame)

		print("--- Testing ended for CFrame serialization ---")
	end

	do
		print("--- Testing Vector2 serialization ---")
		local vector = Vector2.new(784292.47211222, 8123.31112812)
		assert(
			instanceToBuffer.CanBeSerialized(vector),
			"Test failed: Cannot serialize Vector2, when they should be serializable."
		)
		local success: boolean
		local deserializedVector: Vector2 | unknown
		success, deserializedVector = instanceToBuffer.TryDeserialize(instanceToBuffer.Serialize(vector))

		assert(success, `Operation was not marked as a success. Error Message: {tostring(deserializedVector)}`)
		assert(type(deserializedVector) == "userdata", "When deserialized, the Vector2 is not of type userdata.")
		assert(deserializedVector == vector, "The serialized and deserialized vectors are not the same.")
		print("Original: ", vector)
		print("From Serialized: ", deserializedVector)
		print("--- Testing ended for Vector2 serialization ---")
	end

	do
		print("--- Testing Vector2int16 serialization ---")
		local vector = Vector2int16.new(1014, 472)
		assert(
			instanceToBuffer.CanBeSerialized(vector),
			"Test failed: Cannot serialize Vector3int16, when they should be serializable."
		)
		local success: boolean
		local deserializedVector: Vector2int16 | unknown
		success, deserializedVector = instanceToBuffer.TryDeserialize(instanceToBuffer.Serialize(vector))

		assert(success, `Operation was not marked as a success. Error Message: {tostring(deserializedVector)}`)
		assert(type(deserializedVector) == "userdata", "When deserialized, the Vector2int16 is not of type userdata.")
		assert(deserializedVector == vector, "The serialized and deserialized vectors are not the same.")
		print("Original: ", vector)
		print("From Serialized: ", deserializedVector)
		print("--- Testing ended for Vector2int16 serialization ---")
	end

	do
		print("--- Testing Vector3 serialization ---")
		local vector = Vector3.new(21392.412722, 81238.31263812, 82981.3276123612)
		assert(
			instanceToBuffer.CanBeSerialized(vector),
			"Test failed: Cannot serialize Vector3, when they should be serializable."
		)
		local success: boolean
		local deserializedVector: Vector3 | unknown
		success, deserializedVector = instanceToBuffer.TryDeserialize(instanceToBuffer.Serialize(vector))

		assert(success, `Operation was not marked as a success. Error Message: {tostring(deserializedVector)}`)
		assert(type(deserializedVector) == "vector", "When deserialized, the Vector3 is not of type Vector.")
		assert(deserializedVector == vector, "The serialized and deserialized vectors are not the same.")
		print("Original: ", vector)
		print("From Serialized: ", deserializedVector)
		print("--- Testing ended for Vector3 serialization ---")
	end

	do
		print("--- Testing Vector3int16 serialization ---")
		local vector = Vector3int16.new(1004, 47712, 27414)
		assert(
			instanceToBuffer.CanBeSerialized(vector),
			"Test failed: Cannot serialize Vector3int16, when they should be serializable."
		)
		local success: boolean
		local deserializedVector: Vector3int16 | unknown
		success, deserializedVector = instanceToBuffer.TryDeserialize(instanceToBuffer.Serialize(vector))

		assert(success, `Operation was not marked as a success. Error Message: {tostring(deserializedVector)}`)
		assert(type(deserializedVector) == "userdata", "When deserialized, the Vector3int16 is not of type userdata.")
		assert(deserializedVector == vector, "The serialized and deserialized vectors are not the same.")
		print("Original: ", vector)
		print("From Serialized: ", deserializedVector)
		print("--- Testing ended for Vector3int16 serialization ---")
	end

	do
		print("--- Testing Animation serialization ---")

		local testAnimation = Instance.new("Animation")
		testAnimation.AnimationId = "rbxassetid://13370003333"
		testAnimation.Name = "The sickest animation ever made"

		assert(
			instanceToBuffer.CanBeSerialized(testAnimation),
			"Test failed: Cannot serialize Animation, when they should be serializable."
		)

		local success: boolean
		local deserializedAnimation: Animation | unknown
		success, deserializedAnimation = instanceToBuffer.TryDeserialize(instanceToBuffer.Serialize(testAnimation))

		assert(success, `Operation was not marked as a success. Error Message: {tostring(deserializedAnimation)}`)
		assert(type(deserializedAnimation) == "userdata", "When deserialized, the Animation is not of type userdata.")
		assert(
			(deserializedAnimation :: Animation).AnimationId == testAnimation.AnimationId
				and (deserializedAnimation :: Animation).Name == testAnimation.Name,
			"The serialized and deserialized Animation Name and AnimationId are not the same."
		)
		assert(deserializedAnimation ~= testAnimation, "The Animations are the same.")
		print("Original Name: ", testAnimation.Name)
		print("Original AnimationId: ", testAnimation.AnimationId)
		print("From Serialized Name: ", (deserializedAnimation :: Animation).Name)
		print("From Serialized AnimationId: ", (deserializedAnimation :: Animation).AnimationId)

		print("--- Testing ended for Animation serialization ---")
	end

	do
		print("--- Testing EnumItem serialization ---")

		local keycodeE = Enum.KeyCode.E

		assert(
			instanceToBuffer.CanBeSerialized(keycodeE),
			"Test failed: Cannot serialize EnumItem, when they should be serializable."
		)

		local success: boolean
		local deserializedKeycode: EnumItem | unknown
		success, deserializedKeycode = instanceToBuffer.TryDeserialize(instanceToBuffer.Serialize(keycodeE))

		assert(success, `Operation was not marked as a success. Error Message: {tostring(deserializedKeycode)}`)
		assert(type(deserializedKeycode) == "userdata", "When deserialized, the EnumItem is not of type userdata.")
		assert(
			(deserializedKeycode :: EnumItem).Name == keycodeE.Name
				and (deserializedKeycode :: EnumItem).Value == keycodeE.Value,
			"The serialized and deserialized EnumItem Name and Value are not the same."
		)
		assert(deserializedKeycode == keycodeE, "The the EnumItems are not the dsame.")

		print("Original KeyCode (Name): ", keycodeE.Name)
		print("Original KeyCode (Value): ", keycodeE.Value)
		print("Original KeyCode (EnumType): ", keycodeE.EnumType)

		print("Deserialized KeyCode (Name): ", (deserializedKeycode :: EnumItem).Name)
		print("Deserialized KeyCode (Value): ", (deserializedKeycode :: EnumItem).Value)
		print("Deserialized KeyCode (EnumType): ", (deserializedKeycode :: EnumItem).EnumType)

		print("--- Testing ended for EnumItem serialization ---")
	end
end

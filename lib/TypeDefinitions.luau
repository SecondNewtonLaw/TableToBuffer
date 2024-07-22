export type Action<T> = {
	DeserializedName: string,
	ActionType: "int" | "boolean" | "float" | "dynamicstring" | "table" | "vector" | "buffer" | "CFrame",
	Solver: {
		write: (buf: buffer, any) -> (),
		read: (buf: buffer) -> any,
		advanceBy: (buf: buffer?) -> number,
	} | nil,
	Serializer: Serializer<T> | nil,
	OffsetedAt: number,
}

export type Serializer<T> = {
	Deserialize: (buf: buffer) -> T,
	GetBufferSize: () -> number,
	Serialize: (obj: T) -> buffer,
	GetActionList: () -> { Action<T> },
}

return {}

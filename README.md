# TableToBuffer

Table to buffer is a project that aims to create a serializer for primitive data types (Except tables) inside of Luau.

All of the serializers and deserializers were manually written, no automatic tool was involved, which means they can be improved, so if there is any bug or space optimization, reach out using issues or make a pull request.

### Currently serializable primitives:
    - boolean
    - number (Automatically serializable as a float64)
    - string

The serializer building can be done automatically given a table. This project ONLY supports tables that are of type `[string]: number | boolean | string`, this is due to how originally the serializer was written, this may change on the future. 

The library follows a Builder pattern to create Deserializers and Serializers. Think of it as something like a Table to JSON, but instead of JSON, is optimized buffers. The order in which the functions for the builder are called matters, as they dictate how big the buffer will be and the position of the data.

#### Documentation:
There is no documentation as of now, as the project is early in development.
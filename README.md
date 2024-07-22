# Table To Buffer

Table to buffer is a project that aims to create a serializer for _most_ primitive data types inside of Luau (`userdata` is not serialized due to it having to be practically manually done for each instance).

All of the serializers and deserializers were manually written, no automatic tool was involved, which means they can be improved, so if there is any bug or space optimization, reach out using issues or make a pull request.

### Currently serializable primitives:
    - boolean
    - number (Automatically serializable as a float64 if not given a specific size)
    - string (May be compressesd using lzw when benefitial)
    - vector (Vector3's on Roblox)
    - table
    - buffer

The serializer building can be done automatically given a table. This project ONLY supports tables that are of type `[string]: number | boolean | string | table | vector (Vector3) | buffer`.

The library follows a Builder pattern to create Deserializers and Serializers. Think of it as something like a Table to JSON, but instead of JSON, is optimized buffers. The order in which the functions for the builder are called matters, as they dictate how big the buffer will be and the position of the data.

Parsing `userdata` value types is not currently on the roadmap, and it may be treated as a side project if it every comes around.

## How to install?
- Download the `.rbxm` file on the latest release of this project.
- Using wally:
    - Add `tabletobuffer = "secondnewtonlaw/tabletobuffer@0.1.4"`

## [How to use this?](https://secondnewtonlaw.github.io/TableToBuffer/)


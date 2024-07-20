# InstanceToBuffer

Instance to buffer is a project that aims to convert as many `userdata` (and the occasional `vector`) into `buffer` representations.

All of the serializers and deserializers were manually written, no automatic tool was involved, which means they can be improved, so if there is any bug or space optimization, reach out using issues or make a pull request.

### Currently serializable instances:
    - Vector2
    - Vector2int16
    - Vector3
    - Vector3int16
    - CFrame
    - Animation
    - Player

This will ONLY serialize when `type(x)` is either `userdata` or `vector`, it will not do anything to `table`s or other primitives.

It is also to note that `Instance`, despite being serializable, will have no parent when its deserialized, as that information is not saved into the buffer, and thus cannot be obtained back.

#### Documentation:
There is no documentation as of now, as the project is early in development.
# InstanceToBuffer

Instance to buffer is a project that aims to convert as many `userdata` into `buffer`s.

All of the serializers and deserializers were manually written, no automatic tool related, so if there is any bug reach out to try and solve it with either an Issue or a Pull Request

Currently serializable instances:
    - Vector2
    - Vector2int16
    - Vector3
    - Vector3int16
    - CFrame
    - Animation
    - Player

This will ONLY serialize when `type(x)` is either `userdata` or `vector`, it will not do anything to `table`s or other primitives.
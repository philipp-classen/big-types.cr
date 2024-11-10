# big-types

Provides data structures that serve as drop-in replacements for Array, Hash, and Set.
Unlike the standard types, these structures support sizes that exceed 32-bit indices.

The implementation is based on the standard library, with 32-bit integers replaced by 64-bit integers.

```crystal
require "big-types"

x = BigArray(Int32).new         # like Array(Int32).new
y = BigSet(Int32).new           # like Set(Int32).new
z = BigHash(Int32, Int32).new   # like Hash(Int32).new
```

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     big-types:
       github: philipp-classen/big-types.cr
   ```

2. Run `shards install`

## Usage

```crystal
require "big-types/big_array"

x = BigArray(Int8).new
4_000_000_000.times { x << 0 }
p! x.size
```

Note that the equivalent program using Array would have overflowed:

```crystal
x = Array(Int8).new
4_000_000_000.times { x << 0 }

Unhandled exception: Arithmetic overflow (OverflowError)
  from /usr/lib/crystal/int.cr:568:7 in '__crystal_main'
  from /usr/lib/crystal/crystal/main.cr:118:5 in 'main'
  from /usr/lib/libc.so.6 in '??'
  from /usr/lib/libc.so.6 in '__libc_start_main'
  from /tmp/phil-crystal-cache-dir/crystal-run-overflow.tmp in '_start'
  from ???
```

The equivalent to `Set` is `BigSet`:

```crystal
require "big-types/big_set"

x = BigSet(Int64).new
4_000_000_000.times { |i| x << i }
p! x.size
```

And the requivalent to `Hash` is `BigHash`:

```crystal
require "big-types/big_hash"

x = BigHash(Int64, Int8).new
4_000_000_000.times { |i| x[i] = 0_i8 }
p! x.size
```

## Development

The code base should stay as close as possible to the implementation in the
Crystal standard library.

## Contributing

1. Fork it (<https://github.com/philipp-classen/big-types/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Philipp Claßen](https://github.com/philipp-classen) - creator and maintainer

# big-types

Provides data structures that are drop-in replacements for Array, Hash, and Set.
In contrast to the standard types, there it supports sizes that exceed 32-bit indicies.

It takes the implementation from the standard library and replaced 32-bit by 64-bit integers.

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
require "big-types"

x = BigArray(Int8).new
4_000_000_000.times { x << 0 }
```

Note that the equivalent program with `Array` would overflow:

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

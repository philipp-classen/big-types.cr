# big-types

Provides data structures that are drop-in replacements for Array, Hash, and Set.
In contrast to the standard types, there it supports sizes that exceed 32-bit indicies.

It takes the implementation from the standard library and replaced 32-bit by 64-bit integers.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     big-types:
       github: your-github-user/big-types
   ```

2. Run `shards install`

## Usage

```crystal
require "big-types"
```

TODO: Write usage instructions here

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/your-github-user/big-types/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Philipp Claßen](https://github.com/your-github-user) - creator and maintainer

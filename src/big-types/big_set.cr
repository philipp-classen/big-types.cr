require "./big_hash"
require "./big_array"

# `BigSet` implements a collection of unordered values with no duplicates.
#
# An `Enumerable` object can be converted to `BigSet` using the `#to_set` method.
#
# `BigSet` uses `BigHash` as storage, so you must note the following points:
#
# * Equality of elements is determined according to `Object#==` and `Object#hash`.
# * `BigSet` assumes that the identity of each element does not change while it is stored. Modifying an element of a set will render the set to an unreliable state.
#
# ### Example
#
# ```
# s1 = BigSet{1, 2}
# s2 = BigArray{1, 2}.to_set
# s3 = BigSet.new [1, 2]
# s1 == s2 # => true
# s1 == s3 # => true
# s1.add(2)
# s1.concat([6, 8])
# s1.subset_of? s2 # => false
# s2.subset_of? s1 # => true
# ```
struct BigSet(T)
  include Enumerable(T)
  include Iterable(T)

  # Creates a new, empty `BigSet`.
  #
  # ```
  # s = BigSet(Int32).new
  # s.empty? # => true
  # ```
  #
  # An initial capacity can be specified, and it will be set as the initial capacity
  # of the internal `Hash`.
  def initialize(initial_capacity = nil)
    @hash = BigHash(T, Nil).new(initial_capacity: initial_capacity)
  end

  protected def initialize(*, using_hash @hash : BigHash(T, Nil))
  end

  # Optimized version of `new` used when *other* is also an `Indexable`
  def self.new(other : Indexable(T))
    BigSet(T).new(other.size).concat(other)
  end

  # Creates a new set from the elements in *enumerable*.
  #
  # ```
  # a = [1, 3, 5]
  # s = BigSet.new a
  # s.empty? # => false
  # ```
  def self.new(enumerable : Enumerable(T))
    BigSet(T).new.concat(enumerable)
  end

  # Makes this set compare objects using their object identity (`object_id)`
  # for types that define such method (`Reference` types, but also structs that
  # might wrap other `Reference` types and delegate the `object_id` method to them).
  #
  # ```
  # s = BigSet{"foo", "bar"}
  # s.includes?("fo" + "o") # => true
  #
  # s.compare_by_identity
  # s.compare_by_identity?  # => true
  # s.includes?("fo" + "o") # => false # not the same String instance
  # ```
  def compare_by_identity : self
    @hash.compare_by_identity
    self
  end

  # Returns `true` if this Set is comparing objects by `object_id`.
  #
  # See `compare_by_identity`.
  def compare_by_identity? : Bool
    @hash.compare_by_identity?
  end

  # Alias for `add`
  def <<(object : T) : self
    add object
  end

  # Adds *object* to the set and returns `self`.
  #
  # ```
  # s = BigSet{1, 5}
  # s.includes? 8 # => false
  # s.add(8)
  # s.includes? 8 # => true
  # ```
  def add(object : T) : self
    @hash[object] = nil
    self
  end

  # Adds *object* to the set and returns `true` on success
  # and `false` if the value was already in the set.
  #
  # ```
  # s = BigSet{1, 5}
  # s.add? 8 # => true
  # s.add? 8 # => false
  # ```
  def add?(object : T) : Bool
    @hash.put(object, nil) { return true }
    false
  end

  # Adds `#each` element of *elems* to the set and returns `self`.
  #
  # ```
  # s = BigSet{1, 5}
  # s.concat [5, 5, 8, 9]
  # s.size # => 4
  # ```
  #
  # See also: `#|` to merge two sets and return a new one.
  def concat(elems) : self
    elems.each { |elem| self << elem }
    self
  end

  # Returns `true` if *object* exists in the set.
  #
  # ```
  # s = BigSet{1, 5}
  # s.includes? 5 # => true
  # s.includes? 9 # => false
  # ```
  def includes?(object) : Bool
    @hash.has_key?(object)
  end

  # Removes the *object* from the set and returns `true` if it was present, otherwise returns `false`.
  #
  # ```
  # s = BigSet{1, 5}
  # s.includes? 5 # => true
  # s.delete 5    # => true
  # s.includes? 5 # => false
  # s.delete 5    # => false
  # ```
  def delete(object) : Bool
    @hash.delete(object) { return false }
    true
  end

  # Returns the number of elements in the set.
  #
  # ```
  # s = BigSet{1, 5}
  # s.size # => 2
  # ```
  def size : UInt64
    @hash.size
  end

  # Removes all elements in the set, and returns `self`.
  #
  # ```
  # s = BigSet{1, 5}
  # s.size # => 2
  # s.clear
  # s.size # => 0
  # ```
  def clear : self
    @hash.clear
    self
  end

  # Returns `true` if the set is empty.
  #
  # ```
  # s = BigSet(Int32).new
  # s.empty? # => true
  # s << 3
  # s.empty? # => false
  # ```
  def empty? : Bool
    @hash.empty?
  end

  # Yields each element of the set, and returns `nil`.
  def each(& : T ->) : Nil
    @hash.each_key do |key|
      yield key
    end
  end

  # Returns an iterator for each element of the set.
  def each
    @hash.each_key
  end

  # Intersection: returns a new set containing elements common to both sets.
  #
  # ```
  # BigSet{1, 1, 3, 5} & BigSet{1, 2, 3}               # => BigSet{1, 3}
  # BigSet{'a', 'b', 'b', 'z'} & BigSet{'a', 'b', 'c'} # => BigSet{'a', 'b'}
  # ```
  def &(other : BigSet) : BigSet(T)
    smallest, largest = self, other
    if largest.size < smallest.size
      smallest, largest = largest, smallest
    end

    set = BigSet(T).new
    smallest.each do |value|
      set.add value if largest.includes?(value)
    end
    set
  end

  # Union: returns a new set containing all unique elements from both sets.
  #
  # ```
  # BigSet{1, 1, 3, 5} | BigSet{1, 2, 3}               # => BigSet{1, 3, 5, 2}
  # BigSet{'a', 'b', 'b', 'z'} | BigSet{'a', 'b', 'c'} # => BigSet{'a', 'b', 'z', 'c'}
  # ```
  #
  # See also: `#concat` to add elements from a set to `self`.
  def |(other : BigSet(U)) : BigSet(T | U) forall U
    set = BigSet(T | U).new(Math.max(size, other.size))
    each { |value| set.add value }
    other.each { |value| set.add value }
    set
  end

  # Addition: returns a new set containing the unique elements from both sets.
  #
  # ```
  # BigSet{1, 1, 2, 3} + BigSet{3, 4, 5} # => BigSet{1, 2, 3, 4, 5}
  # ```
  def +(other : BigSet(U)) : BigSet(T | U) forall U
    self | other
  end

  # Returns the additive identity of this type.
  #
  # This is an empty set.
  def self.additive_identity : self
    new
  end

  # Difference: returns a new set containing elements in this set that are not
  # present in the other.
  #
  # ```
  # BigSet{1, 2, 3, 4, 5} - BigSet{2, 4}               # => BigSet{1, 3, 5}
  # BigSet{'a', 'b', 'b', 'z'} - BigSet{'a', 'b', 'c'} # => BigSet{'z'}
  # ```
  def -(other : BigSet) : BigSet(T)
    set = Set(T).new
    each do |value|
      set.add value unless other.includes?(value)
    end
    set
  end

  # Difference: returns a new set containing elements in this set that are not
  # present in the other enumerable.
  #
  # ```
  # BigSet{1, 2, 3, 4, 5} - [2, 4]               # => BigSet{1, 3, 5}
  # BigSet{'a', 'b', 'b', 'z'} - ['a', 'b', 'c'] # => BigSet{'z'}
  # ```
  def -(other : Enumerable) : BigSet(T)
    dup.subtract other
  end

  # Symmetric Difference: returns a new set `(self - other) | (other - self)`.
  # Equivalently, returns `(self | other) - (self & other)`.
  #
  # ```
  # BigSet{1, 2, 3, 4, 5} ^ BigSet{2, 4, 6}            # => BigSet{1, 3, 5, 6}
  # BigSet{'a', 'b', 'b', 'z'} ^ BigSet{'a', 'b', 'c'} # => BigSet{'z', 'c'}
  # ```
  def ^(other : BigSet(U)) : BigSet(T | U) forall U
    set = BigSet(T | U).new
    each do |value|
      set.add value unless other.includes?(value)
    end
    other.each do |value|
      set.add value unless includes?(value)
    end
    set
  end

  # Symmetric Difference: returns a new set `(self - other) | (other - self)`.
  # Equivalently, returns `(self | other) - (self & other)`.
  #
  # ```
  # BigSet{1, 2, 3, 4, 5} ^ [2, 4, 6]            # => BigSet{1, 3, 5, 6}
  # BigSet{'a', 'b', 'b', 'z'} ^ ['a', 'b', 'c'] # => BigSet{'z', 'c'}
  # ```
  def ^(other : Enumerable(U)) : BigSet(T | U) forall U
    set = BigSet(T | U).new(self)
    other.each do |value|
      if includes?(value)
        set.delete value
      else
        set.add value
      end
    end
    set
  end

  # Returns `self` after removing from it those elements that are present in
  # the given enumerable.
  #
  # ```
  # BigSet{'a', 'b', 'b', 'z'}.subtract BigSet{'a', 'b', 'c'} # => BigSet{'z'}
  # BigSet{1, 2, 3, 4, 5}.subtract [2, 4, 6]               # => BigSet{1, 3, 5}
  # ```
  def subtract(other : Enumerable) : self
    other.each do |value|
      delete value
    end
    self
  end

  # Returns `true` if both sets have the same elements.
  #
  # ```
  # BigSet{1, 5} == BigSet{1, 5} # => true
  # ```
  def ==(other : BigSet) : Bool
    same?(other) || @hash == other.@hash
  end

  # Same as `#includes?`.
  #
  # It is for convenience with using on `case` statement.
  #
  # ```
  # red_like = BigSet{"red", "pink", "violet"}
  # blue_like = BigSet{"blue", "azure", "violet"}
  #
  # case "violet"
  # when red_like & blue_like
  #   puts "red & blue like color!"
  # when red_like
  #   puts "red like color!"
  # when blue_like
  #   puts "blue like color!"
  # end
  # ```
  #
  # See also: `Object#===`.
  def ===(object : T) : Bool
    includes? object
  end

  # Returns a new `BigSet` with all of the same elements.
  def dup : BigSet(T)
    set = BigSet(T).new(using_hash: @hash.dup)
    set.compare_by_identity if compare_by_identity?
    set
  end

  # Returns a new `BigSet` with all of the elements cloned.
  def clone : BigSet(T)
    clone = BigSet(T).new(self.size)
    clone.compare_by_identity if compare_by_identity?
    each do |element|
      clone << element.clone
    end
    clone
  end

  # Returns the elements as a `BigArray`.
  #
  # ```
  # BigSet{1, 5}.to_a # => BigArray{1,5}
  # ```
  def to_a : BigArray(T)
    @hash.keys
  end

  # Returns a `BigArray` with the results of running *block* against each element of the collection.
  #
  # ```
  # Set{1, 2, 3, 4, 5}.to_a { |i| i // 2 } # => BigArray{0, 1, 1, 2, 2}
  # ```
  def to_a(& : T -> U) : BigArray(U) forall U
    array = BigArray(U).new(size)
    @hash.each_key do |key|
      array << yield key
    end
    array
  end

  # Alias of `#to_s`.
  def inspect(io : IO) : Nil
    to_s(io)
  end

  def pretty_print(pp) : Nil
    pp.list("{", self, "}")
  end

  # See `Object#hash(hasher)`
  def_hash @hash

  # Returns `true` if the set and the given set have at least one element in
  # common.
  #
  # ```
  # BigSet{1, 2, 3}.intersects? BigSet{4, 5} # => false
  # BigSet{1, 2, 3}.intersects? BigSet{3, 4} # => true
  # ```
  def intersects?(other : BigSet) : Bool
    if size < other.size
      any? { |o| other.includes?(o) }
    else
      other.any? { |o| includes?(o) }
    end
  end

  # Writes a string representation of the set to *io*.
  def to_s(io : IO) : Nil
    io << "BigSet{"
    join io, ", ", &.inspect(io)
    io << '}'
  end

  # Returns `true` if the set is a subset of the *other* set.
  #
  # This set must have the same or fewer elements than the *other* set, and all
  # of elements in this set must be present in the *other* set.
  #
  # ```
  # BigSet{1, 5}.subset_of? BigSet{1, 3, 5}    # => true
  # BigSet{1, 3, 5}.subset_of? BigSet{1, 3, 5} # => true
  # ```
  def subset_of?(other : BigSet) : Bool
    return false if other.size < size
    all? { |value| other.includes?(value) }
  end

  # Returns `true` if the set is a proper subset of the *other* set.
  #
  # This set must have fewer elements than the *other* set, and all
  # of elements in this set must be present in the *other* set.
  #
  # ```
  # BigSet{1, 5}.proper_subset_of? BigSet{1, 3, 5}    # => true
  # BigSet{1, 3, 5}.proper_subset_of? BigSet{1, 3, 5} # => false
  # ```
  def proper_subset_of?(other : BigSet) : Bool
    return false if other.size <= size
    all? { |value| other.includes?(value) }
  end

  # Returns `true` if the set is a superset of the *other* set.
  #
  # The *other* must have the same or fewer elements than this set, and all of
  # elements in the *other* set must be present in this set.
  #
  # ```
  # BigSet{1, 3, 5}.superset_of? BigSet{1, 5}    # => true
  # BigSet{1, 3, 5}.superset_of? BigSet{1, 3, 5} # => true
  # ```
  def superset_of?(other : BigSet) : Bool
    other.subset_of?(self)
  end

  # Returns `true` if the set is a superset of the *other* set.
  #
  # The *other* must have fewer elements than this set, and all of
  # elements in the *other* set must be present in this set.
  #
  # ```
  # BigSet{1, 3, 5}.proper_superset_of? BigSet{1, 5}    # => true
  # BigSet{1, 3, 5}.proper_superset_of? BigSet{1, 3, 5} # => false
  # ```
  def proper_superset_of?(other : BigSet) : Bool
    other.proper_subset_of?(self)
  end

  # :nodoc:
  def object_id : UInt64
    @hash.object_id
  end

  # :nodoc:
  def same?(other : BigSet) : Bool
    @hash.same?(other.@hash)
  end

  # Rebuilds the set based on the current elements.
  #
  # When using mutable data types as elements, modifying an elements after it
  # was inserted into the `BigSet` may lead to undefined behaviour. This method
  # re-indexes the set using the current elements.
  def rehash : Nil
    @hash.rehash
  end
end

module Enumerable
  # Returns a new `BigSet` with each unique element in the enumerable.
  def to_big_set : BigSet(T)
    BigSet.new(self)
  end

  # Returns a new `BigSet` with the unique results of running *block* against each
  # element of the enumerable.
  def to_big_set(&block : T -> U) : BigSet(U) forall U
    set = BigSet(U).new
    each do |elem|
      set << yield elem
    end
    set
  end
end

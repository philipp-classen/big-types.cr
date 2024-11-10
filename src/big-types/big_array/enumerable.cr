module Enumerable
  # Returns a new `BigArray` with each element in the enumerable.
  def to_big_array : BigArray(T)
    BigArray.new(self)
  end

  # Returns a new `BigArray` with the unique results of running *block* against each
  # element of the enumerable.
  def to_big_array(&block : T -> U) : BigArray(U) forall U
    ary = BigArray(U).new
    each do |elem|
      ary << yield elem
    end
    ary
  end
end

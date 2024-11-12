require "../spec_helper"
require "../../src/big-types/big_hash"

describe BigHash do
  it "should allow defining a default value" do
    hash = BigHash(String, Int32).new { 0 }
    hash["foo"].should eq(0)
    hash["foo"] += 1
    hash["foo"].should eq(1)
  end

  it "should allow defining a default value (version with capacity passed)" do
    hash = BigHash(String, Int32).new(42) { 0 }
    hash["foo"].should eq(0)
    hash["foo"] += 1
    hash["foo"].should eq(1)
  end
end

require "./spec_helper"

describe BigTypes do
  it "should work in a simple BigArray example" do
    ary = BigArray{"Eins", "Zwei", "Drei"}
    ary.shift.should eq("Eins")
    ary.shift.should eq("Zwei")
    ary.shift.should eq("Drei")
    ary.shift?.should eq(nil)
  end
end

require 'chatter'

describe Chatter do
  before(:each) do
    @chatter = Class.new
    @chatter.send(:attr_accessor, :value)
    @chatter.extend Chatter
  end

  def any_value
    rand
  end

  def any_function
    proc do |*a|
      a.reverse
    end
  end

  def any_method_name
    :"test_method_#{rand(100)}"
  end

  it "should define the method using block when only one sub-method" do
    v = any_value
    m = any_method_name
    @chatter.chat(m) {v}
    @chatter.new.send(m).should == v
  end

  it "should evaluate method block in instance scope" do
    v = any_value
    m = any_method_name
    @chatter.chat(:test_method) {@value}
    @chatter.new.tap {|o| o.value = v}.test_method.should == v
  end

  it "should combine multiple sub-methods to function like one method" do
    method_body = any_function
    (m1, m2, m3) = Array.new(3) {any_method_name}
    (v1, v2, v3) = Array.new(3) {any_value}
    @chatter.chat(m1, m2, m3, &method_body)
    @chatter.send(:define_method, :equiv_method, &method_body)
    @chatter.new.tap do |o|
      o.send(m1, v1).send(m2, v2).send(m3, v3).should ==
        o.equiv_method(v1, v2, v3)
    end
  end
end
   

require 'chatter'

describe Chatter do
  before(:each) do
    @chatter = Class.new
    @chatter.extend Chatter
  end

  it "should act like define_method when given one sub-method" do
    @chatter.chat(:test_method) {'correct_value'}
    @chatter.new.test_method.should == 'correct_value'
  end

  it "should evaluate method block in instance scope" do
    @chatter.chat(:test_method) {@a}
    @chatter.new.tap do |o|
      o.instance_variable_set(:@a, 'correct_value')
    end.test_method.should == 'correct_value'
  end

  it "should combine multiple sub-methods to function like one method" do
    method_body = proc do |a1, a2, a3|
      [a1, a3] * 2 + [a2]
    end
    @chatter.chat(:test_method_1, :test_method_2, :test_method_3, &method_body)
    @chatter.send(:define_method, :equiv_method, &method_body) 
    @chatter.new.tap do |o|
      o.test_method_1(1).test_method_2(2).test_method_3(3).should ==
        o.equiv_method(1, 2, 3)
    end
  end
end
   

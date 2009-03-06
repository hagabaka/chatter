# Extending Chatter allows using "chat" to define a series of methods
# to do the same task.
#
# = Example
# 
#   class Kid
#     def initialize(name)
#       @name = name
#     end
#   
#     extend Chatter
#   
#     # this is how to use "chat" to define a multi-named method
#     chat(:pass, :to, :saying) do |item, target, words|
#       puts "#{@name} passes #{item} to #{target}, saying '#{words}'"
#     end
#   end
#   
#   jack = Kid.new('Jack')
#   
#   # this is how the method is called
#   jack.pass('ball').to('Jill').saying('catch!')
#   # >> "Jack passes ball to Jill, saying 'catch!'"
module Chatter

  # Define a multi-named method. The block should accept as many argument as
  # method names provided, and the block body is +instance_eval+ed. See Chatter
  # for example usage
  def chat(first_method, *rest_methods, &block)
    if rest_methods.empty?
      # when only one method, act like define_method
      define_method(first_method, &block)
    else
      helper_class = Class.new

      # an instance of helper_class is created when the first sub-method is
      # called, and stores the receiver and arguments
      define_method(first_method) do |*args|
        helper_class.new(self, args)
      end
      helper_class.send(:define_method, :initialize) do |receiver, args|
        @receiver = receiver
        @args = args
      end

      # it accepts the rest of the sub-methods and passes the receiver and
      # arguments down the recursion
      helper_class.extend Chatter
      helper_class.chat(*rest_methods) do |*rest_args|
        @receiver.instance_exec(*(@args + rest_args), &block)
      end
    end
  end
end


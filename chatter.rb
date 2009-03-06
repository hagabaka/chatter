require 'metaid'

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
      helper = Object.new
      helper.metaclass.extend Chatter
      helper.metaclass.chat(*rest_methods) do |*rest_args|
        @object.instance_exec(*(@args + rest_args), &block)
      end

      define_method(first_method) do |*args|
        helper.instance_variable_set(:@object, self)
        helper.instance_variable_set(:@args, args)
        helper
      end
    end
  end
end


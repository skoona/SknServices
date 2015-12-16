##
# /lib/tasks/explorer_task.rake
#
# This file documents a few of the many ways a rake task could be constructed
# - I was most interested in how to pass arguments from the command line.
# - The follow are two methods for doing that.
#


namespace :myspace do

  # task :explorer, [:arg1, :arg2] => [:dependency1, :dependency2]

  # rake myspace:explorer[value1,value2]
  desc 'Demonstrates use of command line params'
  task :explorer, :value1, :value2  do |t, args|
    puts "Args were: #{args}"
    puts "Task is: #{t}"
    puts "Task inspection provides: #{t.inspect}"
  end



  # rake myspace:explorer_params value1=sameValue value2=someMoreVaule
  desc 'Demonstrates use of command line params as ENV params'
  task :explorer_params do |this_task_object, args|
    puts "Args were: #{args}"
    puts "Task is: #{this_task_object}"
    puts "Task inspection provides: #{this_task_object.inspect}"
    puts "Task inspection provides: #{this_task_object.methods}"

    puts "Environment value1=#{ENV["value1"]}, value2=#{ENV["value2"]}"
  end
end

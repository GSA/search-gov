require 'irb'

module IRB
  def self.start_session(binding)
    IRB.setup(nil)

    workspace = WorkSpace.new(binding)

    if @CONF[:SCRIPT]
      irb = Irb.new(workspace, @CONF[:SCRIPT])
    else
      irb = Irb.new(workspace)
    end

    @CONF[:IRB_RC].call(irb.context) if @CONF[:IRB_RC]
    @CONF[:MAIN_CONTEXT] = irb.context

    trap("SIGINT") do
      irb.signal_handle
    end

    catch(:IRB_EXIT) do
      irb.eval_input
    end
  end
end

# Drop into an IRB session for whatever object you pass in:
#
#     class Dude
#       def abides
#         true
#       end
#     end
#     
#     console_for(binding)
#
# Then type "quit" or "exit" to get out. In a step definition, it should look like:
#
#     When /^I console/ do
#       console_for(binding)
#     end
#
# (from http://errtheblog.com/posts/9-drop-to-irb)
def console_for(bounding)
  puts "== ENTERING CONSOLE MODE. ==\nType 'exit' to move on.\nContext: #{eval('self', bounding).inspect}"

  begin
    oldargs = ARGV.dup
    ARGV.clear
    IRB.start_session(bounding)
  ensure
    ARGV.replace(oldargs)
  end
end
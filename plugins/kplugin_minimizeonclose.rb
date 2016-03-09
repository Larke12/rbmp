=begin

  AUTHOR:
   Kesiev <http://www.kesiev.com>
  	
  WHAT IT DOES:
    Minimizes the main window if closed with the X. Use File >> Close to quit.
    Load this as your first plugin.

=end

alias minimizeonclose_shutdown shutdown
def shutdown(from)
  if from==:fromwindow
    $window.hide
    return false
  else
    minimizeonclose_shutdown(from)
  end
end
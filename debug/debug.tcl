# debug.tcl
################################################################################
# Generic debugging tools for the Tcl programmer
#
# Written by Alex Baker, 2020
# ambaker1@mtu.edu
################################################################################

# pause --
#
# Pauses the script, states the source file and line number it is on, 
# and starts an interactive command line mode. 
# The script can then be continued by pressing enter without a command. 

proc pause {} {
    # Wait for user input, evaluate user commands.
    set userInput ""
    puts "PAUSED..."
    set level -1
    while {1} {
        set frameInfo [info frame $level]
        if {[dict get $frameInfo type] eq "source"} {
            break
        } else {
            incr level -1
        }
    }    
    puts "File: [dict get $frameInfo file]"
    puts "Line: [dict get $frameInfo line]"
    puts -nonewline "> "
    while {1} {
        append userInput "[gets stdin]\n"
        if {[string trim $userInput] eq ""} {break}
        if {[info complete $userInput]} {
            # Evaluate user input, but catch for error.
            if {0!=[catch {uplevel 1 $userInput} result error]} {
                puts [dict get $error -errorinfo]
            } elseif {$result ne ""} {
                puts $result
            }
            puts -nonewline "> "
            set userInput ""
        }
    }
    return
}

# pvar --
#
# Same idea as parray. Prints the value of a variable to screen.
# If variable is array, parray will be called, with no pattern.
#
# Arguments:
# name:         Name of variable to print

proc pvar {name} {
    upvar $name var
    if {![info exists var]} {
        return -code error "can't read \"$name\": no such variable"
    } elseif {[array exists var]} {
        # Use native parray function
        uplevel [list parray $name]
    } else {
        puts "$name = $var"
    }
    return
}

# OpenSeesMP emulator
################################################################################
# The command "emulateMP" is a basic emulator of OpenSeesMP, reproducing the 
# behavior of the getPID and getNP commands.
# It does NOT have the send, recv and barrier commands, or parallel solvers.
# To run emulateMP, you must specify the number of processes to run in the 
# background. Optionally, you can specify which pids to run.
# The command will not work if you do not have OpenSees defined on your path.
#
# Written by Alex Baker, 2020
# Michigan Technological University
# ambaker1@mtu.edu
################################################################################
proc emulateMP {args} {
    # Emulates OpenSeesMP on a PC.
    # Arguments:
    # pids:         Processor IDs (0 through NP-1)
    # np:           Number of processors
    # filename:     OpenSeesMP-compatible file
    
    # Examples:
    # emulateMP $np $filename
    # emulateMP $pids $np $filename
    
    # Interpret input
    switch [llength $args] {
        2 {set pids -all}
        3 {set pids [lindex $args 0]}
        default {return -code error "Incorrect number of arguments"}
    }
    set np [lindex $args end-1]
    set filename [lindex $args end]
    if {$pids eq "-all"} {
        # Generate list of all pids
        set pids ""
        for {set pid 0} {$pid < $np} {incr pid} {
            lappend pids $pid
        }
    } else {
        # Check list of pids
        foreach pid $pids {
            if {![string is integer $pid]} {
                return -code error "PIDs must be integer or -all"
            } elseif {$pid < 0} {
                return -code error "PIDs must be positive"
            } elseif {$pid >= $np} {
                return -code error "PIDs must less than NP"
            }
        }
    }

    # Create all processes.
    foreach pid $pids {
        # Open channel to execute OpenSees in background.
        set chan [open |OpenSees w]
        lappend background $chan
        # Define OpenSeesMP commands in channel.
        puts $chan "puts \"RESULTS FROM EMULATED PID $pid:\""
        puts $chan "proc getPID {} {return $pid}\n"
        puts $chan "proc getNP {} {return $np}\n"
        # Source file in channel.
        puts $chan "source {$filename}"
        flush $chan
    }
    # Get results from each.
    foreach chan $background {
        # Get result after waiting for process to finish:
        catch {close $chan} result
        # Return trimmed result to user
        puts [join [lrange [split $result \n] 11 end] \n]
    }
    
    return
}

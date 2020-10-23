# To run this file with emulateMP with 5 processors:
#   source emulateMP.tcl
#   emulateMP 5 example.tcl

puts "PID == [getPID]"
puts "NP == [getNP]"
for {set i 0} {$i < 100} {incr i} {
    if {$i % [getNP] == [getPID]} {
        puts "Task $i is mine"
    }
}

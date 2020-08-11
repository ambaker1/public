# getVecXZ.tcl
proc getVecXZ {nodeI nodeJ vecXY} {
    # Gets the local XZ vector required for the 3D geometric transformation
    # Performs the cross-product of the vector from I to J and vecXY
    # Inspired by Python code by Michael Scott, Oregon State University
    # Written by: Alex Baker, Michigan Technological University
    # Date: 08/2020
    
    # Arguments:
    # nodeI:        First node of frame element
    # nodeJ:        Second node of frame element
    # vecXY:        A vector in the local XY plane of element.
    
    # Notes: 
    # If vecXY is in a line with nodeI and nodeJ, this will return error.
    # If your section is not symmetric about the local Y axis, check results.

    # Get node coords and check input
    set coordsI [nodeCoord $nodeI]
    set coordsJ [nodeCoord $nodeJ]
    if {[llength $coordsI]!=3 || [llength $coordsJ]!=3} {
        return -code error "Input nodes must be 3-dimensional"
    } elseif {[llength $vecXY]!=3} {
        return -code error "XY vector must be 3-dimensional"
    }
    
    # Get vector from node I to node J
    set vecX ""
    foreach coordI $coordsI coordJ $coordsJ {
        lappend vecX [expr $coordJ - $coordI]
    }
    
    # Compute cross-product (Tcllib 1.18 math::linearalgebra)
    foreach {v11 v12 v13} $vecX {v21 v22 v23} $vecXY break
    set vecXZ [list \
        [expr $v12*$v23 - $v13*$v22] \
        [expr $v13*$v21 - $v11*$v23] \
        [expr $v11*$v22 - $v12*$v21] ]
        
    # Check for null case
    if {[lindex $vecXZ 0]==0 && [lindex $vecXZ 1]==0 && [lindex $vecXZ 2]==0} {
        return -code error "XY vector cannot be in line with nodes I & J"
    }
    
    # Normalize to unit vector
    set norm [expr sqrt([join [lmap v $vecXZ {expr $v**2}] +])]
    set vecXZ [lmap v $vecXZ {expr $v/$norm}]
    
    # Return the vector defined in local XZ
    return $vecXZ
}

# Example:
model BasicBuilder -ndm 3 
node 1 0 0 0
node 2 1 1 1

set vecXZ [getVecXZ 1 2 {0 1 0}]
puts $vecXZ
geomTransf Linear 1 {*}$vecXZ

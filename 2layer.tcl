# this runs a simple two layer saturated aquifer case
# with infrastructure to connect to something like PEST
# input for the two layers is set from a simple ascii text file 
# output is grabbed from the pressure file and written to
# a simple text file so another software package can read it
#
#  Reed Maxwell rmaxwell@mines.edu Jul-2018
#
# Import the ParFlow TCL package
#
lappend auto_path $env(PARFLOW_DIR)/bin
package require parflow
namespace import Parflow::*


#-----------------------------------------------------------------------------
# File input version number
#-----------------------------------------------------------------------------
pfset FileVersion 4

#-----------------------------------------------------------------------------
# Process Topology
#-----------------------------------------------------------------------------

pfset Process.Topology.P        1
pfset Process.Topology.Q        1
pfset Process.Topology.R        1

#-----------------------------------------------------------------------------
# Computational Grid
#-----------------------------------------------------------------------------
pfset ComputationalGrid.Lower.X                0.0
pfset ComputationalGrid.Lower.Y                0.0
pfset ComputationalGrid.Lower.Z                 0.0

pfset ComputationalGrid.DX	                 10.0
pfset ComputationalGrid.DY                    10.0
pfset ComputationalGrid.DZ	                 0.5

pfset ComputationalGrid.NX                      50
pfset ComputationalGrid.NY                      30
pfset ComputationalGrid.NZ                      100

#-----------------------------------------------------------------------------
# The Names of the GeomInputs
#-----------------------------------------------------------------------------
pfset GeomInput.Names "domain_input upper_aquifer_input lower_aquifer_input"


#-----------------------------------------------------------------------------
# Domain Geometry Input
#-----------------------------------------------------------------------------
pfset GeomInput.domain_input.InputType            Box
pfset GeomInput.domain_input.GeomName             domain

#-----------------------------------------------------------------------------
# Domain Geometry
#-----------------------------------------------------------------------------
pfset Geom.domain.Lower.X                        0.0
pfset Geom.domain.Lower.Y                        0.0
pfset Geom.domain.Lower.Z                          0.0

pfset Geom.domain.Upper.X                        500.0
pfset Geom.domain.Upper.Y                        300.
pfset Geom.domain.Upper.Z                        50.0

pfset Geom.domain.Patches "left right front back bottom top"

#-----------------------------------------------------------------------------
# Upper Aquifer Geometry Input
#-----------------------------------------------------------------------------
pfset GeomInput.upper_aquifer_input.InputType            Box
pfset GeomInput.upper_aquifer_input.GeomName             upper_aquifer

#-----------------------------------------------------------------------------
# Upper Aquifer Geometry
#-----------------------------------------------------------------------------
pfset Geom.upper_aquifer.Lower.X                        0.0
pfset Geom.upper_aquifer.Lower.Y                        0.0
pfset Geom.upper_aquifer.Lower.Z                        30.0

pfset Geom.upper_aquifer.Upper.X                        500.0
pfset Geom.upper_aquifer.Upper.Y                        300.
pfset Geom.upper_aquifer.Upper.Z                        50.

#-----------------------------------------------------------------------------
# Lower Aquifer Geometry Input
#-----------------------------------------------------------------------------
pfset GeomInput.lower_aquifer_input.InputType            Box
pfset GeomInput.lower_aquifer_input.GeomName             lower_aquifer

#-----------------------------------------------------------------------------
# Lower Aquifer Geometry
#-----------------------------------------------------------------------------
pfset Geom.lower_aquifer.Lower.X                        0.0
pfset Geom.lower_aquifer.Lower.Y                        0.0
pfset Geom.lower_aquifer.Lower.Z                        0.0

pfset Geom.lower_aquifer.Upper.X                        500.0
pfset Geom.lower_aquifer.Upper.Y                        300.
pfset Geom.lower_aquifer.Upper.Z                        30.


#-----------------------------------------------------------------------------
# Perm
#-----------------------------------------------------------------------------
pfset Geom.Perm.Names "upper_aquifer lower_aquifer"
# we open a file, in this case from PEST to set upper and lower aquifer values
# k1=upper_aquifer k2=lower_aquifer

set fileId [open input.txt r 0600]
set k1 [gets $fileId]
set k2 [gets $fileId]
close $fileId
## output K values used this run
puts "K layer 1: $k1"
puts "K layer 2: $k2"

## we use the parallel turning bands formulation in ParFlow to simulate
## GRF for upper and lower aquifer
##

pfset Geom.upper_aquifer.Perm.Type Constant
pfset Geom.lower_aquifer.Perm.Type Constant

#pfset lower aqu and upper aq stats to pest/read in values

pfset Geom.upper_aquifer.Perm.Value  $k1

pfset Geom.lower_aquifer.Perm.Value  $k2


pfset Perm.TensorType               TensorByGeom

pfset Geom.Perm.TensorByGeom.Names  "domain"

pfset Geom.domain.Perm.TensorValX  1.0
pfset Geom.domain.Perm.TensorValY  1.0
pfset Geom.domain.Perm.TensorValZ  1.0

#-----------------------------------------------------------------------------
# Specific Storage
#-----------------------------------------------------------------------------
# specific storage does not figure into the impes (fully sat) case but we still
# need a key for it

pfset SpecificStorage.Type            Constant
pfset SpecificStorage.GeomNames       ""
pfset Geom.domain.SpecificStorage.Value 1.0e-4

#-----------------------------------------------------------------------------
# Phases
#-----------------------------------------------------------------------------

pfset Phase.Names "water"

pfset Phase.water.Density.Type	Constant
pfset Phase.water.Density.Value	1.0

pfset Phase.water.Viscosity.Type	Constant
pfset Phase.water.Viscosity.Value	1.0

#-----------------------------------------------------------------------------
# Contaminants
#-----------------------------------------------------------------------------
pfset Contaminants.Names			""


#-----------------------------------------------------------------------------
# Gravity
#-----------------------------------------------------------------------------

pfset Gravity				1.0

#-----------------------------------------------------------------------------
# Setup timing info
#-----------------------------------------------------------------------------

pfset TimingInfo.BaseUnit		1.0
pfset TimingInfo.StartCount		-1
pfset TimingInfo.StartTime		0.0
pfset TimingInfo.StopTime            0.0
pfset TimingInfo.DumpInterval	       -1

#-----------------------------------------------------------------------------
# Porosity
#-----------------------------------------------------------------------------

pfset Geom.Porosity.GeomNames          domain

pfset Geom.domain.Porosity.Type    Constant
pfset Geom.domain.Porosity.Value   0.390

#-----------------------------------------------------------------------------
# Domain
#-----------------------------------------------------------------------------
pfset Domain.GeomName domain

#-----------------------------------------------------------------------------
# Mobility
#-----------------------------------------------------------------------------
pfset Phase.water.Mobility.Type        Constant
pfset Phase.water.Mobility.Value       1.0


#-----------------------------------------------------------------------------
# Wells
#-----------------------------------------------------------------------------
pfset Wells.Names ""


#-----------------------------------------------------------------------------
# Time Cycles
#-----------------------------------------------------------------------------
pfset Cycle.Names constant
pfset Cycle.constant.Names		"alltime"
pfset Cycle.constant.alltime.Length	 1
pfset Cycle.constant.Repeat		-1

#-----------------------------------------------------------------------------
# Boundary Conditions: Pressure
#-----------------------------------------------------------------------------
pfset BCPressure.PatchNames "left right front back bottom top"

pfset Patch.left.BCPressure.Type			DirEquilRefPatch
pfset Patch.left.BCPressure.Cycle			"constant"
pfset Patch.left.BCPressure.RefGeom			domain
pfset Patch.left.BCPressure.RefPatch			top
pfset Patch.left.BCPressure.alltime.Value		5.0

pfset Patch.right.BCPressure.Type			FluxConst
pfset Patch.right.BCPressure.Cycle			"constant"
pfset Patch.right.BCPressure.RefGeom			domain
pfset Patch.right.BCPressure.RefPatch			top
pfset Patch.right.BCPressure.alltime.Value		0.001

pfset Patch.front.BCPressure.Type			FluxConst
pfset Patch.front.BCPressure.Cycle			"constant"
pfset Patch.front.BCPressure.alltime.Value		0.0

pfset Patch.back.BCPressure.Type			FluxConst
pfset Patch.back.BCPressure.Cycle			"constant"
pfset Patch.back.BCPressure.alltime.Value		0.0

pfset Patch.bottom.BCPressure.Type			FluxConst
pfset Patch.bottom.BCPressure.Cycle			"constant"
pfset Patch.bottom.BCPressure.alltime.Value		0.0

pfset Patch.top.BCPressure.Type			        FluxConst
pfset Patch.top.BCPressure.Cycle			"constant"
pfset Patch.top.BCPressure.alltime.Value		0.0

#---------------------------------------------------------
# Topo slopes in x-direction
#---------------------------------------------------------
# topo slopes do not figure into the impes (fully sat) case but we still
# need keys for them

pfset TopoSlopesX.Type "Constant"
pfset TopoSlopesX.GeomNames ""

pfset TopoSlopesX.Geom.domain.Value 0.0

#---------------------------------------------------------
# Topo slopes in y-direction
#---------------------------------------------------------

pfset TopoSlopesY.Type "Constant"
pfset TopoSlopesY.GeomNames ""

pfset TopoSlopesY.Geom.domain.Value 0.0

#---------------------------------------------------------
# Mannings coefficient
#---------------------------------------------------------
# mannings roughnesses do not figure into the impes (fully sat) case but we still
# need a key for them

pfset Mannings.Type "Constant"
pfset Mannings.GeomNames ""
pfset Mannings.Geom.domain.Value 0.

#-----------------------------------------------------------------------------
# Phase sources:
#-----------------------------------------------------------------------------

pfset PhaseSources.water.Type                         Constant
pfset PhaseSources.water.GeomNames                    domain
pfset PhaseSources.water.Geom.domain.Value        0.0

#-----------------------------------------------------------------------------
#  Solver Impes
#-----------------------------------------------------------------------------
pfset Solver.MaxIter 50
pfset Solver.AbsTol  1E-10
pfset Solver.Drop   1E-15

#-----------------------------------------------------------------------------
# Run and Unload the ParFlow output files
#-----------------------------------------------------------------------------


pfrun 2layer
pfundist 2layer

# we use pf tools to load presssure
#
set press [pfload 2layer.out.press.pfb]

## uncomment if you want an ascii file of PF output every timestep
##pfsave $press -sa press.sa

# we use pftools to grab observation locations
# and write them to a file

set obs1 [pfgetelt $press 20 20 20]
set obs2 [pfgetelt $press 10 10 10]
set obs3 [pfgetelt $press 5 10 40]
set obs4 [pfgetelt $press 20 10 40]
set obs5 [pfgetelt $press 45 10 10]

set outfile [open Press.txt w]
# just the bare bones output to make things easier for PEST
#puts $outfile "I J K Pressure"
# 20 20 20
puts $outfile [format "%e" $obs1]
# 10 10 10
puts $outfile [format "%e" $obs2]
# 5 10 40
puts $outfile [format "%e" $obs3]
# 20 10 40
puts $outfile [format "%e" $obs4]
# 45 10 10
puts $outfile [format "%e" $obs5]

close $outfile

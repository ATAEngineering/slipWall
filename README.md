# Slip Wall Module
This module was developed by [ATA Engineering](http://www.ata-e.com) as an 
add-on to the Loci/CHEM computational fluid dynamics (CFD) solver. The module 
can be used to extend Loci/CHEM's `viscousWall` boundary condition for use in 
rarefied flows. The module can be used with nonequilibrium flows and supplies 
slip boundary conditions for velocity, translational temperature, and 
vibrational temperature. A Maxwellian slip model like the one shown in [1] is
used.

# Dependencies
This module depends on both Loci and CHEM being installed. Loci is an open
source framework developed at Mississippi State University (MSU) by Dr. Ed 
Luke. The framework provides a rule-based programming model and can take 
advantage of massively parallel high performance computing systems. CHEM is a 
full featured open source CFD code with finite-rate chemistry built on the Loci 
framework. CHEM is export controlled under the International Traffic In Arms 
Regulations (ITAR). Both Loci and CHEM can be obtained from the 
[SimSys Software Forum](http://www.simcenter.msstate.edu) hosted by MSU. A
compiler with C++11 support is also required.

# Installation Instructions
First Loci and CHEM should be installed. The `LOCI_BASE` environment
variable should be set to point to the Loci installation directory. The 
`CHEM_BASE` environment variable should be set to point to the CHEM 
installation directory. The installation process follows the standard 
make, make install procedure.

```bash
make
make install
```

# Usage
First the module must be loaded at the top of the `vars` file. The `viscousWall`
boundary may be tagged with `slip` to enable the slip wall boundary condition. 
The enforcement of the slip condition may be delayed using the `slipDelay` 
input. This uses the traditional no-slip formulation for the first number of
iterations specified to enable the flow to be established. Users can also
relax the enforcement of the slip wall condition by only applying a fraction
of the change to the boundary condition at each iteration. This is useful
for steady problems. In the example below the `BC_1` boundary is set to use a
no-slip formulation for the first 1000 iterations, after which it will switch
to a slip formulation where 10% of the boundary condition update will be applied
at each iteration.

```
loadModule: slipWall

boundary_conditions: <BC_1=viscousWall(slip, Twall=298 K), ...>
slipDelay: 1000
slipRelaxation: 0.1
```

# References
[1] Nompelis, Ioannis, et al. "Effect of Vibrational Nonequilibrium on 
    Hypersonic Double-Cone Experiments". AIAA Journal. Vol. 41, No. 11, Nov 2003.
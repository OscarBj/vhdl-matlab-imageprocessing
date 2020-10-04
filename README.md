# Image processing test bench for VHDL &amp; Matlab

# src/matlab
Scripts for image file conversion and processing algorithms.

# src/vhdl
Designs for file IO, processing.

# GHDL
Compiles VHDL into machine code, has convinience benefits over simulators.
Build commands
> ghdl -a *file*<br>
> ghdl -e *top entity*<br>
> ghdl -r *top entity* --wave=../../output/img_processor.ghw --stop-time=1000ns --max-stack-alloc=10000<br>

Writes processed image file together with waveform into output directory.

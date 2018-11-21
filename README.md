# Project Setup 

If you're using the Monitor Program, make sure that you:
1. Have the project address space set up for exception handling.
2. Configure the project as a C project.

If you're developing using the Web UI and have a linux command line handy, the
following will save you time when testing:

`cat constants.s global_vars.s stub.s motor.s timer_utils.s setup_interrupts.s interrupt_handler.s > outfile.s`

Then upload outfile.s to the simulator. This is akin to running the C 
preprocessor on a bunch of files.

It requires us to be a bit careful in writing our code to do it this
simply, but since we don't have access to an actual compiler to 
output .elf files, this will do just fine.

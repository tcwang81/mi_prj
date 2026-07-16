#!/usr/bin/perl -w
use strict;
use Cwd;
use Getopt::Long;
use Fi1e::Basename;
use Sys::Hostname;
use Env qw(ARCH SGE_ROOT PATH LD_LIBRARY_PATH DIGITAL_DIR PROJECT_ROOT GEV_PROJECT_ROOT);

# Global variables
my $block = "CD06A";                   # block to run                                                                                          
my @command_args;                      # remove simulation files                                                                     
my $cleanup;                           # remove simulation files                                                                     
my $coverage;                          # run with code coverage                                                                      
my $dump = "oFF";                      # dump Format = Fsdb, trn                                                                     
my $Filelist_local = "";               # Filelist in run directory                                                                   
my $Filelist_alt = "";                 # Filelist in run directory                                                                   
my $gen_anacode;                       # generate code For analog sim                                                                
my $BinDir = "";                       # bin directory                                                                               
my $SDFDir = "";                       # SDF directory                                                                               
my $ERROR_cnt = 0;                     # total error count                                                                           
my $mode = "rtl";                      # rtl or gate, deFault is rtl                                                                 
my $case = "wcs";                      # worst case or best case, deFault is worst case                                              
my $nocompile;                         # Do not run verilog compile                                                                  
my $makecsrc;                          # Compile once and make make $RunDirView/INCA_libs directory                                  
my $nosim;                             # Do not run verilog simulation                                                               
my $preclean;                          # irun oF ms                                                                                  
my $nodc;                              # No DC component For FFT SNR calculation                                                     
my $RunDirRegression = "";             # Rename the run directory                                                                    
my $RunDirCoverage = "";               # Code coverage results directory                                                             
my $CodeCoverageCompile = "            # Code coverage command line options                                                          
my $CodeCoverageRun = "";              # Code coverage command line options                                                          
my $DesignDir = "";                    # digital dir root                                                                            
my $ResultsDir = "";                   # run dir                                                                                     
my $RunDirTest = "";                   # test run directory                                                                          
my $SavedDir = "";                     # Save Dir to this                                                                            
my $status_File = "";                  # STATUS File in run directory                                                                
my $SimPath;                                                        
my $simulator = "irun";                # irun or ms, deFault is irun                             
my $TestsDir = "";                     # top level tests directory                                                    
my $testname = "";                     # option variable                                                              
my $StopAtT ime;                       # stop test at this time                                                       
my $start_time;                        # start time                                                                   
my $Finish_time;                       # start time                                                                   
my $timing = "typ";                    # option variable with deFault value (typ)                                     
my $random_seed = 0;                   # random seed                                                                  
my $verilog_compile_sim_log="irun.log"; # verilog compile log Filename                             
my $verilog_sim_log = "irun.ncsc.log"; # verilog run log Filename   
my $verbose = "";                      # option variable                                                               
my $View = "";                         # views=what kind oF run (Fpga, wcs, bcs, rtl)                                  
my $RunDirView = "";                   # rundir of all tests in view (Fpga, wcs, bcs, rtl)                             
my $Usage = "Usage: $0 \                                         
   -Block <block_name> or if no -block then deFault to chip_top> \
   -Cleanup \
   -COverage \
   -Dump <Fsdb|vcd|dump_mem> \
   -Filelist <File> \
   -gen_anacode \
   -Help \
   -seed <number> \
   -Makecsrc \
   -Mode <rtllgate|Fpga> \
   -Case <wcs|bcs> \
   -NOCompile \
   -NOSim \
   -PReclean \
   -Regression <directory> \
    -Simulator <irun|ms> \
   -StopAtTime <#oF miliseconds> \ -TEstname <testname> \
   -TIming <min|typ|max> \
   \n";


   GetArgs();                         #	Get command line arguments                                            
iF ($makecsrc) {                      # if makecsrc (First run regress.pl or sim.run batch jobs)               
	FindDesignDir() ;             # Search For digital root dir                                           
	MakeFilelist();               #	Create rundir and make File list                                      
	VerilogCompileSim();          # compile verilog Files                                                 
}
else {
	FindDesignDir();              # Search For digital root dir                     
	MakeFilelist();               #	Create rundir and make File list                
	VerilogCompileSim();          # compile verilog Files                           
	CheckVerilogLog();            # parse logFile For ERROR                         
	GetFinishTime();              #	get Finish times                                
}


####################################################################################
## GetArgs 
####################################################################################
sub GetArgs {
my %optctl;
my @other_args = '';	# option variable with deFault value (False)
my $help = "";		# help option

  #$block = "chip_top"; #deFault block is chip_top
  # $block = -CD06A-;	#
@command_args = @ARGV;
%optctl = (
	block	=>	\$block,	# block name
	cleanup	=>	\$cleanup,	# dump = Fsdb, vcd
	coverage=>	\$coverage,	# code coverage
	dump	=>	\$dump,		# dump = Fsdb, vcd
	Filelist_alt => \$Filelist_alt,	# alternate source Filelist
	gen_anacode =>  \$gen_anacode,	# generate analog code
	help	=>	\$help,		# get command Usage
	seed	=>	\$random_seed,	# required integer argument
	mode	=>	\$mode ,	# rtl or gate mode, deFault is rtl
	case	=>	\$case,		# best or worst case timing, deFault is worst
	makecsrc=>	\$makecsrc,	# make INCA_libs directory
	nocompile=>	\$nocompile ,	# do not compile
	nosim	=>	\$nosim, 	# do not run verilog simulation
	regression=>	\$RunDirRegression,# regression directory
	nodc	=>	\$nodc,		# no DC For FFt SNR
	preclean=>	\$preclean,	# clean run dir beFors sim
	simulator=>	\$simulator,	# simulator = irun or ms
	StopAtTime=>	\$StopAtTime,	# stop test at this time
	testname=>	\$testname,	# test File name
	timing=>	\$timing,	# sdf timing
	);

unless (GetOptions (\%optctl, 
		    "block=s",                  # pass in string                                                                                               
		    "cleanup",                  # no argument                                                                                                  
		    "coverage",                 # no argument                                                                                                  
		    "dump=s",                   # required string argument                                                                                     
		    "filelist_alt=s",           # required string argument                                                                                     
		    "gen_anacode",              # no argument                                                                                                  
		    "help",                     # no argument                                                                                                  
		    "seed=i",                   # required integer argument                                                                                    
		    "mode=s",                   # required string argument                                                                                     
		    "case=s",                   # required string argument                                                                        
		    "makecsrc",                 # no argument                                                                                   
		    "nocompile",                # no argument                                                                                                  
		    "nosim",                    # no argument                                                                                                  
		    "regression=s" ,            # required argument                                                                                            
		    "nodc",                     # no arguments                                                                                                 
		    "preclean" ,                # no argument^                                                                                                 
		    "testname=s",               # required string argument                                                          
		    "timing=s",                 # required string argument                                                                                     
		    "simulator:s" ,             # optional string argument 
		    "StopAtTime=i"		# required integer argument 
			)) { 
	die "$Usage \n";
}
# capture all other arguments 
@other_args = @ARGV; 
if (@other_args) { 
	print "non_options are @other_args \n";
}
############ check arguments ###### 
if ($help) {
	die "$Usage";
}
############ check testname arg 
if ($testname eq "") {
	die "ERROR $0: -Testname argument required \n $Usage";
}
# remove path inFormation
$testname =" s/^(.*\/)?<[\d\w]+)\/$/$2/;

## check mode arg 
if ($mode ne "rtl" && $mode ne "gate" && $mode ne "fpga") {
	die "ERROR $0: -Mode argument \"$mode\" must be \"rtl\" or \"gate\" or \"Fpga\"\n $Usage";
## check timing argument
if ($timing ne "min" && $timing ne "typ" && $timing ne "max") {
	die "ERROR $0: -TIming argument \"$timing\" must be \"min\" or \"typ\" or \"max\" \n $Usage" )
unless ($simulator eq "irun" || $simulator eq "ms") {
	die "ERROR $0: -Simulator argument \"$simulator\" must be \"irun\" or \"msX"\n";
}

print "\n\nRUNNING TEST $testname ON BLOCK $block... \n\n";
} #endsub GetArgs

###########################################################################
## FindDesignDir	
###########################################################################
sub FindDesignDir {
	# Get current working directory 
	unless ($DesignDir = cwd()) { die "$O: ERROR: invalid current directory \n";
	}
	print "FOUND: DigitalPath1\t\t$DesignDir \n";
	my $basename = "";
	my $base_all = "bin|sim|hdl";
	# stop scanning directory name when $basename is one oF sim|bin|design|system AND
	# all oF the following directories are found chip_top, common
	#while ( !(-d "$DesignDir/hdl" &8< -d "$DesignDir/scripts** && -d "$DesignDir/shared" ) ) { 
	while ( !<-d "$DesignDir/hdl") ) {
	$basename = basename($DesignDir);
	$DesignDir = dirname($DesignDir);
	print "FOUND: DigitalPath2XtXt$DesignDir Xn";
	print "FOUND: basename2XtXt$basename Xn";
	if ($DesignDir eq "/**) {
	die "$0: ERROR: Cannot find base directory ending with $base_all Xn";
	}
####################################################################
#	Setting paths For use later 
####################################################################
#$DIGITAL_DIR = "$DesignDir/hdl";
#$PROJECT_ROOT = "$GEV_PROJECT_ROOT";
# print ''\n\n DesignDir IS $DesignDir \n\n";
	#if ($block eq "chip_top") {
	#if ($block eq "CD06A") {
	$SimPath = "$DesignDir/sim";
	#) else {
	#$SimPath = "$DesignDir/hdl/$block/sim";
	print "\n\Simpath is $SimPath\n\n";

	unless (-d "$SimPath") {
	die "ERROR $0: Cannot Find directory SimPath $SimPath\n";
	}
	$ResultsDir = "$SimPath/results";
	unless (-d "$ResultsDir") {	#iF not exist, make it
		system("mkdir $ResultsDir") == 0
		or die "Can't create directory ResultsDir $ResultsDir \n";
	}
	
# perf - Linux Profiling Tool Documentation (from GitHub source)

Source: https://github.com/torvalds/linux/tree/master/tools/perf/Documentation
Fetched: 2026-02-14

---

## 1. perf.txt - Main Overview

```
perf(1)
=======

NAME
----
perf - Performance analysis tools for Linux

SYNOPSIS
--------
[verse]
'perf' [--version] [--help] [OPTIONS] COMMAND [ARGS]

OPTIONS
-------
-h::
--help::
        Run perf help command.

-v::
--version::
        Display perf version.

-vv::
        Print the compiled-in status of libraries.

--exec-path::
        Display or set exec path.

--html-path::
        Display html documentation path.

-p::
--paginate::
        Set up pager.

--no-pager::
        Do not set pager.

--buildid-dir::
        Setup buildid cache directory. It has higher priority
        than buildid.dir config file option.

--list-cmds::
        List the most commonly used perf commands.

--list-opts::
        List available perf options.

--debugfs-dir::
        Set debugfs directory or set environment variable PERF_DEBUGFS_DIR.

--debug::
        Setup debug variable (see list below) in value
        range (0, 10). Use like:
          --debug verbose   # sets verbose = 1
          --debug verbose=2 # sets verbose = 2

        List of debug variables allowed to set:
          verbose          - general debug messages
          ordered-events   - ordered events object debug messages
          data-convert     - data convert command debug messages
          stderr           - write debug output (option -v) to stderr
                             in browser mode
          perf-event-open  - Print perf_event_open() arguments and
                             return value
          kmaps            - Print kernel and module maps (perf script
                             and perf report without browser)

--debug-file::
	Write debug output to a specified file.

DESCRIPTION
-----------
Performance counters for Linux are a new kernel-based subsystem
that provide a framework for all things performance analysis. It
covers hardware level (CPU/PMU, Performance Monitoring Unit) features
and software features (software counters, tracepoints) as well.

SEE ALSO
--------
linkperf:perf-stat[1], linkperf:perf-top[1],
linkperf:perf-record[1], linkperf:perf-report[1],
linkperf:perf-list[1]

linkperf:perf-amd-ibs[1], linkperf:perf-annotate[1],
linkperf:perf-archive[1], linkperf:perf-arm-spe[1],
linkperf:perf-bench[1], linkperf:perf-buildid-cache[1],
linkperf:perf-buildid-list[1], linkperf:perf-c2c[1],
linkperf:perf-config[1], linkperf:perf-data[1], linkperf:perf-diff[1],
linkperf:perf-evlist[1], linkperf:perf-ftrace[1],
linkperf:perf-help[1], linkperf:perf-inject[1],
linkperf:perf-intel-pt[1], linkperf:perf-iostat[1], linkperf:perf-kallsyms[1],
linkperf:perf-kmem[1], linkperf:perf-kvm[1], linkperf:perf-lock[1],
linkperf:perf-mem[1], linkperf:perf-probe[1], linkperf:perf-sched[1],
linkperf:perf-script[1], linkperf:perf-test[1],
linkperf:perf-trace[1], linkperf:perf-version[1]

```

## 2. perf-record.txt - Recording Profiles

```
perf-record(1)
==============

NAME
----
perf-record - Run a command and record its profile into perf.data

SYNOPSIS
--------
[verse]
'perf record' [-e <EVENT> | --event=EVENT] [-a] <command>
'perf record' [-e <EVENT> | --event=EVENT] [-a] \-- <command> [<options>]

DESCRIPTION
-----------
This command runs a command and gathers a performance counter profile
from it, into perf.data - without displaying anything.

This file can then be inspected later on, using 'perf report'.


OPTIONS
-------
<command>...::
	Any command you can specify in a shell.

-e::
--event=::
	Select the PMU event. Selection can be:

        - a symbolic event name	(use 'perf list' to list all events)

        - a raw PMU event in the form of rN where N is a hexadecimal value
          that represents the raw register encoding with the layout of the
          event control registers as described by entries in
          /sys/bus/event_source/devices/cpu/format/*.

        - a symbolic or raw PMU event followed by an optional colon
	  and a list of event modifiers, e.g., cpu-cycles:p.  See the
	  linkperf:perf-list[1] man page for details on event modifiers.

	- a symbolically formed PMU event like 'pmu/param1=0x3,param2/' where
	  'param1', 'param2', etc are defined as formats for the PMU in
	  /sys/bus/event_source/devices/<pmu>/format/*.

	- a symbolically formed event like 'pmu/config=M,config1=N,config3=K/'

          where M, N, K are numbers (in decimal, hex, octal format). Acceptable
          values for each of 'config', 'config1' and 'config2' are defined by
          corresponding entries in /sys/bus/event_source/devices/<pmu>/format/*
          param1 and param2 are defined as formats for the PMU in:
          /sys/bus/event_source/devices/<pmu>/format/*

	  There are also some parameters which are not defined in .../<pmu>/format/*.
	  These params can be used to overload default config values per event.
	  Here are some common parameters:
	  - 'period': Set event sampling period
	  - 'freq': Set event sampling frequency
	  - 'time': Disable/enable time stamping. Acceptable values are 1 for
		    enabling time stamping. 0 for disabling time stamping.
		    The default is 1.
	  - 'call-graph': Disable/enable callgraph. Acceptable str are "fp" for
			 FP mode, "dwarf" for DWARF mode, "lbr" for LBR mode and
			 "no" for disable callgraph.
	  - 'stack-size': user stack size for dwarf mode
	  - 'name' : User defined event name. Single quotes (') may be used to
		    escape symbols in the name from parsing by shell and tool
		    like this: name=\'CPU_CLK_UNHALTED.THREAD:cmask=0x1\'.
	  - 'aux-output': Generate AUX records instead of events. This requires
			  that an AUX area event is also provided.
	  - 'aux-action': "pause" or "resume" to pause or resume an AUX
			  area event (the group leader) when this event occurs.
			  "start-paused" on an AUX area event itself, will
			  start in a paused state.
	  - 'aux-sample-size': Set sample size for AUX area sampling. If the
	  '--aux-sample' option has been used, set aux-sample-size=0 to disable
	  AUX area sampling for the event.

          See the linkperf:perf-list[1] man page for more parameters.

	  Note: If user explicitly sets options which conflict with the params,
	  the value set by the parameters will be overridden.

	  Also not defined in .../<pmu>/format/* are PMU driver specific
	  configuration parameters.  Any configuration parameter preceded by
	  the letter '@' is not interpreted in user space and sent down directly
	  to the PMU driver.  For example:

	  perf record -e some_event/@cfg1,@cfg2=config/ ...

	  will see 'cfg1' and 'cfg2=config' pushed to the PMU driver associated
	  with the event for further processing.  There is no restriction on
	  what the configuration parameters are, as long as their semantic is
	  understood and supported by the PMU driver.

        - a hardware breakpoint event in the form of '\mem:addr[/len][:access]'
          where addr is the address in memory you want to break in.
          Access is the memory access type (read, write, execute) it can
          be passed as follows: '\mem:addr[:[r][w][x]]'. len is the range,
          number of bytes from specified addr, which the breakpoint will cover.
          If you want to profile read-write accesses in 0x1000, just set
          'mem:0x1000:rw'.
          If you want to profile write accesses in [0x1000~1008), just set
          'mem:0x1000/8:w'.

	- a group of events surrounded by a pair of brace ("{event1,event2,...}").
	  Each event is separated by commas and the group should be quoted to
	  prevent the shell interpretation.  You also need to use --group on
	  "perf report" to view group events together.

--filter=<filter>::
	Event filter.  This option should follow an event selector (-e).
	If the event is a tracepoint, the filter string will be parsed by
	the kernel.  If the event is a hardware trace PMU (e.g. Intel PT
	or CoreSight), it'll be processed as an address filter.  Otherwise
	it means a general filter using BPF which can be applied for any
	kind of event.

	- tracepoint filters

	In the case of tracepoints, multiple '--filter' options are combined
	using '&&'.

	- address filters

	A hardware trace PMU advertises its ability to accept a number of
	address filters	by specifying a non-zero value in
	/sys/bus/event_source/devices/<pmu>/nr_addr_filters.

	Address filters have the format:

	filter|start|stop|tracestop <start> [/ <size>] [@<file name>]

	Where:
	- 'filter': defines a region that will be traced.
	- 'start': defines an address at which tracing will begin.
	- 'stop': defines an address at which tracing will stop.
	- 'tracestop': defines a region in which tracing will stop.

	<file name> is the name of the object file, <start> is the offset to the
	code to trace in that file, and <size> is the size of the region to
	trace. 'start' and 'stop' filters need not specify a <size>.

	If no object file is specified then the kernel is assumed, in which case
	the start address must be a current kernel memory address.

	<start> can also be specified by providing the name of a symbol. If the
	symbol name is not unique, it can be disambiguated by inserting #n where
	'n' selects the n'th symbol in address order. Alternately #0, #g or #G
	select only a global symbol. <size> can also be specified by providing
	the name of a symbol, in which case the size is calculated to the end
	of that symbol. For 'filter' and 'tracestop' filters, if <size> is
	omitted and <start> is a symbol, then the size is calculated to the end
	of that symbol.

	If <size> is omitted and <start> is '*', then the start and size will
	be calculated from the first and last symbols, i.e. to trace the whole
	file.

	If symbol names (or '*') are provided, they must be surrounded by white
	space.

	The filter passed to the kernel is not necessarily the same as entered.
	To see the filter that is passed, use the -v option.

	The kernel may not be able to configure a trace region if it is not
	within a single mapping.  MMAP events (or /proc/<pid>/maps) can be
	examined to determine if that is a possibility.

	Multiple filters can be separated with space or comma.

	- bpf filters

	A BPF filter can access the sample data and make a decision based on the
	data.  Users need to set an appropriate sample type to use the BPF
	filter.  BPF filters need root privilege.

	The sample data field can be specified in lower case letter.  Multiple
	filters can be separated with comma.  For example,

	  --filter 'period > 1000, cpu == 1'
	or
	  --filter 'mem_op == load || mem_op == store, mem_lvl > l1'

	The former filter only accept samples with period greater than 1000 AND
	CPU number is 1.  The latter one accepts either load and store memory
	operations but it should have memory level above the L1.  Since the
	mem_op and mem_lvl fields come from the (memory) data_source, it'd only
	work with some events which set the data_source field.

	Also user should request to collect that information (with -d option in
	the above case).  Otherwise, the following message will be shown.

	  $ sudo perf record -e cycles --filter 'mem_op == load'
	  Error: cycles event does not have PERF_SAMPLE_DATA_SRC
	   Hint: please add -d option to perf record.
	  failed to set filter "BPF" on event cycles with 22 (Invalid argument)

	Essentially the BPF filter expression is:

	  <term> <operator> <value> (("," | "||") <term> <operator> <value>)*

	The <term> can be one of:
	  ip, id, tid, pid, cpu, time, addr, period, txn, weight, phys_addr,
	  code_pgsz, data_pgsz, weight1, weight2, weight3, ins_lat, retire_lat,
	  p_stage_cyc, mem_op, mem_lvl, mem_snoop, mem_remote, mem_lock,
	  mem_dtlb, mem_blk, mem_hops, uid, gid

	The <operator> can be one of:
	  ==, !=, >, >=, <, <=, &

	The <value> can be one of:
	  <number> (for any term)
	  na, load, store, pfetch, exec (for mem_op)
	  l1, l2, l3, l4, cxl, io, any_cache, lfb, ram, pmem (for mem_lvl)
	  na, none, hit, miss, hitm, fwd, peer (for mem_snoop)
	  remote (for mem_remote)
	  na, locked (for mem_locked)
	  na, l1_hit, l1_miss, l2_hit, l2_miss, any_hit, any_miss, walk, fault (for mem_dtlb)
	  na, by_data, by_addr (for mem_blk)
	  hops0, hops1, hops2, hops3 (for mem_hops)

--exclude-perf::
	Don't record events issued by perf itself. This option should follow
	an event selector (-e) which selects tracepoint event(s). It adds a
	filter expression 'common_pid != $PERFPID' to filters. If other
	'--filter' exists, the new filter expression will be combined with
	them by '&&'.

--latency::
	Enable data collection for latency profiling.
	Use perf report --latency for latency-centric profile.

-a::
--all-cpus::
        System-wide collection from all CPUs (default if no target is specified).

-p::
--pid=::
	Record events on existing process ID (comma separated list).

-t::
--tid=::
        Record events on existing thread ID (comma separated list).
        This option also disables inheritance by default.  Enable it by adding
        --inherit.

-u::
--uid=::
        Record events in threads owned by uid. Name or number.

-r::
--realtime=::
	Collect data with this RT SCHED_FIFO priority.

--no-buffering::
	Collect data without buffering.

-c::
--count=::
	Event period to sample.

-o::
--output=::
	Output file name.

-i::
--no-inherit::
	Child tasks do not inherit counters.

-F::
--freq=::
	Profile at this frequency. Use 'max' to use the currently maximum
	allowed frequency, i.e. the value in the kernel.perf_event_max_sample_rate
	sysctl. Will throttle down to the currently maximum allowed frequency.
	See --strict-freq.

--strict-freq::
	Fail if the specified frequency can't be used.

-m::
--mmap-pages=::
	Number of mmap data pages (must be a power of two) or size
	specification in bytes with appended unit character - B/K/M/G.
	The size is rounded up to the nearest power-of-two page value.
	By adding a comma, an additional parameter with the same
	semantics used for the normal mmap areas can be specified for
	AUX tracing area.

-g::
	Enables call-graph (stack chain/backtrace) recording for both
	kernel space and user space.

--call-graph::
	Setup and enable call-graph (stack chain/backtrace) recording,
	implies -g.  Default is "fp" (for user space).

	The unwinding method used for kernel space is dependent on the
	unwinder used by the active kernel configuration, i.e
	CONFIG_UNWINDER_FRAME_POINTER (fp) or CONFIG_UNWINDER_ORC (orc)

	Any option specified here controls the method used for user space.

	Valid options are "fp" (frame pointer), "dwarf" (DWARF's CFI -
	Call Frame Information) or "lbr" (Hardware Last Branch Record
	facility).

	In some systems, where binaries are build with gcc
	--fomit-frame-pointer, using the "fp" method will produce bogus
	call graphs, using "dwarf", if available (perf tools linked to
	the libunwind or libdw library) should be used instead.
	Using the "lbr" method doesn't require any compiler options. It
	will produce call graphs from the hardware LBR registers. The
	main limitation is that it is only available on new Intel
	platforms, such as Haswell. It can only get user call chain. It
	doesn't work with branch stack sampling at the same time.

	When "dwarf" recording is used, perf also records (user) stack dump
	when sampled.  Default size of the stack dump is 8192 (bytes).
	User can change the size by passing the size after comma like
	"--call-graph dwarf,4096".

	When "fp" recording is used, perf tries to save stack entries
	up to the number specified in sysctl.kernel.perf_event_max_stack
	by default.  User can change the number by passing it after comma
	like "--call-graph fp,32".

	Also "defer" can be used with "fp" (like "--call-graph fp,defer") to
	enable deferred user callchain which will collect user-space callchains
	when the thread returns to the user space.

-q::
--quiet::
	Don't print any warnings or messages, useful for scripting.

-v::
--verbose::
	Be more verbose (show counter open errors, etc).

-s::
--stat::
	Record per-thread event counts.  Use it with 'perf report -T' to see
	the values.

-d::
--data::
	Record the sample virtual addresses.  Implies --sample-mem-info.

--phys-data::
	Record the sample physical addresses.

--data-page-size::
	Record the sampled data address data page size.

--code-page-size::
	Record the sampled code address (ip) page size

-T::
--timestamp::
	Record the sample timestamps. Use it with 'perf report -D' to see the
	timestamps, for instance.

-P::
--period::
	Record the sample period.

--sample-cpu::
	Record the sample cpu.

--sample-identifier::
	Record the sample identifier i.e. PERF_SAMPLE_IDENTIFIER bit set in
	the sample_type member of the struct perf_event_attr argument to the
	perf_event_open system call.

--sample-mem-info::
	Record the sample data source information for memory operations.
	It requires hardware supports and may work on specific events only.
	Please consider using 'perf mem record' instead if you're not sure.

-n::
--no-samples::
	Don't sample.

-R::
--raw-samples::
Collect raw sample records from all opened counters (default for tracepoint counters).

-C::
--cpu::
Collect samples only on the list of CPUs provided. Multiple CPUs can be provided as a
comma-separated list with no space: 0,1. Ranges of CPUs are specified with -: 0-2.
In per-thread mode with inheritance mode on (default), samples are captured only when
the thread executes on the designated CPUs. Default is to monitor all CPUs.

User space tasks can migrate between CPUs, so when tracing selected CPUs,
a dummy event is created to track sideband for all CPUs.

-B::
--no-buildid::
Do not save the build ids of binaries in the perf.data files. This skips
post processing after recording, which sometimes makes the final step in
the recording process to take a long time, as it needs to process all
events looking for mmap records. The downside is that it can misresolve
symbols if the workload binaries used when recording get locally rebuilt
or upgraded, because the only key available in this case is the
pathname. You can also set the "record.build-id" config variable to
'skip to have this behaviour permanently.

-N::
--no-buildid-cache::
Do not update the buildid cache. This saves some overhead in situations
where the information in the perf.data file (which includes buildids)
is sufficient.  You can also set the "record.build-id" config variable to
'no-cache' to have the same effect.

-G name,...::
--cgroup name,...::
monitor only in the container (cgroup) called "name". This option is available only
in per-cpu mode. The cgroup filesystem must be mounted. All threads belonging to
container "name" are monitored when they run on the monitored CPUs. Multiple cgroups
can be provided. Each cgroup is applied to the corresponding event, i.e., first cgroup
to first event, second cgroup to second event and so on. It is possible to provide
an empty cgroup (monitor all the time) using, e.g., -G foo,,bar. Cgroups must have
corresponding events, i.e., they always refer to events defined earlier on the command
line. If the user wants to track multiple events for a specific cgroup, the user can
use '-e e1 -e e2 -G foo,foo' or just use '-e e1 -e e2 -G foo'.

If wanting to monitor, say, 'cycles' for a cgroup and also for system wide, this
command line can be used: 'perf stat -e cycles -G cgroup_name -a -e cycles'.

-b::
--branch-any::
Enable taken branch stack sampling. Any type of taken branch may be sampled.
This is a shortcut for --branch-filter any. See --branch-filter for more infos.

-j::
--branch-filter::
Enable taken branch stack sampling. Each sample captures a series of consecutive
taken branches. The number of branches captured with each sample depends on the
underlying hardware, the type of branches of interest, and the executed code.
It is possible to select the types of branches captured by enabling filters. The
following filters are defined:

        - any:  any type of branches
        - any_call: any function call or system call
        - any_ret: any function return or system call return
        - ind_call: any indirect branch
        - ind_jmp: any indirect jump
        - call: direct calls, including far (to/from kernel) calls
        - u:  only when the branch target is at the user level
        - k: only when the branch target is in the kernel
        - hv: only when the target is at the hypervisor level
	- in_tx: only when the target is in a hardware transaction
	- no_tx: only when the target is not in a hardware transaction
	- abort_tx: only when the target is a hardware transaction abort
	- cond: conditional branches
	- call_stack: save call stack
	- no_flags: don't save branch flags e.g prediction, misprediction etc
	- no_cycles: don't save branch cycles
	- hw_index: save branch hardware index
	- save_type: save branch type during sampling in case binary is not available later
		     For the platforms with Intel Arch LBR support (12th-Gen+ client or
		     4th-Gen Xeon+ server), the save branch type is unconditionally enabled
		     when the taken branch stack sampling is enabled.
	- priv: save privilege state during sampling in case binary is not available later
	- counter: save occurrences of the event since the last branch entry. Currently, the
		   feature is only supported by a newer CPU, e.g., Intel Sierra Forest and
		   later platforms. An error out is expected if it's used on the unsupported
		   kernel or CPUs.

+
The option requires at least one branch type among any, any_call, any_ret, ind_call, cond.
The privilege levels may be omitted, in which case, the privilege levels of the associated
event are applied to the branch filter. Both kernel (k) and hypervisor (hv) privilege
levels are subject to permissions.  When sampling on multiple events, branch stack sampling
is enabled for all the sampling events. The sampled branch type is the same for all events.
The various filters must be specified as a comma separated list: --branch-filter any_ret,u,k
Note that this feature may not be available on all processors.

-W::
--weight::
Enable weightened sampling. An additional weight is recorded per sample and can be
displayed with the weight and local_weight sort keys.  This currently works for TSX
abort events and some memory events in precise mode on modern Intel CPUs.

--namespaces::
Record events of type PERF_RECORD_NAMESPACES.  This enables 'cgroup_id' sort key.

--all-cgroups::
Record events of type PERF_RECORD_CGROUP.  This enables 'cgroup' sort key.

--transaction::
Record transaction flags for transaction related events.

--per-thread::
Use per-thread mmaps.  By default per-cpu mmaps are created.  This option
overrides that and uses per-thread mmaps.  A side-effect of that is that
inheritance is automatically disabled.  --per-thread is ignored with a warning
if combined with -a or -C options.

-D::
--delay=::
After starting the program, wait msecs before measuring (-1: start with events
disabled), or enable events only for specified ranges of msecs (e.g.
-D 10-20,30-40 means wait 10 msecs, enable for 10 msecs, wait 10 msecs, enable
for 10 msecs, then stop). Note, delaying enabling of events is useful to filter
out the startup phase of the program, which is often very different.

-I::
--intr-regs::
Capture machine state (registers) at interrupt, i.e., on counter overflows for
each sample. List of captured registers depends on the architecture. This option
is off by default. It is possible to select the registers to sample using their
symbolic names, e.g. on x86, ax, si. To list the available registers use
--intr-regs=\?. To name registers, pass a comma separated list such as
--intr-regs=ax,bx. The list of register is architecture dependent.

--user-regs::
Similar to -I, but capture user registers at sample time. To list the available
user registers use --user-regs=\?.

--running-time::
Record running and enabled time for read events (:S)

-k::
--clockid::
Sets the clock id to use for the various time fields in the perf_event_type
records. See clock_gettime(). In particular CLOCK_MONOTONIC and
CLOCK_MONOTONIC_RAW are supported, some events might also allow
CLOCK_BOOTTIME, CLOCK_REALTIME and CLOCK_TAI.

-S::
--snapshot::
Select AUX area tracing Snapshot Mode. This option is valid only with an
AUX area tracing event. Optionally, certain snapshot capturing parameters
can be specified in a string that follows this option:

  - 'e': take one last snapshot on exit; guarantees that there is at least one
       snapshot in the output file;
  - <size>: if the PMU supports this, specify the desired snapshot size.

In Snapshot Mode trace data is captured only when signal SIGUSR2 is received
and on exit if the above 'e' option is given.

--aux-sample[=OPTIONS]::
Select AUX area sampling. At least one of the events selected by the -e option
must be an AUX area event. Samples on other events will be created containing
data from the AUX area. Optionally sample size may be specified, otherwise it
defaults to 4KiB.

--proc-map-timeout::
When processing pre-existing threads /proc/XXX/mmap, it may take a long time,
because the file may be huge. A time out is needed in such cases.
This option sets the time out limit. The default value is 500 ms.

--switch-events::
Record context switch events i.e. events of type PERF_RECORD_SWITCH or
PERF_RECORD_SWITCH_CPU_WIDE. In some cases (e.g. Intel PT, CoreSight or Arm SPE)
switch events will be enabled automatically, which can be suppressed by
by the option --no-switch-events.

--vmlinux=PATH::
Specify vmlinux path which has debuginfo.
(enabled when BPF prologue is on)

--buildid-all::
Record build-id of all DSOs regardless whether it's actually hit or not.

--buildid-mmap::
Legacy record build-id in map events option which is now the
default. Behaves indentically to --no-buildid. Disable with
--no-buildid-mmap.

--aio[=n]::
Use <n> control blocks in asynchronous (Posix AIO) trace writing mode (default: 1, max: 4).
Asynchronous mode is supported only when linking Perf tool with libc library
providing implementation for Posix AIO API.

--affinity=mode::
Set affinity mask of trace reading thread according to the policy defined by 'mode' value:

  - node - thread affinity mask is set to NUMA node cpu mask of the processed mmap buffer
  - cpu  - thread affinity mask is set to cpu of the processed mmap buffer

--mmap-flush=number::

Specify minimal number of bytes that is extracted from mmap data pages and
processed for output. One can specify the number using B/K/M/G suffixes.

The maximal allowed value is a quarter of the size of mmaped data pages.

The default option value is 1 byte which means that every time that the output
writing thread finds some new data in the mmaped buffer the data is extracted,
possibly compressed (-z) and written to the output, perf.data or pipe.

Larger data chunks are compressed more effectively in comparison to smaller
chunks so extraction of larger chunks from the mmap data pages is preferable
from the perspective of output size reduction.

Also at some cases executing less output write syscalls with bigger data size
can take less time than executing more output write syscalls with smaller data
size thus lowering runtime profiling overhead.

-z::
--compression-level[=n]::
Produce compressed trace using specified level n (default: 1 - fastest compression,
22 - smallest trace)

--all-kernel::
Configure all used events to run in kernel space.

--all-user::
Configure all used events to run in user space.

--kernel-callchains::
Collect callchains only from kernel space. I.e. this option sets
perf_event_attr.exclude_callchain_user to 1.

--user-callchains::
Collect callchains only from user space. I.e. this option sets
perf_event_attr.exclude_callchain_kernel to 1.

Don't use both --kernel-callchains and --user-callchains at the same time or no
callchains will be collected.

--timestamp-filename
Append timestamp to output file name.

--timestamp-boundary::
Record timestamp boundary (time of first/last samples).

--switch-output[=mode]::
Generate multiple perf.data files, timestamp prefixed, switching to a new one
based on 'mode' value:

  - "signal" - when receiving a SIGUSR2 (default value) or
  - <size>   - when reaching the size threshold, size is expected to
               be a number with appended unit character - B/K/M/G
  - <time>   - when reaching the time threshold, size is expected to
               be a number with appended unit character - s/m/h/d

               Note: the precision of  the size  threshold  hugely depends
               on your configuration  - the number and size of  your  ring
               buffers (-m). It is generally more precise for higher sizes
               (like >5M), for lower values expect different sizes.

A possible use case is to, given an external event, slice the perf.data file
that gets then processed, possibly via a perf script, to decide if that
particular perf.data snapshot should be kept or not.

Implies --timestamp-filename, --no-buildid and --no-buildid-cache.
The reason for the latter two is to reduce the data file switching
overhead. You can still switch them on with:

  --switch-output --no-no-buildid  --no-no-buildid-cache

--switch-output-event::
Events that will cause the switch of the perf.data file, auto-selecting
--switch-output=signal, the results are similar as internally the side band
thread will also send a SIGUSR2 to the main one.

Uses the same syntax as --event, it will just not be recorded, serving only to
switch the perf.data file as soon as the --switch-output event is processed by
a separate sideband thread.

This sideband thread is also used to other purposes, like processing the
PERF_RECORD_BPF_EVENT records as they happen, asking the kernel for extra BPF
information, etc.

--switch-max-files=N::

When rotating perf.data with --switch-output, only keep N files.

--dry-run::
Parse options then exit. --dry-run can be used to detect errors in cmdline
options.

'perf record --dry-run -e' can act as a BPF script compiler if llvm.dump-obj
in config file is set to true.

--synth=TYPE::
Collect and synthesize given type of events (comma separated).  Note that
this option controls the synthesis from the /proc filesystem which represent
task status for pre-existing threads.

Kernel (and some other) events are recorded regardless of the
choice in this option.  For example, --synth=no would have MMAP events for
kernel and modules.

Available types are:

  - 'task'    - synthesize FORK and COMM events for each task
  - 'mmap'    - synthesize MMAP events for each process (implies 'task')
  - 'cgroup'  - synthesize CGROUP events for each cgroup
  - 'all'     - synthesize all events (default)
  - 'no'      - do not synthesize any of the above events

--tail-synthesize::
Instead of collecting non-sample events (for example, fork, comm, mmap) at
the beginning of record, collect them during finalizing an output file.
The collected non-sample events reflects the status of the system when
record is finished.

--overwrite::
Makes all events use an overwritable ring buffer. An overwritable ring
buffer works like a flight recorder: when it gets full, the kernel will
overwrite the oldest records, that thus will never make it to the
perf.data file.

When '--overwrite' and '--switch-output' are used perf records and drops
events until it receives a signal, meaning that something unusual was
detected that warrants taking a snapshot of the most current events,
those fitting in the ring buffer at that moment.

'overwrite' attribute can also be set or canceled for an event using
config terms. For example: 'cycles/overwrite/' and 'instructions/no-overwrite/'.

Implies --tail-synthesize.

--kcore::
Make a copy of /proc/kcore and place it into a directory with the perf data file.

--max-size=<size>::
Limit the sample data max size, <size> is expected to be a number with
appended unit character - B/K/M/G

--num-thread-synthesize::
	The number of threads to run when synthesizing events for existing processes.
	By default, the number of threads equals 1.

ifdef::HAVE_LIBPFM[]
--pfm-events events::
Select a PMU event using libpfm4 syntax (see http://perfmon2.sf.net)
including support for event filters. For example '--pfm-events
inst_retired:any_p:u:c=1:i'. More than one event can be passed to the
option using the comma separator. Hardware events and generic hardware
events cannot be mixed together. The latter must be used with the -e
option. The -e option and this one can be mixed and matched.  Events
can be grouped using the {} notation.
endif::HAVE_LIBPFM[]

--control=fifo:ctl-fifo[,ack-fifo]::
--control=fd:ctl-fd[,ack-fd]::
ctl-fifo / ack-fifo are opened and used as ctl-fd / ack-fd as follows.
Listen on ctl-fd descriptor for command to control measurement.

Available commands:

  - 'enable'           : enable events
  - 'disable'          : disable events
  - 'enable name'      : enable event 'name'
  - 'disable name'     : disable event 'name'
  - 'snapshot'         : AUX area tracing snapshot).
  - 'stop'             : stop perf record
  - 'ping'             : ping
  - 'evlist [-v|-g|-F] : display all events

                         -F  Show just the sample frequency used for each event.
                         -v  Show all fields.
                         -g  Show event group information.

Measurements can be started with events disabled using --delay=-1 option. Optionally
send control command completion ('ack\n') to ack-fd descriptor to synchronize with the
controlling process.  Example of bash shell script to enable and disable events during
measurements:

 #!/bin/bash

 ctl_dir=/tmp/

 ctl_fifo=${ctl_dir}perf_ctl.fifo
 test -p ${ctl_fifo} && unlink ${ctl_fifo}
 mkfifo ${ctl_fifo}
 exec {ctl_fd}<>${ctl_fifo}

 ctl_ack_fifo=${ctl_dir}perf_ctl_ack.fifo
 test -p ${ctl_ack_fifo} && unlink ${ctl_ack_fifo}
 mkfifo ${ctl_ack_fifo}
 exec {ctl_fd_ack}<>${ctl_ack_fifo}

 perf record -D -1 -e cpu-cycles -a               \
             --control fd:${ctl_fd},${ctl_fd_ack} \
             -- sleep 30 &
 perf_pid=$!

 sleep 5  && echo 'enable' >&${ctl_fd} && read -u ${ctl_fd_ack} e1 && echo "enabled(${e1})"
 sleep 10 && echo 'disable' >&${ctl_fd} && read -u ${ctl_fd_ack} d1 && echo "disabled(${d1})"

 exec {ctl_fd_ack}>&-
 unlink ${ctl_ack_fifo}

 exec {ctl_fd}>&-
 unlink ${ctl_fifo}

 wait -n ${perf_pid}
 exit $?

--threads=<spec>::
Write collected trace data into several data files using parallel threads.
<spec> value can be user defined list of masks. Masks separated by colon
define CPUs to be monitored by a thread and affinity mask of that thread
is separated by slash:

    <cpus mask 1>/<affinity mask 1>:<cpus mask 2>/<affinity mask 2>:...

CPUs or affinity masks must not overlap with other corresponding masks.
Invalid CPUs are ignored, but masks containing only invalid CPUs are not
allowed.

For example user specification like the following:

    0,2-4/2-4:1,5-7/5-7

specifies parallel threads layout that consists of two threads,
the first thread monitors CPUs 0 and 2-4 with the affinity mask 2-4,
the second monitors CPUs 1 and 5-7 with the affinity mask 5-7.

<spec> value can also be a string meaning predefined parallel threads
layout:

    - cpu    - create new data streaming thread for every monitored cpu
    - core   - create new thread to monitor CPUs grouped by a core
    - package - create new thread to monitor CPUs grouped by a package
    - numa   - create new threed to monitor CPUs grouped by a NUMA domain

Predefined layouts can be used on systems with large number of CPUs in
order not to spawn multiple per-cpu streaming threads but still avoid LOST
events in data directory files. Option specified with no or empty value
defaults to CPU layout. Masks defined or provided by the option value are
filtered through the mask provided by -C option.

--debuginfod[=URLs]::
	Specify debuginfod URL to be used when cacheing perf.data binaries,
	it follows the same syntax as the DEBUGINFOD_URLS variable, like:

	  http://192.168.122.174:8002

	If the URLs is not specified, the value of DEBUGINFOD_URLS
	system environment variable is used.

--off-cpu::
	Enable off-cpu profiling with BPF.  The BPF program will collect
	task scheduling information with (user) stacktrace and save them
	as sample data of a software event named "offcpu-time".  The
	sample period will have the time the task slept in nanoseconds.

	Note that BPF can collect stack traces using frame pointer ("fp")
	only, as of now.  So the applications built without the frame
	pointer might see bogus addresses.

	off-cpu profiling consists two types of samples: direct samples, which
	share the same behavior as regular samples, and the accumulated
	samples, stored in BPF stack trace map, presented after all the regular
	samples.

--off-cpu-thresh::
	Once a task's off-cpu time reaches this threshold (in milliseconds), it
	generates a direct off-cpu sample. The default is 500ms.

--setup-filter=<action>::
	Prepare BPF filter to be used by regular users.  The action should be
	either "pin" or "unpin".  The filter can be used after it's pinned.


include::intel-hybrid.txt[]

SEE ALSO
--------
linkperf:perf-stat[1], linkperf:perf-list[1], linkperf:perf-intel-pt[1]

```

## 3. perf-report.txt - Analyzing Profiles

```
perf-report(1)
==============

NAME
----
perf-report - Read perf.data (created by perf record) and display the profile

SYNOPSIS
--------
[verse]
'perf report' [-i <file> | --input=file]

DESCRIPTION
-----------
This command displays the performance counter profile information recorded
via perf record.

OPTIONS
-------
-i::
--input=::
        Input file name. (default: perf.data unless stdin is a fifo)

-v::
--verbose::
        Be more verbose. (show symbol address, etc)

-q::
--quiet::
	Do not show any warnings or messages.  (Suppress -v)

-n::
--show-nr-samples::
	Show the number of samples for each symbol

--show-cpu-utilization::
        Show sample percentage for different cpu modes.

-T::
--threads::
	Show per-thread event counters.  The input data file should be recorded
	with -s option.
-c::
--comms=::
	Only consider symbols in these comms. CSV that understands
	file://filename entries.  This option will affect the percentage of
	the overhead and latency columns.  See --percentage for more info.
--pid=::
        Only show events for given process ID (comma separated list).

--tid=::
        Only show events for given thread ID (comma separated list).
-d::
--dsos=::
	Only consider symbols in these dsos. CSV that understands
	file://filename entries.  This option will affect the percentage of
	the overhead and latency columns.  See --percentage for more info.
-S::
--symbols=::
	Only consider these symbols. CSV that understands
	file://filename entries.  This option will affect the percentage of
	the overhead and latency columns.  See --percentage for more info.

--symbol-filter=::
	Only show symbols that match (partially) with this filter.

-U::
--hide-unresolved::
        Only display entries resolved to a symbol.

--parallelism::
        Only consider these parallelism levels. Parallelism level is the number
        of threads that actively run on CPUs at the time of sample. The flag
        accepts single number, comma-separated list, and ranges (for example:
        "1", "7,8", "1,64-128"). This is useful in understanding what a program
        is doing during sequential/low-parallelism phases as compared to
        high-parallelism phases. This option will affect the percentage of
        the overhead and latency columns. See --percentage for more info.
        Also see the `CPU and latency overheads' section for more details.

--latency::
        Show latency-centric profile rather than the default
        CPU-consumption-centric profile
        (requires perf record --latency flag).

-s::
--sort=::
	Sort histogram entries by given key(s) - multiple keys can be specified
	in CSV format.  Following sort keys are available:
	pid, comm, dso, symbol, parent, cpu, socket, srcline, weight,
	local_weight, cgroup_id, addr.

	Each key has following meaning:

	- comm: command (name) of the task which can be read via /proc/<pid>/comm
	- pid: command and tid of the task
	- tgid: command and tgid of the task
	- dso: name of library or module executed at the time of sample
	- dso_size: size of library or module executed at the time of sample
	- symbol: name of function executed at the time of sample
	- symbol_size: size of function executed at the time of sample
	- parent: name of function matched to the parent regex filter. Unmatched
	entries are displayed as "[other]".
	- cpu: cpu number the task ran at the time of sample
	- socket: processor socket number the task ran at the time of sample
	- parallelism: number of running threads at the time of sample
	- srcline: filename and line number executed at the time of sample.  The
	DWARF debugging info must be provided.
	- srcfile: file name of the source file of the samples. Requires dwarf
	information.
	- weight: Event specific weight, e.g. memory latency or transaction
	abort cost. This is the global weight.
	- local_weight: Local weight version of the weight above.
	- cgroup_id: ID derived from cgroup namespace device and inode numbers.
	- cgroup: cgroup pathname in the cgroupfs.
	- transaction: Transaction abort flags.
	- overhead: CPU overhead percentage of sample.
	- latency: latency (wall-clock) overhead percentage of sample.
	  See the `CPU and latency overheads' section for more details.
	- overhead_sys: CPU overhead percentage of sample running in system mode
	- overhead_us: CPU overhead percentage of sample running in user mode
	- overhead_guest_sys: CPU overhead percentage of sample running in system mode
	on guest machine
	- overhead_guest_us: CPU overhead percentage of sample running in user mode on
	guest machine
	- sample: Number of sample
	- period: Raw number of event count of sample
	- time: Separate the samples by time stamp with the resolution specified by
	--time-quantum (default 100ms). Specify with overhead and before it.
	- code_page_size: the code page size of sampled code address (ip)
	- ins_lat: Instruction latency in core cycles. This is the global instruction
	  latency
	- local_ins_lat: Local instruction latency version
	- p_stage_cyc: On powerpc, this presents the number of cycles spent in a
	  pipeline stage. And currently supported only on powerpc.
	- addr: (Full) virtual address of the sampled instruction
	- retire_lat: On X86, this reports pipeline stall of this instruction compared
	  to the previous instruction in cycles. And currently supported only on X86
	- simd: Flags describing a SIMD operation. "e" for empty Arm SVE predicate. "p" for partial Arm SVE predicate
	- type: Data type of sample memory access.
	- typeoff: Offset in the data type of sample memory access.
	- symoff: Offset in the symbol.
	- weight1: Average value of event specific weight (1st field of weight_struct).
	- weight2: Average value of event specific weight (2nd field of weight_struct).
	- weight3: Average value of event specific weight (3rd field of weight_struct).

	By default, overhead, comm, dso and symbol keys are used.
	(i.e. --sort overhead,comm,dso,symbol).

	If --branch-stack option is used, following sort keys are also
	available:

	- dso_from: name of library or module branched from
	- dso_to: name of library or module branched to
	- symbol_from: name of function branched from
	- symbol_to: name of function branched to
	- srcline_from: source file and line branched from
	- srcline_to: source file and line branched to
	- mispredict: "N" for predicted branch, "Y" for mispredicted branch
	- in_tx: branch in TSX transaction
	- abort: TSX transaction abort.
	- cycles: Cycles in basic block

	And default sort keys are changed to comm, dso_from, symbol_from, dso_to
	and symbol_to, see '--branch-stack'.

	When the sort key symbol is specified, columns "IPC" and "IPC Coverage"
	are enabled automatically. Column "IPC" reports the average IPC per function
	and column "IPC coverage" reports the percentage of instructions with
	sampled IPC in this function. IPC means Instruction Per Cycle. If it's low,
	it indicates there may be a performance bottleneck when the function is
	executed, such as a memory access bottleneck. If a function has high overhead
	and low IPC, it's worth further analyzing it to optimize its performance.

	If the --mem-mode option is used, the following sort keys are also available
	(incompatible with --branch-stack):
	symbol_daddr, dso_daddr, locked, tlb, mem, snoop, dcacheline, blocked.

	- symbol_daddr: name of data symbol being executed on at the time of sample
	- dso_daddr: name of library or module containing the data being executed
	on at the time of the sample
	- locked: whether the bus was locked at the time of the sample
	- tlb: type of tlb access for the data at the time of the sample
	- mem: type of memory access for the data at the time of the sample
	- snoop: type of snoop (if any) for the data at the time of the sample
	- dcacheline: the cacheline the data address is on at the time of the sample
	- phys_daddr: physical address of data being executed on at the time of sample
	- data_page_size: the data page size of data being executed on at the time of sample
	- blocked: reason of blocked load access for the data at the time of the sample

	And the default sort keys are changed to local_weight, mem, sym, dso,
	symbol_daddr, dso_daddr, snoop, tlb, locked, blocked, local_ins_lat,
	see '--mem-mode'.

	If the data file has tracepoint event(s), following (dynamic) sort keys
	are also available:
	trace, trace_fields, [<event>.]<field>[/raw]

	- trace: pretty printed trace output in a single column
	- trace_fields: fields in tracepoints in separate columns
	- <field name>: optional event and field name for a specific field

	The last form consists of event and field names.  If event name is
	omitted, it searches all events for matching field name.  The matched
	field will be shown only for the event has the field.  The event name
	supports substring match so user doesn't need to specify full subsystem
	and event name everytime.  For example, 'sched:sched_switch' event can
	be shortened to 'switch' as long as it's not ambiguous.  Also event can
	be specified by its index (starting from 1) preceded by the '%'.
	So '%1' is the first event, '%2' is the second, and so on.

	The field name can have '/raw' suffix which disables pretty printing
	and shows raw field value like hex numbers.  The --raw-trace option
	has the same effect for all dynamic sort keys.

	The default sort keys are changed to 'trace' if all events in the data
	file are tracepoint.

-F::
--fields=::
	Specify output field - multiple keys can be specified in CSV format.
	Following fields are available:
	overhead, latency, overhead_sys, overhead_us, overhead_children, sample,
	period, weight1, weight2, weight3, ins_lat, p_stage_cyc and retire_lat.
	The last 3 names are alias for the corresponding weights.  When the weight
	fields are used, they will show the average value of the weight.

	Also it can contain any sort key(s).

	By default, every sort keys not specified in -F will be appended
	automatically.

	If the keys starts with a prefix '+', then it will append the specified
        field(s) to the default field order. For example: perf report -F +period,sample.

-p::
--parent=<regex>::
        A regex filter to identify parent. The parent is a caller of this
	function and searched through the callchain, thus it requires callchain
	information recorded. The pattern is in the extended regex format and
	defaults to "\^sys_|^do_page_fault", see '--sort parent'.

-x::
--exclude-other::
        Only display entries with parent-match.

-w::
--column-widths=<width[,width...]>::
	Force each column width to the provided list, for large terminal
	readability.  0 means no limit (default behavior).

-t::
--field-separator=::
	Use a special separator character and don't pad with spaces, replacing
	all occurrences of this separator in symbol names (and other output)
	with a '.' character, that thus it's the only non valid separator.

-D::
--dump-raw-trace::
        Dump raw trace in ASCII.

--disable-order::
	Disable raw trace ordering.

-g::
--call-graph=<print_type,threshold[,print_limit],order,sort_key[,branch],value>::
        Display call chains using type, min percent threshold, print limit,
	call order, sort key, optional branch and value.  Note that ordering
	is not fixed so any parameter can be given in an arbitrary order.
	One exception is the print_limit which should be preceded by threshold.

	print_type can be either:
	- flat: single column, linear exposure of call chains.
	- graph: use a graph tree, displaying absolute overhead rates. (default)
	- fractal: like graph, but displays relative rates. Each branch of
		 the tree is considered as a new profiled object.
	- folded: call chains are displayed in a line, separated by semicolons
	- none: disable call chain display.

	threshold is a percentage value which specifies a minimum percent to be
	included in the output call graph.  Default is 0.5 (%).

	print_limit is only applied when stdio interface is used.  It's to limit
	number of call graph entries in a single hist entry.  Note that it needs
	to be given after threshold (but not necessarily consecutive).
	Default is 0 (unlimited).

	order can be either:
	- callee: callee based call graph.
	- caller: inverted caller based call graph.
	Default is 'caller' when --children is used, otherwise 'callee'.

	sort_key can be:
	- function: compare on functions (default)
	- address: compare on individual code addresses
	- srcline: compare on source filename and line number

	branch can be:
	- branch: include last branch information in callgraph when available.
	          Usually more convenient to use --branch-history for this.

	value can be:
	- percent: display overhead percent (default)
	- period: display event period
	- count: display event count

--children::
	Accumulate callchain of children to parent entry so that then can
	show up in the output.  The output will have a new "Children" column
	and will be sorted on the data.  It requires callchains are recorded.
	See the `Overhead calculation' section for more details. Enabled by
	default, disable with --no-children.

--max-stack::
	Set the stack depth limit when parsing the callchain, anything
	beyond the specified depth will be ignored. This is a trade-off
	between information loss and faster processing especially for
	workloads that can have a very long callchain stack.
	Note that when using the --itrace option the synthesized callchain size
	will override this value if the synthesized callchain size is bigger.

	Default: 127

-G::
--inverted::
        alias for inverted caller based call graph.

--ignore-callees=<regex>::
        Ignore callees of the function(s) matching the given regex.
        This has the effect of collecting the callers of each such
        function into one place in the call-graph tree.

--pretty=<key>::
        Pretty printing style.  key: normal, raw

--stdio:: Use the stdio interface.

--stdio-color::
	'always', 'never' or 'auto', allowing configuring color output
	via the command line, in addition to via "color.ui" .perfconfig.
	Use '--stdio-color always' to generate color even when redirecting
	to a pipe or file. Using just '--stdio-color' is equivalent to
	using 'always'.

--tui:: Use the TUI interface, that is integrated with annotate and allows
        zooming into DSOs or threads, among other features. Use of --tui
	requires a tty, if one is not present, as when piping to other
	commands, the stdio interface is used.

--gtk:: Use the GTK2 interface.

-k::
--vmlinux=<file>::
        vmlinux pathname

--ignore-vmlinux::
	Ignore vmlinux files.

--kallsyms=<file>::
        kallsyms pathname

-m::
--modules::
        Load module symbols. WARNING: This should only be used with -k and
        a LIVE kernel.

-f::
--force::
        Don't do ownership validation.

--symfs=<directory>::
        Look for files with symbols relative to this directory.

-C::
--cpu:: Only report samples for the list of CPUs provided. Multiple CPUs can
	be provided as a comma-separated list with no space: 0,1. Ranges of
	CPUs are specified with -: 0-2. Default is to report samples on all
	CPUs.

-M::
--disassembler-style=:: Set disassembler style for objdump.

--source::
	Interleave source code with assembly code. Enabled by default,
	disable with --no-source.

--asm-raw::
	Show raw instruction encoding of assembly instructions.

--show-total-period:: Show a column with the sum of periods.

-I::
--show-info::
	Display extended information about the perf.data file. This adds
	information which may be very large and thus may clutter the display.
	It currently includes: cpu and numa topology of the host system.

-b::
--branch-stack::
	Use the addresses of sampled taken branches instead of the instruction
	address to build the histograms. To generate meaningful output, the
	perf.data file must have been obtained using perf record -b or
	perf record --branch-filter xxx where xxx is a branch filter option.
	perf report is able to auto-detect whether a perf.data file contains
	branch stacks and it will automatically switch to the branch view mode,
	unless --no-branch-stack is used.

--branch-history::
	Add the addresses of sampled taken branches to the callstack.
	This allows to examine the path the program took to each sample.
	The data collection must have used -b (or -j) and -g.

	Also show with some branch flags that can be:
	- Predicted: display the average percentage of predicated branches.
		     (predicated number / total number)
	- Abort: display the number of tsx aborted branches.
	- Cycles: cycles in basic block.

	- iterations: display the average number of iterations in callchain list.

--addr2line=<path>::
        Path to addr2line binary.

--objdump=<path>::
        Path to objdump binary.

--prefix=PREFIX::
--prefix-strip=N::
	Remove first N entries from source file path names in executables
	and add PREFIX. This allows to display source code compiled on systems
	with different file system layout.

--group::
	Show event group information together. It forces group output also
	if there are no groups defined in data file.

--group-sort-idx::
	Sort the output by the event at the index n in group. If n is invalid,
	sort by the first event. It can support multiple groups with different
	amount of events. WARNING: This should be used on grouped events.

--demangle::
	Demangle symbol names to human readable form. It's enabled by default,
	disable with --no-demangle.

--demangle-kernel::
	Demangle kernel symbol names to human readable form (for C++ kernels).

--mem-mode::
	Use the data addresses of samples in addition to instruction addresses
	to build the histograms.  To generate meaningful output, the perf.data
	file must have been obtained using perf record -d -W and using a
	special event -e cpu/mem-loads/p or -e cpu/mem-stores/p. See
	'perf mem' for simpler access.

--percent-limit::
	Do not show entries which have an overhead under that percent.
	(Default: 0).  Note that this option also sets the percent limit (threshold)
	of callchains.  However the default value of callchain threshold is
	different than the default value of hist entries.  Please see the
	--call-graph option for details.

--percentage::
	Determine how to display the CPU and latency overhead percentage
	of filtered entries. Filters can be applied by --comms, --dsos, --symbols
	and/or --parallelism options and Zoom operations on the TUI (thread, dso, etc).

	"relative" means it's relative to filtered entries only so that the
	sum of shown entries will be always 100%.  "absolute" means it retains
	the original value before and after the filter is applied.

--header::
	Show header information in the perf.data file.  This includes
	various information like hostname, OS and perf version, cpu/mem
	info, perf command line, event list and so on.  Currently only
	--stdio output supports this feature.

--header-only::
	Show only perf.data header (forces --stdio).

--time::
	Only analyze samples within given time window: <start>,<stop>. Times
	have the format seconds.nanoseconds. If start is not given (i.e. time
	string is ',x.y') then analysis starts at the beginning of the file. If
	stop time is not given (i.e. time string is 'x.y,') then analysis goes
	to end of file. Multiple ranges can be separated by spaces, which
	requires the argument to be quoted e.g. --time "1234.567,1234.789 1235,"

	Also support time percent with multiple time ranges. Time string is
	'a%/n,b%/m,...' or 'a%-b%,c%-%d,...'.

	For example:
	Select the second 10% time slice:

	  perf report --time 10%/2

	Select from 0% to 10% time slice:

	  perf report --time 0%-10%

	Select the first and second 10% time slices:

	  perf report --time 10%/1,10%/2

	Select from 0% to 10% and 30% to 40% slices:

	  perf report --time 0%-10%,30%-40%

--switch-on EVENT_NAME::
	Only consider events after this event is found.

	This may be interesting to measure a workload only after some initialization
	phase is over, i.e. insert a perf probe at that point and then using this
	option with that probe.

--switch-off EVENT_NAME::
	Stop considering events after this event is found.

--show-on-off-events::
	Show the --switch-on/off events too. This has no effect in 'perf report' now
	but probably we'll make the default not to show the switch-on/off events
        on the --group mode and if there is only one event besides the off/on ones,
	go straight to the histogram browser, just like 'perf report' with no events
	explicitly specified does.

--itrace::
	Options for decoding instruction tracing data. The options are:

include::itrace.txt[]

	To disable decoding entirely, use --no-itrace.

--full-source-path::
	Show the full path for source files for srcline output.

--show-ref-call-graph::
	When multiple events are sampled, it may not be needed to collect
	callgraphs for all of them. The sample sites are usually nearby,
	and it's enough to collect the callgraphs on a reference event.
	So user can use "call-graph=no" event modifier to disable callgraph
	for other events to reduce the overhead.
	However, perf report cannot show callgraphs for the event which
	disable the callgraph.
	This option extends the perf report to show reference callgraphs,
	which collected by reference event, in no callgraph event.

--stitch-lbr::
	Show callgraph with stitched LBRs, which may have more complete
	callgraph. The perf.data file must have been obtained using
	perf record --call-graph lbr.
	Disabled by default. In common cases with call stack overflows,
	it can recreate better call stacks than the default lbr call stack
	output. But this approach is not foolproof. There can be cases
	where it creates incorrect call stacks from incorrect matches.
	The known limitations include exception handing such as
	setjmp/longjmp will have calls/returns not match.

--socket-filter::
	Only report the samples on the processor socket that match with this filter

--samples=N::
	Save N individual samples for each histogram entry to show context in perf
	report tui browser.

--raw-trace::
	When displaying traceevent output, do not use print fmt or plugins.

-H::
--hierarchy::
	Enable hierarchical output.  In the hierarchy mode, each sort key groups
	samples based on the criteria and then sub-divide it using the lower
	level sort key.

	For example:
	In normal output:

	  perf report -s dso,sym
	  # Overhead  Shared Object      Symbol
	      50.00%  [kernel.kallsyms]  [k] kfunc1
	      20.00%  perf               [.] foo
	      15.00%  [kernel.kallsyms]  [k] kfunc2
	      10.00%  perf               [.] bar
	       5.00%  libc.so            [.] libcall

	In hierarchy output:

	  perf report -s dso,sym --hierarchy
	  #   Overhead  Shared Object / Symbol
	      65.00%    [kernel.kallsyms]
	        50.00%    [k] kfunc1
	        15.00%    [k] kfunc2
	      30.00%    perf
	        20.00%    [.] foo
	        10.00%    [.] bar
	       5.00%    libc.so
	         5.00%    [.] libcall

--inline::
	If a callgraph address belongs to an inlined function, the inline stack
	will be printed. Each entry is function name or file/line. Enabled by
	default, disable with --no-inline.

--mmaps::
	Show --tasks output plus mmap information in a format similar to
	/proc/<PID>/maps.

	Please note that not all mmaps are stored, options affecting which ones
	are include 'perf record --data', for instance.

--ns::
	Show time stamps in nanoseconds.

--stats::
	Display overall events statistics without any further processing.
	(like the one at the end of the perf report -D command)

--tasks::
	Display monitored tasks stored in perf data. Displaying pid/tid/ppid
	plus the command string aligned to distinguish parent and child tasks.

--percent-type::
	Set annotation percent type from following choices:
	  global-period, local-period, global-hits, local-hits

	The local/global keywords set if the percentage is computed
	in the scope of the function (local) or the whole data (global).
	The period/hits keywords set the base the percentage is computed
	on - the samples period or the number of samples (hits).

--time-quantum::
	Configure time quantum for time sort key. Default 100ms.
	Accepts s, us, ms, ns units.

--total-cycles::
	When --total-cycles is specified, it supports sorting for all blocks by
	'Sampled Cycles%'. This is useful to concentrate on the globally hottest
	blocks. In output, there are some new columns:

	'Sampled Cycles%' - block sampled cycles aggregation / total sampled cycles
	'Sampled Cycles'  - block sampled cycles aggregation
	'Avg Cycles%'     - block average sampled cycles / sum of total block average
			    sampled cycles
	'Avg Cycles'      - block average sampled cycles
	'Branch Counter'  - block branch counter histogram (with -v showing the number)

--skip-empty::
	Do not print 0 results in the --stat output.

include::cpu-and-latency-overheads.txt[]

include::callchain-overhead-calculation.txt[]

SEE ALSO
--------
linkperf:perf-stat[1], linkperf:perf-annotate[1], linkperf:perf-record[1],
linkperf:perf-intel-pt[1]

```

## 4. perf-stat.txt - Counting Events

```
perf-stat(1)
============

NAME
----
perf-stat - Run a command and gather performance counter statistics

SYNOPSIS
--------
[verse]
'perf stat' [-e <EVENT> | --event=EVENT] [-a] <command>
'perf stat' [-e <EVENT> | --event=EVENT] [-a] \-- <command> [<options>]
'perf stat' [-e <EVENT> | --event=EVENT] [-a] record [-o file] \-- <command> [<options>]
'perf stat' report [-i file]

DESCRIPTION
-----------
This command runs a command and gathers performance counter statistics
from it.


OPTIONS
-------
<command>...::
	Any command you can specify in a shell.

record::
	See STAT RECORD.

report::
	See STAT REPORT.

-e::
--event=::
	Select the PMU event. Selection can be:

	- a symbolic event name (use 'perf list' to list all events)

	- a raw PMU event in the form of rN where N is a hexadecimal value
	  that represents the raw register encoding with the layout of the
	  event control registers as described by entries in
	  /sys/bus/event_source/devices/cpu/format/*.

        - a symbolic or raw PMU event followed by an optional colon
	  and a list of event modifiers, e.g., cpu-cycles:p.  See the
	  linkperf:perf-list[1] man page for details on event modifiers.

	- a symbolically formed event like 'pmu/param1=0x3,param2/' where
	  param1 and param2 are defined as formats for the PMU in
	  /sys/bus/event_source/devices/<pmu>/format/*

	  'percore' is a event qualifier that sums up the event counts for both
	  hardware threads in a core. For example:
	  perf stat -A -a -e cpu/event,percore=1/,otherevent ...

	- a symbolically formed event like 'pmu/config=M,config1=N,config2=K/'
	  where M, N, K are numbers (in decimal, hex, octal format).
	  Acceptable values for each of 'config', 'config1' and 'config2'
	  parameters are defined by corresponding entries in
	  /sys/bus/event_source/devices/<pmu>/format/*

	Note that the last two syntaxes support prefix and glob matching in
	the PMU name to simplify creation of events across multiple instances
	of the same type of PMU in large systems (e.g. memory controller PMUs).
	Multiple PMU instances are typical for uncore PMUs, so the prefix
	'uncore_' is also ignored when performing this match.


-i::
--no-inherit::
        child tasks do not inherit counters
-p::
--pid=<pid>::
        stat events on existing process id (comma separated list)

-t::
--tid=<tid>::
        stat events on existing thread id (comma separated list)

-b::
--bpf-prog::
        stat events on existing bpf program id (comma separated list),
        requiring root rights. bpftool-prog could be used to find program
        id all bpf programs in the system. For example:

  # bpftool prog | head -n 1
  17247: tracepoint  name sys_enter  tag 192d548b9d754067  gpl

  # perf stat -e cycles,instructions --bpf-prog 17247 --timeout 1000

   Performance counter stats for 'BPF program(s) 17247':

             85,967      cycles
             28,982      instructions              #    0.34  insn per cycle

        1.102235068 seconds time elapsed

--bpf-counters::
	Use BPF programs to aggregate readings from perf_events.  This
	allows multiple perf-stat sessions that are counting the same metric (cycles,
	instructions, etc.) to share hardware counters.
	To use BPF programs on common events by default, use
	"perf config stat.bpf-counter-events=<list_of_events>".

--bpf-attr-map::
	With option "--bpf-counters", different perf-stat sessions share
	information about shared BPF programs and maps via a pinned hashmap.
	Use "--bpf-attr-map" to specify the path of this pinned hashmap.
	The default path is /sys/fs/bpf/perf_attr_map.

ifdef::HAVE_LIBPFM[]
--pfm-events events::
Select a PMU event using libpfm4 syntax (see http://perfmon2.sf.net)
including support for event filters. For example '--pfm-events
inst_retired:any_p:u:c=1:i'. More than one event can be passed to the
option using the comma separator. Hardware events and generic hardware
events cannot be mixed together. The latter must be used with the -e
option. The -e option and this one can be mixed and matched.  Events
can be grouped using the {} notation.
endif::HAVE_LIBPFM[]

-a::
--all-cpus::
        system-wide collection from all CPUs (default if no target is specified)

--no-scale::
	Don't scale/normalize counter values

-d::
--detailed::
	print more detailed statistics, can be specified up to 3 times

	   -d:          detailed events, L1 and LLC data cache
        -d -d:     more detailed events, dTLB and iTLB events
     -d -d -d:     very detailed events, adding prefetch events

-r::
--repeat=<n>::
	repeat command and print average + stddev (max: 100). 0 means forever.

-B::
--big-num::
        print large numbers with thousands' separators according to locale.
	Enabled by default. Use "--no-big-num" to disable.
	Default setting can be changed with "perf config stat.big-num=false".

-C::
--cpu=::
Count only on the list of CPUs provided. Multiple CPUs can be provided as a
comma-separated list with no space: 0,1. Ranges of CPUs are specified with -: 0-2.
In per-thread mode, this option is ignored. The -a option is still necessary
to activate system-wide monitoring. Default is to count on all CPUs.

-A::
--no-aggr::
Do not aggregate counts across all monitored CPUs.

-n::
--null::
null run - Don't start any counters.

This can be useful to measure just elapsed wall-clock time - or to assess the
raw overhead of perf stat itself, without running any counters.

-v::
--verbose::
        be more verbose (show counter open errors, etc)

-x SEP::
--field-separator SEP::
print counts using a CSV-style output to make it easy to import directly into
spreadsheets. Columns are separated by the string specified in SEP.

--table:: Display time for each run (-r option), in a table format, e.g.:

  $ perf stat --null -r 5 --table perf bench sched pipe

   Performance counter stats for 'perf bench sched pipe' (5 runs):

             # Table of individual measurements:
             5.189 (-0.293) #
             5.189 (-0.294) #
             5.186 (-0.296) #
             5.663 (+0.181) ##
             6.186 (+0.703) ####

             # Final result:
             5.483 +- 0.198 seconds time elapsed  ( +-  3.62% )

-G name::
--cgroup name::
monitor only in the container (cgroup) called "name". This option is available only
in per-cpu mode. The cgroup filesystem must be mounted. All threads belonging to
container "name" are monitored when they run on the monitored CPUs. Multiple cgroups
can be provided. Each cgroup is applied to the corresponding event, i.e., first cgroup
to first event, second cgroup to second event and so on. It is possible to provide
an empty cgroup (monitor all the time) using, e.g., -G foo,,bar. Cgroups must have
corresponding events, i.e., they always refer to events defined earlier on the command
line. If the user wants to track multiple events for a specific cgroup, the user can
use '-e e1 -e e2 -G foo,foo' or just use '-e e1 -e e2 -G foo'.

If wanting to monitor, say, 'cycles' for a cgroup and also for system wide, this
command line can be used: 'perf stat -e cycles -G cgroup_name -a -e cycles'.

--for-each-cgroup name::
Expand event list for each cgroup in "name" (allow multiple cgroups separated
by comma).  It also support regex patterns to match multiple groups.  This has same
effect that repeating -e option and -G option for each event x name.  This option
cannot be used with -G/--cgroup option.

-o file::
--output file::
Print the output into the designated file.

--append::
Append to the output file designated with the -o option. Ignored if -o is not specified.

--log-fd::

Log output to fd, instead of stderr.  Complementary to --output, and mutually exclusive
with it.  --append may be used here.  Examples:
     3>results  perf stat --log-fd 3          \-- $cmd
     3>>results perf stat --log-fd 3 --append \-- $cmd

--control=fifo:ctl-fifo[,ack-fifo]::
--control=fd:ctl-fd[,ack-fd]::
ctl-fifo / ack-fifo are opened and used as ctl-fd / ack-fd as follows.
Listen on ctl-fd descriptor for command to control measurement ('enable': enable events,
'disable': disable events). Measurements can be started with events disabled using
--delay=-1 option. Optionally send control command completion ('ack\n') to ack-fd descriptor
to synchronize with the controlling process. Example of bash shell script to enable and
disable events during measurements:

 #!/bin/bash

 ctl_dir=/tmp/

 ctl_fifo=${ctl_dir}perf_ctl.fifo
 test -p ${ctl_fifo} && unlink ${ctl_fifo}
 mkfifo ${ctl_fifo}
 exec {ctl_fd}<>${ctl_fifo}

 ctl_ack_fifo=${ctl_dir}perf_ctl_ack.fifo
 test -p ${ctl_ack_fifo} && unlink ${ctl_ack_fifo}
 mkfifo ${ctl_ack_fifo}
 exec {ctl_fd_ack}<>${ctl_ack_fifo}

 perf stat -D -1 -e cpu-cycles -a -I 1000       \
           --control fd:${ctl_fd},${ctl_fd_ack} \
           \-- sleep 30 &
 perf_pid=$!

 sleep 5  && echo 'enable' >&${ctl_fd} && read -u ${ctl_fd_ack} e1 && echo "enabled(${e1})"
 sleep 10 && echo 'disable' >&${ctl_fd} && read -u ${ctl_fd_ack} d1 && echo "disabled(${d1})"

 exec {ctl_fd_ack}>&-
 unlink ${ctl_ack_fifo}

 exec {ctl_fd}>&-
 unlink ${ctl_fifo}

 wait -n ${perf_pid}
 exit $?


--pre::
--post::
	Pre and post measurement hooks, e.g.:

perf stat --repeat 10 --null --sync --pre 'make -s O=defconfig-build/clean' \-- make -s -j64 O=defconfig-build/ bzImage

-I msecs::
--interval-print msecs::
Print count deltas every N milliseconds (minimum: 1ms)
The overhead percentage could be high in some cases, for instance with small, sub 100ms intervals.  Use with caution.
	example: 'perf stat -I 1000 -e cycles -a sleep 5'

If the metric exists, it is calculated by the counts generated in this interval and the metric is printed after #.

--interval-count times::
Print count deltas for fixed number of times.
This option should be used together with "-I" option.
	example: 'perf stat -I 1000 --interval-count 2 -e cycles -a'

--interval-clear::
Clear the screen before next interval.

--timeout msecs::
Stop the 'perf stat' session and print count deltas after N milliseconds (minimum: 10 ms).
This option is not supported with the "-I" option.
	example: 'perf stat --time 2000 -e cycles -a'

--metric-only::
Only print computed metrics. Print them in a single line.
Don't show any raw values. Not supported with --per-thread.

--per-socket::
Aggregate counts per processor socket for system-wide mode measurements.  This
is a useful mode to detect imbalance between sockets.  To enable this mode,
use --per-socket in addition to -a. (system-wide).  The output includes the
socket number and the number of online processors on that socket. This is
useful to gauge the amount of aggregation.

--per-die::
Aggregate counts per processor die for system-wide mode measurements.  This
is a useful mode to detect imbalance between dies.  To enable this mode,
use --per-die in addition to -a. (system-wide).  The output includes the
die number and the number of online processors on that die. This is
useful to gauge the amount of aggregation.

--per-cluster::
Aggregate counts per processor cluster for system-wide mode measurement.  This
is a useful mode to detect imbalance between clusters.  To enable this mode,
use --per-cluster in addition to -a. (system-wide).  The output includes the
cluster number and the number of online processors on that cluster. This is
useful to gauge the amount of aggregation. The information of cluster ID and
related CPUs can be gotten from /sys/devices/system/cpu/cpuX/topology/cluster_{id, cpus}.

--per-cache::
Aggregate counts per cache instance for system-wide mode measurements.  By
default, the aggregation happens for the cache level at the highest index
in the system. To specify a particular level, mention the cache level
alongside the option in the format [Ll][1-9][0-9]*. For example:
Using option "--per-cache=l3" or "--per-cache=L3" will aggregate the
information at the boundary of the level 3 cache in the system.

--per-core::
Aggregate counts per physical processor for system-wide mode measurements.  This
is a useful mode to detect imbalance between physical cores.  To enable this mode,
use --per-core in addition to -a. (system-wide).  The output includes the
core number and the number of online logical processors on that physical processor.

--per-thread::
Aggregate counts per monitored threads, when monitoring threads (-t option)
or processes (-p option).

--per-node::
Aggregate counts per NUMA nodes for system-wide mode measurements. This
is a useful mode to detect imbalance between NUMA nodes. To enable this
mode, use --per-node in addition to -a. (system-wide).

-D msecs::
--delay msecs::
After starting the program, wait msecs before measuring (-1: start with events
disabled). This is useful to filter out the startup phase of the program,
which is often very different.

-T::
--transaction::

Print statistics of transactional execution if supported.

--metric-no-group::
By default, events to compute a metric are placed in weak groups. The
group tries to enforce scheduling all or none of the events. The
--metric-no-group option places events outside of groups and may
increase the chance of the event being scheduled - leading to more
accuracy. However, as events may not be scheduled together accuracy
for metrics like instructions per cycle can be lower - as both metrics
may no longer be being measured at the same time.

--metric-no-merge::
By default metric events in different weak groups can be shared if one
group contains all the events needed by another. In such cases one
group will be eliminated reducing event multiplexing and making it so
that certain groups of metrics sum to 100%. A downside to sharing a
group is that the group may require multiplexing and so accuracy for a
small group that need not have multiplexing is lowered. This option
forbids the event merging logic from sharing events between groups and
may be used to increase accuracy in this case.

--metric-no-threshold::
Metric thresholds may increase the number of events necessary to
compute whether a metric has exceeded its threshold expression. This
may not be desirable, for example, as the events can introduce
multiplexing. This option disables the adding of threshold expression
events for a metric. However, if there are sufficient events to
compute the threshold then the threshold is still computed and used to
color the metric's computed value.

--quiet::
Don't print output, warnings or messages. This is useful with perf stat
record below to only write data to the perf.data file.

STAT RECORD
-----------
Stores stat data into perf data file.

-o file::
--output file::
Output file name.

STAT REPORT
-----------
Reads and reports stat data from perf data file.

-i file::
--input file::
Input file name.

--per-socket::
Aggregate counts per processor socket for system-wide mode measurements.

--per-die::
Aggregate counts per processor die for system-wide mode measurements.

--per-cluster::
Aggregate counts perf processor cluster for system-wide mode measurements.

--per-cache::
Aggregate counts per cache instance for system-wide mode measurements.  By
default, the aggregation happens for the cache level at the highest index
in the system. To specify a particular level, mention the cache level
alongside the option in the format [Ll][1-9][0-9]*. For example: Using
option "--per-cache=l3" or "--per-cache=L3" will aggregate the
information at the boundary of the level 3 cache in the system.

--per-core::
Aggregate counts per physical processor for system-wide mode measurements.

-M::
--metrics::
Print metrics or metricgroups specified in a comma separated list.
For a group all metrics from the group are added.
The events from the metrics are automatically measured.
See perf list output for the possible metrics and metricgroups.

	When threshold information is available for a metric, the
	color red is used to signify a metric has exceeded a threshold
	while green shows it hasn't. The default color means that
	no threshold information was available or the threshold
	couldn't be computed.

-A::
--no-aggr::
--no-merge::
Do not aggregate/merge counts across monitored CPUs or PMUs.

When multiple events are created from a single event specification,
stat will, by default, aggregate the event counts and show the result
in a single row. This option disables that behavior and shows the
individual events and counts.

Multiple events are created from a single event specification when:

1. PID monitoring isn't requested and the system has more than one
   CPU. For example, a system with 8 SMT threads will have one event
   opened on each thread and aggregation is performed across them.

2. Prefix or glob wildcard matching is used for the PMU name. For
   example, multiple memory controller PMUs may exist typically with a
   suffix of _0, _1, etc. By default the event counts will all be
   combined if the PMU is specified without the suffix such as
   uncore_imc rather than uncore_imc_0.

3. Aliases, which are listed immediately after the Kernel PMU events
   by perf list, are used.

--hybrid-merge::
Merge core event counts from all core PMUs. In hybrid or big.LITTLE
systems by default each core PMU will report its count
separately. This option forces core PMU counts to be combined to give
a behavior closer to having a single CPU type in the system.

--topdown::
Print top-down metrics supported by the CPU. This allows to determine
bottle necks in the CPU pipeline for CPU bound workloads, by breaking
the cycles consumed down into frontend bound, backend bound, bad
speculation and retiring.

Frontend bound means that the CPU cannot fetch and decode instructions fast
enough. Backend bound means that computation or memory access is the bottle
neck. Bad Speculation means that the CPU wasted cycles due to branch
mispredictions and similar issues. Retiring means that the CPU computed without
an apparently bottleneck. The bottleneck is only the real bottleneck
if the workload is actually bound by the CPU and not by something else.

For best results it is usually a good idea to use it with interval
mode like -I 1000, as the bottleneck of workloads can change often.

This enables --metric-only, unless overridden with --no-metric-only.

The following restrictions only apply to older Intel CPUs and Atom,
on newer CPUs (IceLake and later) TopDown can be collected for any thread:

The top down metrics are collected per core instead of per
CPU thread. Per core mode is automatically enabled
and -a (global monitoring) is needed, requiring root rights or
perf.perf_event_paranoid=-1.

Topdown uses the full Performance Monitoring Unit, and needs
disabling of the NMI watchdog (as root):
echo 0 > /proc/sys/kernel/nmi_watchdog
for best results. Otherwise the bottlenecks may be inconsistent
on workload with changing phases.

To interpret the results it is usually needed to know on which
CPUs the workload runs on. If needed the CPUs can be forced using
taskset.

--record-tpebs::
Enable automatic sampling on Intel TPEBS retire_latency events (event with :R
modifier). Without this option, perf would not capture dynamic retire_latency
at runtime. Currently, a zero value is assigned to the retire_latency event when
this option is not set. The TPEBS hardware feature starts from Intel Granite
Rapids microarchitecture. This option only exists in X86_64 and is meaningful on
Intel platforms with TPEBS feature.

--tpebs-mode=[mean|min|max|last]::
Set how retirement latency events have their sample times
combined. The default "mean" gives the average of retirement
latency. "min" or "max" give the smallest or largest retirment latency
times respectively. "last" uses the last retirment latency sample's
time.

--td-level::
Print the top-down statistics that equal the input level. It allows
users to print the interested top-down metrics level instead of the
level 1 top-down metrics.

As the higher levels gather more metrics and use more counters they
will be less accurate. By convention a metric can be examined by
appending '_group' to it and this will increase accuracy compared to
gathering all metrics for a level. For example, level 1 analysis may
highlight 'tma_frontend_bound'. This metric may be drilled into with
'tma_frontend_bound_group' with
'perf stat -M tma_frontend_bound_group...'.

Error out if the input is higher than the supported max level.

--smi-cost::
Measure SMI cost if msr/aperf/ and msr/smi/ events are supported.

During the measurement, the /sys/device/cpu/freeze_on_smi will be set to
freeze core counters on SMI.
The aperf counter will not be effected by the setting.
The cost of SMI can be measured by (aperf - unhalted core cycles).

In practice, the percentages of SMI cycles is very useful for performance
oriented analysis. --metric_only will be applied by default.
The output is SMI cycles%, equals to (aperf - unhalted core cycles) / aperf

Users who wants to get the actual value can apply --no-metric-only.

--all-kernel::
Configure all used events to run in kernel space.

--all-user::
Configure all used events to run in user space.

--percore-show-thread::
The event modifier "percore" has supported to sum up the event counts
for all hardware threads in a core and show the counts per core.

This option with event modifier "percore" enabled also sums up the event
counts for all hardware threads in a core but show the sum counts per
hardware thread. This is essentially a replacement for the any bit and
convenient for post processing.

--summary::
Print summary for interval mode (-I).

--no-csv-summary::
Don't print 'summary' at the first column for CVS summary output.
This option must be used with -x and --summary.

This option can be enabled in perf config by setting the variable
'stat.no-csv-summary'.

$ perf config stat.no-csv-summary=true

--cputype::
Only enable events on applying cpu with this type for hybrid platform
(e.g. core or atom)"

EXAMPLES
--------

$ perf stat \-- make

   Performance counter stats for 'make':

        83723.452481      task-clock:u (msec)       #    1.004 CPUs utilized
                   0      context-switches:u        #    0.000 K/sec
                   0      cpu-migrations:u          #    0.000 K/sec
           3,228,188      page-faults:u             #    0.039 M/sec
     229,570,665,834      cycles:u                  #    2.742 GHz
     313,163,853,778      instructions:u            #    1.36  insn per cycle
      69,704,684,856      branches:u                #  832.559 M/sec
       2,078,861,393      branch-misses:u           #    2.98% of all branches

        83.409183620 seconds time elapsed

        74.684747000 seconds user
         8.739217000 seconds sys

TIMINGS
-------
As displayed in the example above we can display 3 types of timings.
We always display the time the counters were enabled/alive:

        83.409183620 seconds time elapsed

For workload sessions we also display time the workloads spent in
user/system lands:

        74.684747000 seconds user
         8.739217000 seconds sys

Those times are the very same as displayed by the 'time' tool.

CSV FORMAT
----------

With -x, perf stat is able to output a not-quite-CSV format output
Commas in the output are not put into "". To make it easy to parse
it is recommended to use a different character like -x \;

The fields are in this order:

	- optional usec time stamp in fractions of second (with -I xxx)
	- optional CPU, core, or socket identifier
	- optional number of logical CPUs aggregated
	- counter value
	- unit of the counter value or empty
	- event name
	- run time of counter
	- percentage of measurement time the counter was running
	- optional variance if multiple values are collected with -r
	- optional metric value
	- optional unit of metric

Additional metrics may be printed with all earlier fields being empty.

include::intel-hybrid.txt[]

JSON FORMAT
-----------

With -j, perf stat is able to print out a JSON format output
that can be used for parsing.

- interval : optional timestamp in fractions of second (with -I)
- optional aggregate options:
		- core : core identifier (with --per-core)
		- die : die identifier (with --per-die)
		- socket : socket identifier (with --per-socket)
		- node : node identifier (with --per-node)
		- thread : thread identifier (with --per-thread)
- counters : number of aggregated PMU counters
- counter-value : counter value
- unit : unit of the counter value or empty
- event : event name
- variance : optional variance if multiple values are collected (with -r)
- event-runtime : run time of the event
- pcnt-running : percentage of time the event was running
- metric-value : optional metric value
- metric-unit : optional unit of metric

SEE ALSO
--------
linkperf:perf-top[1], linkperf:perf-list[1]

```

## 5. perf-top.txt - Live Analysis

```
perf-top(1)
===========

NAME
----
perf-top - System profiling tool.

SYNOPSIS
--------
[verse]
'perf top' [-e <EVENT> | --event=EVENT] [<options>]

DESCRIPTION
-----------
This command generates and displays a performance counter profile in real time.


OPTIONS
-------
-a::
--all-cpus::
        System-wide collection.  (default)

-c <count>::
--count=<count>::
	Event period to sample.

-C <cpu-list>::
--cpu=<cpu>::
Monitor only on the list of CPUs provided. Multiple CPUs can be provided as a
comma-separated list with no space: 0,1. Ranges of CPUs are specified with -: 0-2.
Default is to monitor all CPUS.

-d <seconds>::
--delay=<seconds>::
	Number of seconds to delay between refreshes.

-e <event>::
--event=<event>::
	Select the PMU event. Selection can be a symbolic event name
	(use 'perf list' to list all events) or a raw PMU event in the form
	of rN where N is a hexadecimal value that represents the raw register
	encoding with the layout of the event control registers as described
	by entries in /sys/bus/event_source/devices/cpu/format/*.

--filter=<filter>::
	Event filter.  This option should follow an event selector (-e). For
	syntax see linkperf:perf-record[1].

-E <entries>::
--entries=<entries>::
	Display this many functions.

-f <count>::
--count-filter=<count>::
	Only display functions with more events than this.

--group-sort-idx::
	Sort the output by the event at the index n in group. If n is invalid,
	sort by the first event. It can support multiple groups with different
	amount of events. WARNING: This should be used on grouped events.

-F <freq>::
--freq=<freq>::
	Profile at this frequency. Use 'max' to use the currently maximum
	allowed frequency, i.e. the value in the kernel.perf_event_max_sample_rate
	sysctl.

-i::
--inherit::
	Child tasks do not inherit counters.

-k <path>::
--vmlinux=<path>::
	Path to vmlinux.  Required for annotation functionality.

--ignore-vmlinux::
	Ignore vmlinux files.

--kallsyms=<file>::
	kallsyms pathname

-m <pages>::
--mmap-pages=<pages>::
	Number of mmap data pages (must be a power of two) or size
	specification in bytes with appended unit character - B/K/M/G.
	The size is rounded up to the nearest power-of-two page value.

-p <pid>::
--pid=<pid>::
	Profile events on existing Process ID (comma separated list).

-t <tid>::
--tid=<tid>::
        Profile events on existing thread ID (comma separated list).

-u::
--uid=::
        Record events in threads owned by uid. Name or number.

-r <priority>::
--realtime=<priority>::
	Collect data with this RT SCHED_FIFO priority.

--sym-annotate=<symbol>::
        Annotate this symbol.

-K::
--hide_kernel_symbols::
        Hide kernel symbols.

-U::
--hide_user_symbols::
        Hide user symbols.

--demangle-kernel::
        Demangle kernel symbols.

-D::
--dump-symtab::
        Dump the symbol table used for profiling.

-v::
--verbose::
	Be more verbose (show counter open errors, etc).

-z::
--zero::
	Zero history across display updates.

-s::
--sort::
	Sort by key(s): pid, comm, dso, symbol, parent, srcline, weight,
	local_weight, abort, in_tx, transaction, overhead, sample, period.
	Please see description of --sort in the perf-report man page.

--fields=::
	Specify output field - multiple keys can be specified in CSV format.
	Following fields are available:
	overhead, overhead_sys, overhead_us, overhead_children, sample and period.
	Also it can contain any sort key(s).

	By default, every sort keys not specified in --field will be appended
	automatically.

-n::
--show-nr-samples::
	Show a column with the number of samples.

--show-total-period::
	Show a column with the sum of periods.

--dsos::
	Only consider symbols in these dsos.  This option will affect the
	percentage of the overhead column.  See --percentage for more info.

--comms::
	Only consider symbols in these comms.  This option will affect the
	percentage of the overhead column.  See --percentage for more info.

--symbols::
	Only consider these symbols.  This option will affect the
	percentage of the overhead column.  See --percentage for more info.

-M::
--disassembler-style=:: Set disassembler style for objdump.

--addr2line=<path>::
        Path to addr2line binary.

--objdump=<path>::
        Path to objdump binary.

--prefix=PREFIX::
--prefix-strip=N::
        Remove first N entries from source file path names in executables
        and add PREFIX. This allows to display source code compiled on systems
        with different file system layout.

--source::
	Interleave source code with assembly code. Enabled by default,
	disable with --no-source.

--asm-raw::
	Show raw instruction encoding of assembly instructions.

-g::
	Enables call-graph (stack chain/backtrace) recording.

--call-graph [mode,type,min[,limit],order[,key][,branch]]::
	Setup and enable call-graph (stack chain/backtrace) recording,
	implies -g.  See `--call-graph` section in perf-record and
	perf-report man pages for details.

--children::
	Accumulate callchain of children to parent entry so that then can
	show up in the output.  The output will have a new "Children" column
	and will be sorted on the data.  It requires -g/--call-graph option
	enabled.  See the `overhead calculation' section for more details.
	Enabled by default, disable with --no-children.

--max-stack::
	Set the stack depth limit when parsing the callchain, anything
	beyond the specified depth will be ignored. This is a trade-off
	between information loss and faster processing especially for
	workloads that can have a very long callchain stack.

	Default: /proc/sys/kernel/perf_event_max_stack when present, 127 otherwise.

--ignore-callees=<regex>::
        Ignore callees of the function(s) matching the given regex.
        This has the effect of collecting the callers of each such
        function into one place in the call-graph tree.

--percent-limit::
	Do not show entries which have an overhead under that percent.
	(Default: 0).

--percentage::
	Determine how to display the overhead percentage of filtered entries.
	Filters can be applied by --comms, --dsos and/or --symbols options and
	Zoom operations on the TUI (thread, dso, etc).

	"relative" means it's relative to filtered entries only so that the
	sum of shown entries will be always 100%. "absolute" means it retains
	the original value before and after the filter is applied.

-w::
--column-widths=<width[,width...]>::
	Force each column width to the provided list, for large terminal
	readability.  0 means no limit (default behavior).

--proc-map-timeout::
	When processing pre-existing threads /proc/XXX/mmap, it may take
	a long time, because the file may be huge. A time out is needed
	in such cases.
	This option sets the time out limit. The default value is 500 ms.


-b::
--branch-any::
	Enable taken branch stack sampling. Any type of taken branch may be sampled.
	This is a shortcut for --branch-filter any. See --branch-filter for more infos.

-j::
--branch-filter::
	Enable taken branch stack sampling. Each sample captures a series of consecutive
	taken branches. The number of branches captured with each sample depends on the
	underlying hardware, the type of branches of interest, and the executed code.
	It is possible to select the types of branches captured by enabling filters.
	For a full list of modifiers please see the perf record manpage.

	The option requires at least one branch type among any, any_call, any_ret, ind_call, cond.
	The privilege levels may be omitted, in which case, the privilege levels of the associated
	event are applied to the branch filter. Both kernel (k) and hypervisor (hv) privilege
	levels are subject to permissions.  When sampling on multiple events, branch stack sampling
	is enabled for all the sampling events. The sampled branch type is the same for all events.
	The various filters must be specified as a comma separated list: --branch-filter any_ret,u,k
	Note that this feature may not be available on all processors.

--branch-history::
	Add the addresses of sampled taken branches to the callstack.
	This allows to examine the path the program took to each sample.

--raw-trace::
	When displaying traceevent output, do not use print fmt or plugins.

-H::
--hierarchy::
	Enable hierarchical output.  In the hierarchy mode, each sort key groups
	samples based on the criteria and then sub-divide it using the lower
	level sort key.

	For example, in normal output:

	  perf report -s dso,sym
	  #
	  # Overhead  Shared Object      Symbol
	  # ........  .................  ...........
	      50.00%  [kernel.kallsyms]  [k] kfunc1
	      20.00%  perf               [.] foo
	      15.00%  [kernel.kallsyms]  [k] kfunc2
	      10.00%  perf               [.] bar
	       5.00%  libc.so            [.] libcall

	In hierarchy output:

	  perf report -s dso,sym --hierarchy
	  #
	  #   Overhead  Shared Object / Symbol
	  # ..........  ......................
	      65.00%    [kernel.kallsyms]
	        50.00%    [k] kfunc1
	        15.00%    [k] kfunc2
	      30.00%    perf
	        20.00%    [.] foo
	        10.00%    [.] bar
	       5.00%    libc.so
	         5.00%    [.] libcall

--overwrite::
	Enable this to use just the most recent records, which helps in high core count
	machines such as Knights Landing/Mill, but right now is disabled by default as
	the pausing used in this technique is leading to loss of metadata events such
	as PERF_RECORD_MMAP which makes 'perf top' unable to resolve samples, leading
	to lots of unknown samples appearing on the UI. Enable this if you are in such
	machines and profiling a workload that doesn't creates short lived threads and/or
	doesn't uses many executable mmap operations. Work is being planed to solve
	this situation, till then, this will remain disabled by default.

--force::
	Don't do ownership validation.

--num-thread-synthesize::
	The number of threads to run when synthesizing events for existing processes.
	By default, the number of threads equals to the number of online CPUs.

--namespaces::
	Record events of type PERF_RECORD_NAMESPACES and display it with the
	'cgroup_id' sort key.

-G name::
--cgroup name::
monitor only in the container (cgroup) called "name". This option is available only
in per-cpu mode. The cgroup filesystem must be mounted. All threads belonging to
container "name" are monitored when they run on the monitored CPUs. Multiple cgroups
can be provided. Each cgroup is applied to the corresponding event, i.e., first cgroup
to first event, second cgroup to second event and so on. It is possible to provide
an empty cgroup (monitor all the time) using, e.g., -G foo,,bar. Cgroups must have
corresponding events, i.e., they always refer to events defined earlier on the command
line. If the user wants to track multiple events for a specific cgroup, the user can
use '-e e1 -e e2 -G foo,foo' or just use '-e e1 -e e2 -G foo'.

--all-cgroups::
	Record events of type PERF_RECORD_CGROUP and display it with the
	'cgroup' sort key.

--switch-on EVENT_NAME::
	Only consider events after this event is found.

	E.g.:

           Find out where broadcast packets are handled

		perf probe -L icmp_rcv

	   Insert a probe there:

		perf probe icmp_rcv:59

	   Start perf top and ask it to only consider the cycles events when a
           broadcast packet arrives This will show a menu with two entries and
           will start counting when a broadcast packet arrives:

		perf top -e cycles,probe:icmp_rcv --switch-on=probe:icmp_rcv

	   Alternatively one can ask for a group and then two overhead columns
           will appear, the first for cycles and the second for the switch-on event.

		perf top -e '{cycles,probe:icmp_rcv}' --switch-on=probe:icmp_rcv

	This may be interesting to measure a workload only after some initialization
	phase is over, i.e. insert a perf probe at that point and use the above
	examples replacing probe:icmp_rcv with the just-after-init probe.

--switch-off EVENT_NAME::
	Stop considering events after this event is found.

--show-on-off-events::
	Show the --switch-on/off events too. This has no effect in 'perf top' now
	but probably we'll make the default not to show the switch-on/off events
        on the --group mode and if there is only one event besides the off/on ones,
	go straight to the histogram browser, just like 'perf top' with no events
	explicitly specified does.

--stitch-lbr::
	Show callgraph with stitched LBRs, which may have more complete
	callgraph. The option must be used with --call-graph lbr recording.
	Disabled by default. In common cases with call stack overflows,
	it can recreate better call stacks than the default lbr call stack
	output. But this approach is not foolproof. There can be cases
	where it creates incorrect call stacks from incorrect matches.
	The known limitations include exception handing such as
	setjmp/longjmp will have calls/returns not match.

ifdef::HAVE_LIBPFM[]
--pfm-events events::
Select a PMU event using libpfm4 syntax (see http://perfmon2.sf.net)
including support for event filters. For example '--pfm-events
inst_retired:any_p:u:c=1:i'. More than one event can be passed to the
option using the comma separator. Hardware events and generic hardware
events cannot be mixed together. The latter must be used with the -e
option. The -e option and this one can be mixed and matched.  Events
can be grouped using the {} notation.
endif::HAVE_LIBPFM[]

INTERACTIVE PROMPTING KEYS
--------------------------

[d]::
	Display refresh delay.

[e]::
	Number of entries to display.

[E]::
	Event to display when multiple counters are active.

[f]::
	Profile display filter (>= hit count).

[F]::
	Annotation display filter (>= % of total).

[s]::
	Annotate symbol.

[S]::
	Stop annotation, return to full profile display.

[K]::
	Hide kernel symbols.

[U]::
	Hide user symbols.

[z]::
	Toggle event count zeroing across display updates.

[qQ]::
	Quit.

Pressing any unmapped key displays a menu, and prompts for input.

include::callchain-overhead-calculation.txt[]

SEE ALSO
--------
linkperf:perf-stat[1], linkperf:perf-list[1], linkperf:perf-report[1]

```

## 6. perf-annotate.txt - Source Annotation

```
perf-annotate(1)
================

NAME
----
perf-annotate - Read perf.data (created by perf record) and display annotated code

SYNOPSIS
--------
[verse]
'perf annotate' [-i <file> | --input=file] [symbol_name]

DESCRIPTION
-----------
This command reads the input file and displays an annotated version of the
code. If the object file has debug symbols then the source code will be
displayed alongside assembly code.

If there is no debug info in the object, then annotated assembly is displayed.

OPTIONS
-------
-i::
--input=<file>::
        Input file name. (default: perf.data unless stdin is a fifo)

-d::
--dsos=<dso[,dso...]>::
        Only consider symbols in these dsos.
-s::
--symbol=<symbol>::
        Symbol to annotate.

-f::
--force::
        Don't do ownership validation.

-v::
--verbose::
        Be more verbose. (Show symbol address, etc)

-q::
--quiet::
	Do not show any warnings or messages.  (Suppress -v)

-n::
--show-nr-samples::
	Show the number of samples for each symbol

-D::
--dump-raw-trace::
        Dump raw trace in ASCII.

-k::
--vmlinux=<file>::
        vmlinux pathname.

--ignore-vmlinux::
	Ignore vmlinux files.

--itrace::
	Options for decoding instruction tracing data. The options are:

include::itrace.txt[]

	To disable decoding entirely, use --no-itrace.

-m::
--modules::
        Load module symbols. WARNING: use only with -k and LIVE kernel.

-l::
--print-line::
        Print matching source lines (may be slow).

-P::
--full-paths::
        Don't shorten the displayed pathnames.

--stdio:: Use the stdio interface.

--stdio2:: Use the stdio2 interface, non-interactive, uses the TUI formatting.

--stdio-color=<mode>::
	'always', 'never' or 'auto', allowing configuring color output
	via the command line, in addition to via "color.ui" .perfconfig.
	Use '--stdio-color always' to generate color even when redirecting
	to a pipe or file. Using just '--stdio-color' is equivalent to
	using 'always'.

--tui:: Use the TUI interface. Use of --tui requires a tty, if one is not
	present, as when piping to other commands, the stdio interface is
	used. This interfaces starts by centering on the line with more
	samples, TAB/UNTAB cycles through the lines with more samples.

--gtk:: Use the GTK interface.

-C::
--cpu=<cpu>:: Only report samples for the list of CPUs provided. Multiple CPUs can
	be provided as a comma-separated list with no space: 0,1. Ranges of
	CPUs are specified with -: 0-2. Default is to report samples on all
	CPUs.

--asm-raw::
	Show raw instruction encoding of assembly instructions.

--show-total-period:: Show a column with the sum of periods.

--source::
	Interleave source code with assembly code. Enabled by default,
	disable with --no-source.

--symfs=<directory>::
        Look for files with symbols relative to this directory.

-M::
--disassembler-style=:: Set disassembler style for objdump.

--addr2line=<path>::
        Path to addr2line binary.

--objdump=<path>::
        Path to objdump binary.

--prefix=PREFIX::
--prefix-strip=N::
	Remove first N entries from source file path names in executables
	and add PREFIX. This allows to display source code compiled on systems
	with different file system layout.

--skip-missing::
	Skip symbols that cannot be annotated.

--group::
	Show event group information together

--demangle::
	Demangle symbol names to human readable form. It's enabled by default,
	disable with --no-demangle.

--demangle-kernel::
	Demangle kernel symbol names to human readable form (for C++ kernels).

--percent-type::
	Set annotation percent type from following choices:
	  global-period, local-period, global-hits, local-hits

	The local/global keywords set if the percentage is computed
	in the scope of the function (local) or the whole data (global).
	The period/hits keywords set the base the percentage is computed
	on - the samples period or the number of samples (hits).

--percent-limit::
	Do not show functions which have an overhead under that percent on
	stdio or stdio2 (Default: 0).  Note that this is about selection of
	functions to display, not about lines within the function.

--data-type[=TYPE_NAME]::
	Display data type annotation instead of code.  It infers data type of
	samples (if they are memory accessing instructions) using DWARF debug
	information.  It can take an optional argument of data type name.  In
	that case it'd show annotation for the type only, otherwise it'd show
	all data types it finds.

--type-stat::
	Show stats for the data type annotation.

--skip-empty::
	Do not display empty (or dummy) events.

--code-with-type::
	Show data type info in code annotation (for memory instructions only).


SEE ALSO
--------
linkperf:perf-record[1], linkperf:perf-report[1]

```

## 7. perf-script.txt - Scripting

```
perf-script(1)
=============

NAME
----
perf-script - Read perf.data (created by perf record) and display trace output

SYNOPSIS
--------
[verse]
'perf script' [<options>]
'perf script' [<options>] record <script> [<record-options>] <command>
'perf script' [<options>] report <script> [script-args]
'perf script' [<options>] <script> <required-script-args> [<record-options>] <command>
'perf script' [<options>] <top-script> [script-args]

DESCRIPTION
-----------
This command reads the input file and displays the trace recorded.

There are several variants of perf script:

  'perf script' to see a detailed trace of the workload that was
  recorded.

  You can also run a set of pre-canned scripts that aggregate and
  summarize the raw trace data in various ways (the list of scripts is
  available via 'perf script -l').  The following variants allow you to
  record and run those scripts:

  'perf script record <script> <command>' to record the events required
  for 'perf script report'.  <script> is the name displayed in the
  output of 'perf script --list' i.e. the actual script name minus any
  language extension.  If <command> is not specified, the events are
  recorded using the -a (system-wide) 'perf record' option.

  'perf script report <script> [args]' to run and display the results
  of <script>.  <script> is the name displayed in the output of 'perf
  script --list' i.e. the actual script name minus any language
  extension.  The perf.data output from a previous run of 'perf script
  record <script>' is used and should be present for this command to
  succeed.  [args] refers to the (mainly optional) args expected by
  the script.

  'perf script <script> <required-script-args> <command>' to both
  record the events required for <script> and to run the <script>
  using 'live-mode' i.e. without writing anything to disk.  <script>
  is the name displayed in the output of 'perf script --list' i.e. the
  actual script name minus any language extension.  If <command> is
  not specified, the events are recorded using the -a (system-wide)
  'perf record' option.  If <script> has any required args, they
  should be specified before <command>.  This mode doesn't allow for
  optional script args to be specified; if optional script args are
  desired, they can be specified using separate 'perf script record'
  and 'perf script report' commands, with the stdout of the record step
  piped to the stdin of the report script, using the '-o -' and '-i -'
  options of the corresponding commands.

  'perf script <top-script>' to both record the events required for
  <top-script> and to run the <top-script> using 'live-mode'
  i.e. without writing anything to disk.  <top-script> is the name
  displayed in the output of 'perf script --list' i.e. the actual
  script name minus any language extension; a <top-script> is defined
  as any script name ending with the string 'top'.

  [<record-options>] can be passed to the record steps of 'perf script
  record' and 'live-mode' variants; this isn't possible however for
  <top-script> 'live-mode' or 'perf script report' variants.

  See the 'SEE ALSO' section for links to language-specific
  information on how to write and run your own trace scripts.

OPTIONS
-------
<command>...::
	Any command you can specify in a shell.

-D::
--dump-raw-trace=::
        Display verbose dump of the trace data.

--dump-unsorted-raw-trace=::
        Same as --dump-raw-trace but not sorted in time order.

-L::
--Latency=::
        Show latency attributes (irqs/preemption disabled, etc).

-l::
--list=::
        Display a list of available trace scripts.

-s ['lang']::
--script=::
        Process trace data with the given script ([lang]:script[.ext]).
	If the string 'lang' is specified in place of a script name, a
        list of supported languages will be displayed instead.

-g::
--gen-script=::
        Generate perf-script.[ext] starter script for given language,
        using current perf.data.

--dlfilter=<file>::
	Filter sample events using the given shared object file.
	Refer linkperf:perf-dlfilter[1]

--dlarg=<arg>::
	Pass 'arg' as an argument to the dlfilter. --dlarg may be repeated
	to add more arguments.

--list-dlfilters::
        Display a list of available dlfilters. Use with option -v (must come
        before option --list-dlfilters) to show long descriptions.

-a::
        Force system-wide collection.  Scripts run without a <command>
        normally use -a by default, while scripts run with a <command>
        normally don't - this option allows the latter to be run in
        system-wide mode.

-i::
--input=::
        Input file name. (default: perf.data unless stdin is a fifo)

-d::
--debug-mode::
        Do various checks like samples ordering and lost events.

-F::
--fields::
        Comma separated list of fields to print. Options are:
        comm, tid, pid, time, cpu, event, trace, ip, sym, dso, dsoff, addr, symoff,
        srcline, period, iregs, uregs, brstack, brstacksym, flags, bpf-output,
        brstackinsn, brstackinsnlen, brstackdisasm, brstackoff, callindent, insn, disasm,
        insnlen, synth, phys_addr, metric, misc, srccode, ipc, data_page_size,
        code_page_size, ins_lat, machine_pid, vcpu, cgroup, retire_lat, brcntr,

        Field list can be prepended with the type, trace, sw or hw,
        to indicate to which event type the field list applies.
        e.g., -F sw:comm,tid,time,ip,sym  and -F trace:time,cpu,trace

		perf script -F <fields>

	is equivalent to:

		perf script -F trace:<fields> -F sw:<fields> -F hw:<fields>

	i.e., the specified fields apply to all event types if the type string
	is not given.

	In addition to overriding fields, it is also possible to add or remove
	fields from the defaults. For example

		-F -cpu,+insn

	removes the cpu field and adds the insn field. Adding/removing fields
	cannot be mixed with normal overriding.

	The arguments are processed in the order received. A later usage can
	reset a prior request. e.g.:

		-F trace: -F comm,tid,time,ip,sym

	The first -F suppresses trace events (field list is ""), but then the
	second invocation sets the fields to comm,tid,time,ip,sym. In this case a
	warning is given to the user:

		"Overriding previous field request for all events."

	Alternatively, consider the order:

		-F comm,tid,time,ip,sym -F trace:

	The first -F sets the fields for all events and the second -F
	suppresses trace events. The user is given a warning message about
	the override, and the result of the above is that only S/W and H/W
	events are displayed with the given fields.

	It's possible tp add/remove fields only for specific event type:

		-Fsw:-cpu,-period

	removes cpu and period from software events.

	For the 'wildcard' option if a user selected field is invalid for an
	event type, a message is displayed to the user that the option is
	ignored for that type. For example:

		$ perf script -F comm,tid,trace
		'trace' not valid for hardware events. Ignoring.
		'trace' not valid for software events. Ignoring.

	Alternatively, if the type is given an invalid field is specified it
	is an error. For example:

        perf script -v -F sw:comm,tid,trace
        'trace' not valid for software events.

	At this point usage is displayed, and perf-script exits.

	The flags field is synthesized and may have a value when Instruction
	Trace decoding. The flags are "bcrosyiABExghDt" which stand for branch,
	call, return, conditional, system, asynchronous, interrupt,
	transaction abort, trace begin, trace end, in transaction, VM-Entry,
	VM-Exit, interrupt disabled and interrupt disable toggle respectively.
	Known combinations of flags are printed more nicely e.g.
	"call" for "bc", "return" for "br", "jcc" for "bo", "jmp" for "b",
	"int" for "bci", "iret" for "bri", "syscall" for "bcs", "sysret" for "brs",
	"async" for "by", "hw int" for "bcyi", "tx abrt" for "bA", "tr strt" for "bB",
	"tr end" for "bE", "vmentry" for "bcg", "vmexit" for "bch".
	However the "x", "D" and "t" flags will be displayed separately in those
	cases e.g. "jcc     (xD)" for a condition branch within a transaction
	with interrupts disabled. Note, interrupts becoming disabled is "t",
	whereas interrupts becoming enabled is "Dt".

	The callindent field is synthesized and may have a value when
	Instruction Trace decoding. For calls and returns, it will display the
	name of the symbol indented with spaces to reflect the stack depth.

	When doing instruction trace decoding, insn, disasm and insnlen give the
	instruction bytes, disassembled instructions (requires libcapstone support)
	and the instruction length of the current instruction respectively.

	The synth field is used by synthesized events which may be created when
	Instruction Trace decoding.

	The ipc (instructions per cycle) field is synthesized and may have a value when
	Instruction Trace decoding.

	The machine_pid and vcpu fields are derived from data resulting from using
	perf inject to insert a perf.data file recorded inside a virtual machine into
	a perf.data file recorded on the host at the same time.

	The cgroup fields requires sample having the cgroup id which is saved
	when "--all-cgroups" option is passed to 'perf record'.

	Finally, a user may not set fields to none for all event types.
	i.e., -F "" is not allowed.

	The brstack output includes branch related information with raw addresses using the
	FROM/TO/EVENT/INTX/ABORT/CYCLES/TYPE/SPEC syntax in the following order:
	FROM  : branch source instruction
	TO    : branch target instruction
	EVENT : M=branch target or direction was mispredicted
	        P=branch target or direction was predicted
	        N=branch not-taken
	        -=no event or not supported
	INTX  : X=branch inside a transactional region
	        -=branch not in transaction region or not supported
	ABORT : A=TSX abort entry
	        -=not aborted region or not supported
	CYCLES: the number of cycles that have elapsed since the last branch was recorded
	TYPE  : branch type: COND/UNCOND/IND/CALL/IND_CALL/RET etc.
	        -=not supported
	SPEC  : branch speculation info: SPEC_WRONG_PATH/NON_SPEC_CORRECT_PATH/SPEC_CORRECT_PATH
	        -=not supported

	The brstacksym is identical to brstack, except that the FROM and TO addresses are printed in a symbolic form if possible.

	When brstackinsn is specified the full assembler sequences of branch sequences for each sample
	is printed. This is the full execution path leading to the sample. This is only supported when the
	sample was recorded with perf record -b or -j any.

	Use brstackinsnlen to print the brstackinsn lenght. For example, you
	can’t know the next sequential instruction after an unconditional branch unless
	you calculate that based on its length.

	brstackdisasm acts like brstackinsn, but will print disassembled instructions if
	perf is built with the capstone library.

	The brstackoff field will print an offset into a specific dso/binary.

	With the metric option perf script can compute metrics for
	sampling periods, similar to perf stat. This requires
	specifying a group with multiple events defining metrics with the :S option
	for perf record. perf will sample on the first event, and
	print computed metrics for all the events in the group. Please note
	that the metric computed is averaged over the whole sampling
	period (since the last sample), not just for the sample point.

	For sample events it's possible to display misc field with -F +misc option,
	following letters are displayed for each bit:

	  PERF_RECORD_MISC_KERNEL               K
	  PERF_RECORD_MISC_USER                 U
	  PERF_RECORD_MISC_HYPERVISOR           H
	  PERF_RECORD_MISC_GUEST_KERNEL         G
	  PERF_RECORD_MISC_GUEST_USER           g
	  PERF_RECORD_MISC_MMAP_DATA*           M
	  PERF_RECORD_MISC_COMM_EXEC            E
	  PERF_RECORD_MISC_SWITCH_OUT           S
	  PERF_RECORD_MISC_SWITCH_OUT_PREEMPT   Sp

	  $ perf script -F +misc ...
	   sched-messaging  1414 K     28690.636582:       4590 cycles ...
	   sched-messaging  1407 U     28690.636600:     325620 cycles ...
	   sched-messaging  1414 K     28690.636608:      19473 cycles ...
	  misc field ___________/

-k::
--vmlinux=<file>::
        vmlinux pathname

--kallsyms=<file>::
        kallsyms pathname

--symfs=<directory>::
        Look for files with symbols relative to this directory.

-G::
--hide-call-graph::
        When printing symbols do not display call chain.

--stop-bt::
        Stop display of callgraph at these symbols

-C::
--cpu:: Only report samples for the list of CPUs provided. Multiple CPUs can
	be provided as a comma-separated list with no space: 0,1. Ranges of
	CPUs are specified with -: 0-2. Default is to report samples on all
	CPUs.

-c::
--comms=::
	Only display events for these comms. CSV that understands
	file://filename entries.

--pid=::
	Only show events for given process ID (comma separated list).

--tid=::
	Only show events for given thread ID (comma separated list).

-I::
--show-info::
	Display extended information about the perf.data file. This adds
	information which may be very large and thus may clutter the display.
	It currently includes: cpu and numa topology of the host system.
	It can only be used with the perf script report mode.

--show-kernel-path::
	Try to resolve the path of [kernel.kallsyms]

--show-task-events
	Display task related events (e.g. FORK, COMM, EXIT).

--show-mmap-events
	Display mmap related events (e.g. MMAP, MMAP2).

--show-namespace-events
	Display namespace events i.e. events of type PERF_RECORD_NAMESPACES.

--show-switch-events
	Display context switch events i.e. events of type PERF_RECORD_SWITCH or
	PERF_RECORD_SWITCH_CPU_WIDE.

--show-lost-events
	Display lost events i.e. events of type PERF_RECORD_LOST.

--show-round-events
	Display finished round events i.e. events of type PERF_RECORD_FINISHED_ROUND.

--show-bpf-events
	Display bpf events i.e. events of type PERF_RECORD_KSYMBOL and PERF_RECORD_BPF_EVENT.

--show-cgroup-events
	Display cgroup events i.e. events of type PERF_RECORD_CGROUP.

--show-text-poke-events
	Display text poke events i.e. events of type PERF_RECORD_TEXT_POKE and
	PERF_RECORD_KSYMBOL.

--demangle::
	Demangle symbol names to human readable form. It's enabled by default,
	disable with --no-demangle.

--demangle-kernel::
	Demangle kernel symbol names to human readable form (for C++ kernels).

--addr2line=<path>::
	Path to addr2line binary.

--header
	Show perf.data header.

--header-only
	Show only perf.data header.

--itrace::
	Options for decoding instruction tracing data. The options are:

include::itrace.txt[]

	To disable decoding entirely, use --no-itrace.

--full-source-path::
	Show the full path for source files for srcline output.

--max-stack::
        Set the stack depth limit when parsing the callchain, anything
        beyond the specified depth will be ignored. This is a trade-off
        between information loss and faster processing especially for
        workloads that can have a very long callchain stack.
        Note that when using the --itrace option the synthesized callchain size
        will override this value if the synthesized callchain size is bigger.

        Default: 127

--ns::
	Use 9 decimal places when displaying time (i.e. show the nanoseconds)

-f::
--force::
	Don't do ownership validation.

--time::
	Only analyze samples within given time window: <start>,<stop>. Times
	have the format seconds.nanoseconds. If start is not given (i.e. time
	string is ',x.y') then analysis starts at the beginning of the file. If
	stop time is not given (i.e. time string is 'x.y,') then analysis goes
	to end of file. Multiple ranges can be separated by spaces, which
	requires the argument to be quoted e.g. --time "1234.567,1234.789 1235,"

	Also support time percent with multiple time ranges. Time string is
	'a%/n,b%/m,...' or 'a%-b%,c%-%d,...'.

	For example:
	Select the second 10% time slice:
	perf script --time 10%/2

	Select from 0% to 10% time slice:
	perf script --time 0%-10%

	Select the first and second 10% time slices:
	perf script --time 10%/1,10%/2

	Select from 0% to 10% and 30% to 40% slices:
	perf script --time 0%-10%,30%-40%

--max-blocks::
	Set the maximum number of program blocks to print with brstackinsn for
	each sample.

--reltime::
	Print time stamps relative to trace start.

--deltatime::
	Print time stamps relative to previous event.

--per-event-dump::
	Create per event files with a "perf.data.EVENT.dump" name instead of
        printing to stdout, useful, for instance, for generating flamegraphs.

--inline::
	If a callgraph address belongs to an inlined function, the inline stack
	will be printed. Each entry has function name and file/line. Enabled by
	default, disable with --no-inline.

--insn-trace[=<raw|disasm>]::
	Show instruction stream in bytes (raw) or disassembled (disasm)
	for intel_pt traces. The default is 'raw'. To use xed, combine
	'raw' with --xed to show disassembly done by xed.

--xed::
	Run xed disassembler on output. Requires installing the xed disassembler.

-S::
--symbols=symbol[,symbol...]::
	Only consider the listed symbols. Symbols are typically a name
	but they may also be hexadecimal address.

	The hexadecimal address may be the start address of a symbol or
	any other address to filter the trace records

	For example, to select the symbol noploop or the address 0x4007a0:
	perf script --symbols=noploop,0x4007a0

	Support filtering trace records by symbol name, start address of
	symbol, any hexadecimal address and address range.

	The comparison order is:

	1. symbol name comparison
	2. symbol start address comparison.
	3. any hexadecimal address comparison.
	4. address range comparison (see --addr-range).

--addr-range::
       Use with -S or --symbols to list traced records within address range.

       For example, to list the traced records within the address range
       [0x4007a0, 0x0x4007a9]:
       perf script -S 0x4007a0 --addr-range 10

--dsos=::
	Only consider symbols in these DSOs.

--call-trace::
	Show call stream for intel_pt traces. The CPUs are interleaved, but
	can be filtered with -C.

--call-ret-trace::
	Show call and return stream for intel_pt traces.

--graph-function::
	For itrace only show specified functions and their callees for
	itrace. Multiple functions can be separated by comma.

--switch-on EVENT_NAME::
	Only consider events after this event is found.

--switch-off EVENT_NAME::
	Stop considering events after this event is found.

--show-on-off-events::
	Show the --switch-on/off events too.

--stitch-lbr::
	Show callgraph with stitched LBRs, which may have more complete
	callgraph. The perf.data file must have been obtained using
	perf record --call-graph lbr.
	Disabled by default. In common cases with call stack overflows,
	it can recreate better call stacks than the default lbr call stack
	output. But this approach is not foolproof. There can be cases
	where it creates incorrect call stacks from incorrect matches.
	The known limitations include exception handing such as
	setjmp/longjmp will have calls/returns not match.

--merge-callchains::
	Enable merging deferred user callchains if available.  This is the
	default behavior.  If you want to see separate CALLCHAIN_DEFERRED
	records for some reason, use --no-merge-callchains explicitly.

:GMEXAMPLECMD: script
:GMEXAMPLESUBCMD:
include::guest-files.txt[]

SEE ALSO
--------
linkperf:perf-record[1], linkperf:perf-script-perl[1],
linkperf:perf-script-python[1], linkperf:perf-intel-pt[1],
linkperf:perf-dlfilter[1]

```

## 8. perf-trace.txt - Tracing

```
perf-trace(1)
=============

NAME
----
perf-trace - strace inspired tool

SYNOPSIS
--------
[verse]
'perf trace'
'perf trace record'

DESCRIPTION
-----------
This command will show the events associated with the target, initially
syscalls, but other system events like pagefaults, task lifetime events,
scheduling events, etc.

This is a live mode tool in addition to working with perf.data files like
the other perf tools. Files can be generated using the 'perf record' command
but the session needs to include the raw_syscalls events (-e 'raw_syscalls:*').
Alternatively, 'perf trace record' can be used as a shortcut to
automatically include the raw_syscalls events when writing events to a file.

The following options apply to perf trace; options to perf trace record are
found in the perf record man page.

OPTIONS
-------

-a::
--all-cpus::
        System-wide collection from all CPUs.

-e::
--expr::
--event::
	List of syscalls and other perf events (tracepoints, HW cache events,
	etc) to show. Globbing is supported, e.g.: "epoll_*", "*msg*", etc.
	See 'perf list' for a complete list of events.
	Prefixing with ! shows all syscalls but the ones specified.  You may
	need to escape it.

--filter=<filter>::
        Event filter. This option should follow an event selector (-e) which
	selects tracepoint event(s).


-D msecs::
--delay msecs::
After starting the program, wait msecs before measuring. This is useful to
filter out the startup phase of the program, which is often very different.

-o::
--output=::
	Output file name.

-p::
--pid=::
	Record events on existing process ID (comma separated list).

-t::
--tid=::
        Record events on existing thread ID (comma separated list).

-u::
--uid=::
        Record events in threads owned by uid. Name or number.

-G::
--cgroup::
	Record events in threads in a cgroup.

	Look for cgroups to set at the /sys/fs/cgroup/perf_event directory, then
	remove the /sys/fs/cgroup/perf_event/ part and try:

		perf trace -G A -e sched:*switch

	Will set all raw_syscalls:sys_{enter,exit}, pgfault, vfs_getname, etc
	_and_ sched:sched_switch to the 'A' cgroup, while:

		perf trace -e sched:*switch -G A

	will only set the sched:sched_switch event to the 'A' cgroup, all the
	other events (raw_syscalls:sys_{enter,exit}, etc are left "without"
	a cgroup (on the root cgroup, sys wide, etc).

	Multiple cgroups:

		perf trace -G A -e sched:*switch -G B

	the syscall ones go to the 'A' cgroup, the sched:sched_switch goes
	to the 'B' cgroup.

--filter-pids=::
	Filter out events for these pids and for 'trace' itself (comma separated list).

-v::
--verbose::
        Increase the verbosity level.

--no-inherit::
	Child tasks do not inherit counters.

-m::
--mmap-pages=::
	Number of mmap data pages (must be a power of two) or size
	specification in bytes with appended unit character - B/K/M/G.
	The size is rounded up to the nearest power-of-two page value.

-C::
--cpu::
Collect samples only on the list of CPUs provided. Multiple CPUs can be provided as a
comma-separated list with no space: 0,1. Ranges of CPUs are specified with -: 0-2.
In per-thread mode with inheritance mode on (default), Events are captured only when
the thread executes on the designated CPUs. Default is to monitor all CPUs.

--duration::
	Show only events that had a duration greater than N.M ms.

--sched::
	Accrue thread runtime and provide a summary at the end of the session.

--failure::
	Show only syscalls that failed, i.e. that returned < 0.

-i::
--input::
	Process events from a given perf data file.

-T::
--time::
	Print full timestamp rather time relative to first sample.

--comm::
        Show process COMM right beside its ID, on by default, disable with --no-comm.

-s::
--summary::
	Show only a summary of syscalls by thread with min, max, and average times
    (in msec) and relative stddev.

-S::
--with-summary::
	Show all syscalls followed by a summary by thread with min, max, and
    average times (in msec) and relative stddev.

--errno-summary::
	To be used with -s or -S, to show stats for the errnos experienced by
	syscalls, using only this option will trigger --summary.

--summary-mode=mode::
	To be used with -s or -S, to select how to show summary.  By default it'll
	show the syscall summary by thread.  Possible values are: thread, total,
	cgroup.

--tool_stats::
	Show tool stats such as number of times fd->pathname was discovered thru
	hooking the open syscall return + vfs_getname or via reading /proc/pid/fd, etc.

-f::
--force::
	Don't complain, do it.

-F=[all|min|maj]::
--pf=[all|min|maj]::
	Trace pagefaults. Optionally, you can specify whether you want minor,
	major or all pagefaults. Default value is maj.

--syscalls::
	Trace system calls. This options is enabled by default, disable with
	--no-syscalls.

--call-graph [mode,type,min[,limit],order[,key][,branch]]::
        Setup and enable call-graph (stack chain/backtrace) recording.
        See `--call-graph` section in perf-record and perf-report
        man pages for details. The ones that are most useful in 'perf trace'
        are 'dwarf' and 'lbr', where available, try: 'perf trace --call-graph dwarf'.

        Using this will, for the root user, bump the value of --mmap-pages to 4
        times the maximum for non-root users, based on the kernel.perf_event_mlock_kb
        sysctl. This is done only if the user doesn't specify a --mmap-pages value.

--kernel-syscall-graph::
	 Show the kernel callchains on the syscall exit path.

--max-events=N::
	Stop after processing N events. Note that strace-like events are considered
	only at exit time or when a syscall is interrupted, i.e. in those cases this
	option is equivalent to the number of lines printed.

--switch-on EVENT_NAME::
	Only consider events after this event is found.

--switch-off EVENT_NAME::
	Stop considering events after this event is found.

--show-on-off-events::
	Show the --switch-on/off events too.

--max-stack::
        Set the stack depth limit when parsing the callchain, anything
        beyond the specified depth will be ignored. Note that at this point
        this is just about the presentation part, i.e. the kernel is still
        not limiting, the overhead of callchains needs to be set via the
        knobs in --call-graph dwarf.

        Implies '--call-graph dwarf' when --call-graph not present on the
        command line, on systems where DWARF unwinding was built in.

        Default: /proc/sys/kernel/perf_event_max_stack when present for
                 live sessions (without --input/-i), 127 otherwise.

--min-stack::
        Set the stack depth limit when parsing the callchain, anything
        below the specified depth will be ignored. Disabled by default.

        Implies '--call-graph dwarf' when --call-graph not present on the
        command line, on systems where DWARF unwinding was built in.

--print-sample::
	Print the PERF_RECORD_SAMPLE PERF_SAMPLE_ info for the
	raw_syscalls:sys_{enter,exit} tracepoints, for debugging.

--proc-map-timeout::
	When processing pre-existing threads /proc/XXX/mmap, it may take a long time,
	because the file may be huge. A time out is needed in such cases.
	This option sets the time out limit. The default value is 500 ms.

--sort-events::
	Do sorting on batches of events, use when noticing out of order events that
	may happen, for instance, when a thread gets migrated to a different CPU
	while processing a syscall.

--libtraceevent_print::
	Use libtraceevent to print tracepoint arguments. By default 'perf trace' uses
	the same beautifiers used in the strace-like enter+exit lines to augment the
	tracepoint arguments.

--force-btf::
	Use btf_dump to pretty print syscall argument data, instead of using hand-crafted pretty
	printers. This option is intended for testing BTF integration in perf trace. btf_dump-based
	pretty-printing serves as a fallback to hand-crafted pretty printers, as the latter can
	better pretty-print integer flags and struct pointers.

--bpf-summary::
	Collect system call statistics in BPF.  This is only for live mode and
	works well with -s/--summary option where no argument information is
	required.

--max-summary=N::
	Maximum number of lines in the summary mode.  Note that this applies to
	each entry (thread or cgroup).


PAGEFAULTS
----------

When tracing pagefaults, the format of the trace is as follows:

<min|maj>fault [<ip.symbol>+<ip.offset>] => <addr.dso@addr.offset> (<map type><addr level>).

- min/maj indicates whether fault event is minor or major;
- ip.symbol shows symbol for instruction pointer (the code that generated the
  fault); if no debug symbols available, perf trace will print raw IP;
- addr.dso shows DSO for the faulted address;
- map type is either 'd' for non-executable maps or 'x' for executable maps;
- addr level is either 'k' for kernel dso or '.' for user dso.

For symbols resolution you may need to install debugging symbols.

Please be aware that duration is currently always 0 and doesn't reflect actual
time it took for fault to be handled!

When --verbose specified, perf trace tries to print all available information
for both IP and fault address in the form of dso@symbol+offset.

EXAMPLES
--------

Trace only major pagefaults:

 $ perf trace --no-syscalls -F

Trace syscalls, major and minor pagefaults:

 $ perf trace -F all

  1416.547 ( 0.000 ms): python/20235 majfault [CRYPTO_push_info_+0x0] => /lib/x86_64-linux-gnu/libcrypto.so.1.0.0@0x61be0 (x.)

  As you can see, there was major pagefault in python process, from
  CRYPTO_push_info_ routine which faulted somewhere in libcrypto.so.

Trace the first 4 open, openat or open_by_handle_at syscalls (in the future more syscalls may match here):

  $ perf trace -e open* --max-events 4
  [root@jouet perf]# trace -e open* --max-events 4
  2272.992 ( 0.037 ms): gnome-shell/1370 openat(dfd: CWD, filename: /proc/self/stat) = 31
  2277.481 ( 0.139 ms): gnome-shell/3039 openat(dfd: CWD, filename: /proc/self/stat) = 65
  3026.398 ( 0.076 ms): gnome-shell/3039 openat(dfd: CWD, filename: /proc/self/stat) = 65
  4294.665 ( 0.015 ms): sed/15879 openat(dfd: CWD, filename: /etc/ld.so.cache, flags: CLOEXEC) = 3
  $

Trace the first minor page fault when running a workload:

  # perf trace -F min --max-stack=7 --max-events 1 sleep 1
     0.000 ( 0.000 ms): sleep/18006 minfault [__clear_user+0x1a] => 0x5626efa56080 (?k)
                                       __clear_user ([kernel.kallsyms])
                                       load_elf_binary ([kernel.kallsyms])
                                       search_binary_handler ([kernel.kallsyms])
                                       __do_execve_file.isra.33 ([kernel.kallsyms])
                                       __x64_sys_execve ([kernel.kallsyms])
                                       do_syscall_64 ([kernel.kallsyms])
                                       entry_SYSCALL_64 ([kernel.kallsyms])
  #

Trace the next min page page fault to take place on the first CPU:

  # perf trace -F min --call-graph=dwarf --max-events 1 --cpu 0
     0.000 ( 0.000 ms): Web Content/17136 minfault [js::gc::Chunk::fetchNextDecommittedArena+0x4b] => 0x7fbe6181b000 (?.)
                                       js::gc::FreeSpan::initAsEmpty (inlined)
                                       js::gc::Arena::setAsNotAllocated (inlined)
                                       js::gc::Chunk::fetchNextDecommittedArena (/usr/lib64/firefox/libxul.so)
                                       js::gc::Chunk::allocateArena (/usr/lib64/firefox/libxul.so)
                                       js::gc::GCRuntime::allocateArena (/usr/lib64/firefox/libxul.so)
                                       js::gc::ArenaLists::allocateFromArena (/usr/lib64/firefox/libxul.so)
                                       js::gc::GCRuntime::tryNewTenuredThing<JSString, (js::AllowGC)1> (inlined)
                                       js::AllocateString<JSString, (js::AllowGC)1> (/usr/lib64/firefox/libxul.so)
                                       js::Allocate<JSThinInlineString, (js::AllowGC)1> (inlined)
                                       JSThinInlineString::new_<(js::AllowGC)1> (inlined)
                                       AllocateInlineString<(js::AllowGC)1, unsigned char> (inlined)
                                       js::ConcatStrings<(js::AllowGC)1> (/usr/lib64/firefox/libxul.so)
                                       [0x18b26e6bc2bd] (/tmp/perf-17136.map)
  #

Trace the next two sched:sched_switch events, four block:*_plug events, the
next block:*_unplug and the next three net:*dev_queue events, this last one
with a backtrace of at most 16 entries, system wide:

  # perf trace -e sched:*switch/nr=2/,block:*_plug/nr=4/,block:*_unplug/nr=1/,net:*dev_queue/nr=3,max-stack=16/
     0.000 :0/0 sched:sched_switch:swapper/2:0 [120] S ==> rcu_sched:10 [120]
     0.015 rcu_sched/10 sched:sched_switch:rcu_sched:10 [120] R ==> swapper/2:0 [120]
   254.198 irq/50-iwlwifi/680 net:net_dev_queue:dev=wlp3s0 skbaddr=0xffff93498051f600 len=66
                                       __dev_queue_xmit ([kernel.kallsyms])
   273.977 :0/0 net:net_dev_queue:dev=wlp3s0 skbaddr=0xffff93498051f600 len=78
                                       __dev_queue_xmit ([kernel.kallsyms])
   274.007 :0/0 net:net_dev_queue:dev=wlp3s0 skbaddr=0xffff93498051ff00 len=78
                                       __dev_queue_xmit ([kernel.kallsyms])
  2930.140 kworker/u16:58/2722 block:block_plug:[kworker/u16:58]
  2930.162 kworker/u16:58/2722 block:block_unplug:[kworker/u16:58] 1
  4466.094 jbd2/dm-2-8/748 block:block_plug:[jbd2/dm-2-8]
  8050.123 kworker/u16:30/2694 block:block_plug:[kworker/u16:30]
  8050.271 kworker/u16:30/2694 block:block_plug:[kworker/u16:30]
  #

SEE ALSO
--------
linkperf:perf-record[1], linkperf:perf-script[1]

```

## 9. perf-mem.txt - Memory Profiling

```
perf-mem(1)
===========

NAME
----
perf-mem - Profile memory accesses

SYNOPSIS
--------
[verse]
'perf mem' [<options>] (record [<command>] | report)

DESCRIPTION
-----------
"perf mem record" runs a command and gathers memory operation data
from it, into perf.data. Perf record options are accepted and are passed through.

"perf mem report" displays the result. It invokes perf report with the
right set of options to display a memory access profile. By default, loads
and stores are sampled. Use the -t option to limit to loads or stores.

Note that on Intel systems the memory latency reported is the use-latency,
not the pure load (or store latency). Use latency includes any pipeline
queuing delays in addition to the memory subsystem latency.

On Arm64 this uses SPE to sample load and store operations, therefore hardware
and kernel support is required. See linkperf:perf-arm-spe[1] for a setup guide.
Due to the statistical nature of SPE sampling, not every memory operation will
be sampled.

On AMD this use IBS Op PMU to sample load-store operations.

COMMON OPTIONS
--------------
-f::
--force::
	Don't do ownership validation

-t::
--type=<type>::
	Select the memory operation type: load or store (default: load,store)

-v::
--verbose::
	Be more verbose (show counter open errors, etc)

-p::
--phys-data::
	Record/Report sample physical addresses

--data-page-size::
	Record/Report sample data address page size

RECORD OPTIONS
--------------
<command>...::
	Any command you can specify in a shell.

-e::
--event <event>::
	Event selector. Use 'perf mem record -e list' to list available events.

-K::
--all-kernel::
	Configure all used events to run in kernel space.

-U::
--all-user::
	Configure all used events to run in user space.

--ldlat <n>::
	Specify desired latency for loads event. Supported on Intel, Arm64 and
	some AMD processors. Ignored on other archs.

	On supported AMD processors:
	- /sys/bus/event_source/devices/ibs_op/caps/ldlat file contains '1'.
	- Supported latency values are 128 to 2048 (both inclusive).
	- Latency value which is a multiple of 128 incurs a little less profiling
	  overhead compared to other values.
	- Load latency filtering is disabled by default.

REPORT OPTIONS
--------------
-i::
--input=<file>::
	Input file name.

-C::
--cpu=<cpu>::
	Monitor only on the list of CPUs provided. Multiple CPUs can be provided as a
        comma-separated list with no space: 0,1. Ranges of CPUs are specified with -
	like 0-2. Default is to monitor all CPUS.

-D::
--dump-raw-samples::
	Dump the raw decoded samples on the screen in a format that is easy to parse with
	one sample per line.

-s::
--sort=<key>::
	Group result by given key(s) - multiple keys can be specified
	in CSV format.  The keys are specific to memory samples are:
	symbol_daddr, symbol_iaddr, dso_daddr, locked, tlb, mem, snoop,
	dcacheline, phys_daddr, data_page_size, blocked.

	- symbol_daddr: name of data symbol being executed on at the time of sample
	- symbol_iaddr: name of code symbol being executed on at the time of sample
	- dso_daddr: name of library or module containing the data being executed
	             on at the time of the sample
	- locked: whether the bus was locked at the time of the sample
	- tlb: type of tlb access for the data at the time of the sample
	- mem: type of memory access for the data at the time of the sample
	- snoop: type of snoop (if any) for the data at the time of the sample
	- dcacheline: the cacheline the data address is on at the time of the sample
	- phys_daddr: physical address of data being executed on at the time of sample
	- data_page_size: the data page size of data being executed on at the time of sample
	- blocked: reason of blocked load access for the data at the time of the sample

	And the default sort keys are changed to local_weight, mem, sym, dso,
	symbol_daddr, dso_daddr, snoop, tlb, locked, blocked, local_ins_lat.

-F::
--fields=::
	Specify output field - multiple keys can be specified in CSV format.
	Please see linkperf:perf-report[1] for details.

	In addition to the default fields, 'perf mem report' will provide the
	following fields to break down sample periods.

	- op: operation in the sample instruction (load, store, prefetch, ...)
	- cache: location in CPU cache (L1, L2, ...) where the sample hit
	- mem: location in memory or other places the sample hit
	- dtlb: location in Data TLB (L1, L2) where the sample hit
	- snoop: snoop result for the sampled data access

	Please take a look at the OUTPUT FIELD SELECTION section for caveats.

-T::
--type-profile::
	Show data-type profile result instead of code symbols.  This requires
	the debug information and it will change the default sort keys to:
	mem, snoop, tlb, type.

-U::
--hide-unresolved::
	Only display entries resolved to a symbol.

-x::
--field-separator=<separator>::
	Specify the field separator used when dump raw samples (-D option). By default,
	The separator is the space character.

In addition, for report all perf report options are valid, and for record
all perf record options.

OVERHEAD CALCULATION
--------------------
Unlike linkperf:perf-report[1], which calculates overhead from the actual
sample period, perf-mem overhead is calculated using sample weight. E.g.
there are two samples in perf.data file, both with the same sample period,
but one sample with weight 180 and the other with weight 20:

  $ perf script -F period,data_src,weight,ip,sym
  100000    629080842 |OP LOAD|LVL L3 hit|...     20       7e69b93ca524 strcmp
  100000   1a29081042 |OP LOAD|LVL RAM hit|...   180   ffffffff82429168 memcpy

  $ perf report -F overhead,symbol
  50%   [.] strcmp
  50%   [k] memcpy

  $ perf mem report -F overhead,symbol
  90%   [k] memcpy
  10%   [.] strcmp

OUTPUT FIELD SELECTION
----------------------
"perf mem report" adds a number of new output fields specific to data source
information in the sample.  Some of them have the same name with the existing
sort keys ("mem" and "snoop").  So unlike other fields and sort keys, they'll
behave differently when it's used by -F/--fields or -s/--sort.

Using those two as output fields will aggregate samples altogether and show
breakdown.

  $ perf mem report -F mem,snoop
  ...
  # ------ Memory -------  --- Snoop ----
  #     RAM Uncach  Other     HitM  Other
  # .....................  ..............
  #
       3.5%   0.0%  96.5%    25.1%  74.9%

But using the same name for sort keys will aggregate samples for each type
separately.

  $ perf mem report -s mem,snoop
  # Overhead       Samples  Memory access                            Snoop
  # ........  ............  .......................................  ............
  #
      47.99%          1509  L2 hit                                   N/A
      25.08%           338  core, same node Any cache hit            HitM
      10.24%         54374  N/A                                      N/A
       6.77%         35938  L1 hit                                   N/A
       6.39%           101  core, same node Any cache hit            N/A
       3.50%            69  RAM hit                                  N/A
       0.03%           158  LFB/MAB hit                              N/A
       0.00%             2  Uncached hit                             N/A

SEE ALSO
--------
linkperf:perf-record[1], linkperf:perf-report[1], linkperf:perf-arm-spe[1]

```

## 10. perf-c2c.txt - Cache-to-Cache Analysis

```
perf-c2c(1)
===========

NAME
----
perf-c2c - Shared Data C2C/HITM Analyzer.

SYNOPSIS
--------
[verse]
'perf c2c record' [<options>] <command>
'perf c2c record' [<options>] \-- [<record command options>] <command>
'perf c2c report' [<options>]

DESCRIPTION
-----------
C2C stands for Cache To Cache.

The perf c2c tool provides means for Shared Data C2C/HITM analysis. It allows
you to track down the cacheline contentions.

On Intel, the tool is based on load latency and precise store facility events
provided by Intel CPUs. On PowerPC, the tool uses random instruction sampling
with thresholding feature. On AMD, the tool uses IBS op pmu (due to hardware
limitations, perf c2c is not supported on Zen3 cpus). On Arm64 it uses SPE to
sample load and store operations, therefore hardware and kernel support is
required. See linkperf:perf-arm-spe[1] for a setup guide. Due to the
statistical nature of Arm SPE sampling, not every memory operation will be
sampled.

These events provide:
  - memory address of the access
  - type of the access (load and store details)
  - latency (in cycles) of the load access

The c2c tool provide means to record this data and report back access details
for cachelines with highest contention - highest number of HITM accesses.

The basic workflow with this tool follows the standard record/report phase.
User uses the record command to record events data and report command to
display it.


RECORD OPTIONS
--------------
-e::
--event=::
	Select the PMU event. Use 'perf c2c record -e list'
	to list available events.

-v::
--verbose::
	Be more verbose (show counter open errors, etc).

-l::
--ldlat::
	Configure mem-loads latency. Supported on Intel, Arm64 and some AMD
	processors. Ignored on other archs.

	On supported AMD processors:
	- /sys/bus/event_source/devices/ibs_op/caps/ldlat file contains '1'.
	- Supported latency values are 128 to 2048 (both inclusive).
	- Latency value which is a multiple of 128 incurs a little less profiling
	  overhead compared to other values.
	- Load latency filtering is disabled by default.

-k::
--all-kernel::
	Configure all used events to run in kernel space.

-u::
--all-user::
	Configure all used events to run in user space.

REPORT OPTIONS
--------------
-k::
--vmlinux=<file>::
	vmlinux pathname

-v::
--verbose::
	Be more verbose (show counter open errors, etc).

-i::
--input::
	Specify the input file to process.

-N::
--node-info::
	Show extra node info in report (see NODE INFO section)

-c::
--coalesce::
	Specify sorting fields for single cacheline display.
	Following fields are available: tid,pid,iaddr,dso
	(see COALESCE)

-g::
--call-graph::
	Setup callchains parameters.
	Please refer to perf-report man page for details.

--stdio::
	Force the stdio output (see STDIO OUTPUT)

--stats::
	Display only statistic tables and force stdio mode.

--full-symbols::
	Display full length of symbols.

--no-source::
	Do not display Source:Line column.

--show-all::
	Show all captured HITM lines, with no regard to HITM % 0.0005 limit.

-f::
--force::
	Don't do ownership validation.

-d::
--display::
	Switch to HITM type (rmt, lcl) or peer snooping type (peer) to display
	and sort on. Total HITMs (tot) as default, except Arm64 uses peer mode
	as default.

--stitch-lbr::
	Show callgraph with stitched LBRs, which may have more complete
	callgraph. The perf.data file must have been obtained using
	perf c2c record --call-graph lbr.
	Disabled by default. In common cases with call stack overflows,
	it can recreate better call stacks than the default lbr call stack
	output. But this approach is not foolproof. There can be cases
	where it creates incorrect call stacks from incorrect matches.
	The known limitations include exception handing such as
	setjmp/longjmp will have calls/returns not match.

--double-cl::
	Group the detection of shared cacheline events into double cacheline
	granularity. Some architectures have an Adjacent Cacheline Prefetch
	feature, which causes cacheline sharing to behave like the cacheline
	size is doubled.

-M::
--disassembler-style=::
	Set disassembler style for objdump.

--objdump=<path>::
        Path to objdump binary.

C2C RECORD
----------
The perf c2c record command setup options related to HITM cacheline analysis
and calls standard perf record command.

Following perf record options are configured by default:
(check perf record man page for details)

  -W,-d,--phys-data,--sample-cpu

Unless specified otherwise with '-e' option, following events are monitored by
default on Intel:

  cpu/mem-loads,ldlat=30/P
  cpu/mem-stores/P

following on AMD:

  ibs_op//

and following on PowerPC:

  cpu/mem-loads/
  cpu/mem-stores/

User can pass any 'perf record' option behind '--' mark, like (to enable
callchains and system wide monitoring):

  $ perf c2c record -- -g -a

Please check RECORD OPTIONS section for specific c2c record options.

C2C REPORT
----------
The perf c2c report command displays shared data analysis.  It comes in two
display modes: stdio and tui (default).

The report command workflow is following:
  - sort all the data based on the cacheline address
  - store access details for each cacheline
  - sort all cachelines based on user settings
  - display data

In general perf report output consist of 2 basic views:
  1) most expensive cachelines list
  2) offsets details for each cacheline

For each cacheline in the 1) list we display following data:
(Both stdio and TUI modes follow the same fields output)

  Index
  - zero based index to identify the cacheline

  Cacheline
  - cacheline address (hex number)

  Rmt/Lcl Hitm (Display with HITM types)
  - cacheline percentage of all Remote/Local HITM accesses

  Peer Snoop (Display with peer type)
  - cacheline percentage of all peer accesses

  LLC Load Hitm - Total, LclHitm, RmtHitm (For display with HITM types)
  - count of Total/Local/Remote load HITMs

  Load Peer - Total, Local, Remote (For display with peer type)
  - count of Total/Local/Remote load from peer cache or DRAM

  Total records
  - sum of all cachelines accesses

  Total loads
  - sum of all load accesses

  Total stores
  - sum of all store accesses

  Store Reference - L1Hit, L1Miss, N/A
    L1Hit - store accesses that hit L1
    L1Miss - store accesses that missed L1
    N/A - store accesses with memory level is not available

  Core Load Hit - FB, L1, L2
  - count of load hits in FB (Fill Buffer), L1 and L2 cache

  LLC Load Hit - LlcHit, LclHitm
  - count of LLC load accesses, includes LLC hits and LLC HITMs

  RMT Load Hit - RmtHit, RmtHitm
  - count of remote load accesses, includes remote hits and remote HITMs;
    on Arm neoverse cores, RmtHit is used to account remote accesses,
    includes remote DRAM or any upward cache level in remote node

  Load Dram - Lcl, Rmt
  - count of local and remote DRAM accesses

For each offset in the 2) list we display following data:

  HITM - Rmt, Lcl (Display with HITM types)
  - % of Remote/Local HITM accesses for given offset within cacheline

  Peer Snoop - Rmt, Lcl (Display with peer type)
  - % of Remote/Local peer accesses for given offset within cacheline

  Store Refs - L1 Hit, L1 Miss, N/A
  - % of store accesses that hit L1, missed L1 and N/A (no available) memory
    level for given offset within cacheline

  Data address - Offset
  - offset address

  Pid
  - pid of the process responsible for the accesses

  Tid
  - tid of the process responsible for the accesses

  Code address
  - code address responsible for the accesses

  cycles - rmt hitm, lcl hitm, load (Display with HITM types)
    - sum of cycles for given accesses - Remote/Local HITM and generic load

  cycles - rmt peer, lcl peer, load (Display with peer type)
    - sum of cycles for given accesses - Remote/Local peer load and generic load

  cpu cnt
    - number of cpus that participated on the access

  Symbol
    - code symbol related to the 'Code address' value

  Shared Object
    - shared object name related to the 'Code address' value

  Source:Line
    - source information related to the 'Code address' value

  Node
    - nodes participating on the access (see NODE INFO section)

NODE INFO
---------
The 'Node' field displays nodes that accesses given cacheline
offset. Its output comes in 3 flavors:
  - node IDs separated by ','
  - node IDs with stats for each ID, in following format:
      Node{cpus %hitms %stores} (Display with HITM types)
      Node{cpus %peers %stores} (Display with peer type)
  - node IDs with list of affected CPUs in following format:
      Node{cpu list}

User can switch between above flavors with -N option or
use 'n' key to interactively switch in TUI mode.

COALESCE
--------
User can specify how to sort offsets for cacheline.

Following fields are available and governs the final
output fields set for cacheline offsets output:

  tid   - coalesced by process TIDs
  pid   - coalesced by process PIDs
  iaddr - coalesced by code address, following fields are displayed:
             Code address, Code symbol, Shared Object, Source line
  dso   - coalesced by shared object

By default the coalescing is setup with 'pid,iaddr'.

STDIO OUTPUT
------------
The stdio output displays data on standard output.

Following tables are displayed:
  Trace Event Information
  - overall statistics of memory accesses

  Global Shared Cache Line Event Information
  - overall statistics on shared cachelines

  Shared Data Cache Line Table
  - list of most expensive cachelines

  Shared Cache Line Distribution Pareto
  - list of all accessed offsets for each cacheline

TUI OUTPUT
----------
The TUI output provides interactive interface to navigate
through cachelines list and to display offset details.

For details please refer to the help window by pressing '?' key.

CREDITS
-------
Although Don Zickus, Dick Fowles and Joe Mario worked together
to get this implemented, we got lots of early help from Arnaldo
Carvalho de Melo, Stephane Eranian, Jiri Olsa and Andi Kleen.

C2C BLOG
--------
Check Joe's blog on c2c tool for detailed use case explanation:
  https://joemario.github.io/blog/2016/09/01/c2c-blog/

SEE ALSO
--------
linkperf:perf-record[1], linkperf:perf-mem[1], linkperf:perf-arm-spe[1]

```

## 11. perf-lock.txt - Lock Contention

```
perf-lock(1)
============

NAME
----
perf-lock - Analyze lock events

SYNOPSIS
--------
[verse]
'perf lock' {record|report|script|info|contention}

DESCRIPTION
-----------
You can analyze various lock behaviours
and statistics with this 'perf lock' command.

  'perf lock record <command>' records lock events
  between start and end <command>. And this command
  produces the file "perf.data" which contains tracing
  results of lock events.

  'perf lock report' reports statistical data.

  'perf lock script' shows raw lock events.

  'perf lock info' shows metadata like threads or addresses
  of lock instances.

  'perf lock contention' shows contention statistics.

COMMON OPTIONS
--------------

-i::
--input=<file>::
        Input file name. (default: perf.data unless stdin is a fifo)

--output=<file>::
        Output file name for perf lock contention and report.

-v::
--verbose::
        Be more verbose (show symbol address, etc).

-q::
--quiet::
	Do not show any warnings or messages. (Suppress -v)

-D::
--dump-raw-trace::
        Dump raw trace in ASCII.

-f::
--force::
	Don't complain, do it.

--vmlinux=<file>::
        vmlinux pathname

--kallsyms=<file>::
        kallsyms pathname


REPORT OPTIONS
--------------

-k::
--key=<value>::
        Sorting key. Possible values: acquired (default), contended,
	avg_wait, wait_total, wait_max, wait_min.

-F::
--field=<value>::
        Output fields. By default it shows all the fields but users can
	customize that using this.  Possible values: acquired, contended,
	avg_wait, wait_total, wait_max, wait_min.

-c::
--combine-locks::
	Merge lock instances in the same class (based on name).

-t::
--threads::
    The -t option is to show per-thread lock stat like below:

      $ perf lock report -t -F acquired,contended,avg_wait

                    Name   acquired  contended   avg wait (ns)

                    perf     240569          9            5784
                 swapper     106610         19             543
                  :15789      17370          2           14538
            ContainerMgr       8981          6             874
                   sleep       5275          1           11281
         ContainerThread       4416          4             944
         RootPressureThr       3215          5            1215
             rcu_preempt       2954          0               0
            ContainerMgr       2560          0               0
                 unnamed       1873          0               0
         EventManager_De       1845          1             636
         futex-default-S       1609          0               0

-E::
--entries=<value>::
	Display this many entries.


INFO OPTIONS
------------

-t::
--threads::
	dump only the thread list in perf.data

-m::
--map::
	dump only the map of lock instances (address:name table)


CONTENTION OPTIONS
------------------

-k::
--key=<value>::
	Sorting key. Possible values: contended, wait_total (default),
	wait_max, wait_min, avg_wait.

-F::
--field=<value>::
	Output fields. By default it shows all but the wait_min fields
	and users can customize that using this.  Possible values:
	contended, wait_total, wait_max, wait_min, avg_wait.

-t::
--threads::
	Show per-thread lock contention stat

-b::
--use-bpf::
	Use BPF program to collect lock contention stats instead of
	using the input data.

-a::
--all-cpus::
        System-wide collection from all CPUs.

-C::
--cpu=<value>::
	Collect samples only on the list of CPUs provided. Multiple CPUs can be
	provided as a comma-separated list with no space: 0,1. Ranges of CPUs
	are specified with -: 0-2.  Default is to monitor all CPUs.

-p::
--pid=<value>::
	Record events on existing process ID (comma separated list).

--tid=<value>::
        Record events on existing thread ID (comma separated list).

-M::
--map-nr-entries=<value>::
	Maximum number of BPF map entries (default: 16384).
	This will be aligned to a power of 2.

--max-stack=<value>::
	Maximum stack depth when collecting lock contention (default: 8).

--stack-skip=<value>::
	Number of stack depth to skip when finding a lock caller (default: 3).

-E::
--entries=<value>::
	Display this many entries.

-l::
--lock-addr::
	Show lock contention stat by address

-o::
--lock-owner::
	Show lock contention stat by owners. This option can be combined with -t,
	which shows owner's per thread lock stats, or -v, which shows owner's
	stacktrace. Requires --use-bpf.

-Y::
--type-filter=<value>::
	Show lock contention only for given lock types (comma separated list).
	Available values are:
	  semaphore, spinlock, rwlock, rwlock:R, rwlock:W, rwsem, rwsem:R, rwsem:W,
	  rtmutex, rwlock-rt, rwlock-rt:R, rwlock-rt:W, percpu-rwmem, pcpu-sem,
	  pcpu-sem:R, pcpu-sem:W, mutex

	Note that RW-variant of locks have :R and :W suffix.  Names without the
	suffix are shortcuts for the both variants.  Ex) rwsem = rwsem:R + rwsem:W.

-L::
--lock-filter=<value>::
	Show lock contention only for given lock addresses or names (comma separated list).

-S::
--callstack-filter=<value>::
	Show lock contention only if the callstack contains the given string.
	Note that it matches the substring so 'rq' would match both 'raw_spin_rq_lock'
	and 'irq_enter_rcu'.

-x::
--field-separator=<SEP>::
	Show results using a CSV-style output to make it easy to import directly
	into spreadsheets. Columns are separated by the string specified in SEP.

--lock-cgroup::
	Show lock contention stat by cgroup.  Requires --use-bpf.

-G::
--cgroup-filter=<value>::
	Show lock contention only in the given cgroups (comma separated list).

-J::
--inject-delay=<time@function>::
	Add delays to the given lock.  It's added to the contention-end part so
	that the (new) owner of the lock will be delayed.  But by slowing down
	the owner, the waiters will also be delayed as well.  This is working
	only with -b/--use-bpf.

	The 'time' is specified in nsec but it can have a unit suffix.  Available
	units are "ms", "us" and "ns".  Currently it accepts up to 10ms of delays
	for safety reasons.

	Note that it will busy-wait after it gets the lock. Delaying locks can
	have significant consequences including potential kernel crashes.  Please
	use it at your own risk.


SEE ALSO
--------
linkperf:perf[1]

```

## 12. perf-sched.txt - Scheduler Analysis

```
perf-sched(1)
=============

NAME
----
perf-sched - Tool to trace/measure scheduler properties (latencies)

SYNOPSIS
--------
[verse]
'perf sched' {record|latency|map|replay|script|timehist}

DESCRIPTION
-----------
There are several variants of 'perf sched':

  'perf sched record <command>' to record the scheduling events
  of an arbitrary workload.

  'perf sched latency' to report the per task scheduling latencies
  and other scheduling properties of the workload.

   Example usage:
       perf sched record -- sleep 1
       perf sched latency

  -------------------------------------------------------------------------------------------------------------------------------------------
  Task                  |   Runtime ms  |  Count   | Avg delay ms    | Max delay ms    | Max delay start           | Max delay end          |
  -------------------------------------------------------------------------------------------------------------------------------------------
  perf:(2)              |      2.804 ms |       66 | avg:   0.524 ms | max:   1.069 ms | max start: 254752.314960 s | max end: 254752.316029 s
  NetworkManager:1343   |      0.372 ms |       13 | avg:   0.008 ms | max:   0.013 ms | max start: 254751.551153 s | max end: 254751.551166 s
  kworker/1:2-xfs:4649  |      0.012 ms |        1 | avg:   0.008 ms | max:   0.008 ms | max start: 254751.519807 s | max end: 254751.519815 s
  kworker/3:1-xfs:388   |      0.011 ms |        1 | avg:   0.006 ms | max:   0.006 ms | max start: 254751.519809 s | max end: 254751.519815 s
  sleep:147736          |      0.938 ms |        3 | avg:   0.006 ms | max:   0.007 ms | max start: 254751.313817 s | max end: 254751.313824 s

  It shows Runtime(time that a task spent actually running on the CPU),
  Count(number of times a delay was calculated) and delay(time that a
  task was ready to run but was kept waiting).

  Tasks with the same command name are merged and the merge count is
  given within (), However if -p option is used, pid is mentioned.

  'perf sched script' to see a detailed trace of the workload that
   was recorded (aliased to 'perf script' for now).

  'perf sched replay' to simulate the workload that was recorded
  via perf sched record. (this is done by starting up mockup threads
  that mimic the workload based on the events in the trace. These
  threads can then replay the timings (CPU runtime and sleep patterns)
  of the workload as it occurred when it was recorded - and can repeat
  it a number of times, measuring its performance.)

  'perf sched map' to print a textual context-switching outline of
  workload captured via perf sched record.  Columns stand for
  individual CPUs, and the two-letter shortcuts stand for tasks that
  are running on a CPU. A '*' denotes the CPU that had the event, and
  a dot signals an idle CPU.

  'perf sched timehist' provides an analysis of scheduling events.
    
    Example usage:
        perf sched record -- sleep 1
        perf sched timehist
    
   By default it shows the individual schedule events, including the wait
   time (time between sched-out and next sched-in events for the task), the
   task scheduling delay (time between runnable and actually running) and
   run time for the task:
    
                time    cpu  task name             wait time  sch delay   run time
                             [tid/pid]                (msec)     (msec)     (msec)
      -------------- ------  --------------------  ---------  ---------  ---------
        79371.874569 [0011]  gcc[31949]                0.014      0.000      1.148
        79371.874591 [0010]  gcc[31951]                0.000      0.000      0.024
        79371.874603 [0010]  migration/10[59]          3.350      0.004      0.011
        79371.874604 [0011]  <idle>                    1.148      0.000      0.035
        79371.874723 [0005]  <idle>                    0.016      0.000      1.383
        79371.874746 [0005]  gcc[31949]                0.153      0.078      0.022
    ...
    
   Times are in msec.usec.

OPTIONS
-------
-i::
--input=<file>::
        Input file name. (default: perf.data unless stdin is a fifo)

-v::
--verbose::
        Be more verbose. (show symbol address, etc)

-D::
--dump-raw-trace=::
        Display verbose dump of the sched data.

-f::
--force::
	Don't complain, do it.

OPTIONS for 'perf sched latency'
-------------------------------

-C::
--CPU <n>::
        CPU to profile on.

-p::
--pids::
        latency stats per pid instead of per command name.

-s::
--sort <key[,key2...]>::
        sort by key(s): runtime, switch, avg, max
        by default it's sorted by "avg ,max ,switch ,runtime".

OPTIONS for 'perf sched map'
----------------------------

--compact::
	Show only CPUs with activity. Helps visualizing on high core
	count systems.

--cpus::
	Show just entries with activities for the given CPUs.

--color-cpus::
	Highlight the given cpus.

--color-pids::
	Highlight the given pids.

--task-name <task>::
	Map output only for the given task name(s). Separate the
	task names with a comma (without whitespace). The sched-out
	time is printed and is represented by '*-' for the given
	task name(s).
	('-' indicates other tasks while '.' is idle).

--fuzzy-name::
	Given task name(s) can be partially matched (fuzzy matching).

OPTIONS for 'perf sched timehist'
---------------------------------
-k::
--vmlinux=<file>::
    vmlinux pathname

--kallsyms=<file>::
    kallsyms pathname

-g::
--call-graph::
	Display call chains if present (default on).

--max-stack::
	Maximum number of functions to display in backtrace, default 5.

-C=::
--cpu=::
	Only show events for the given CPU(s) (comma separated list).

-p=::
--pid=::
	Only show events for given process ID (comma separated list).

-t=::
--tid=::
	Only show events for given thread ID (comma separated list).

-s::
--summary::
    Show only a summary of scheduling by thread with min, max, and average
    run times (in sec) and relative stddev.

-S::
--with-summary::
    Show all scheduling events followed by a summary by thread with min,
    max, and average run times (in sec) and relative stddev.

--symfs=<directory>::
    Look for files with symbols relative to this directory.

-V::
--cpu-visual::
	Show visual aid for sched switches by CPU: 'i' marks idle time,
	's' are scheduler events.

-w::
--wakeups::
	Show wakeup events.

-M::
--migrations::
	Show migration events.

-n::
--next::
	Show next task.

-I::
--idle-hist::
	Show idle-related events only.

--time::
	Only analyze samples within given time window: <start>,<stop>. Times
	have the format seconds.microseconds. If start is not given (i.e., time
	string is ',x.y') then analysis starts at the beginning of the file. If
	stop time is not given (i.e, time string is 'x.y,') then analysis goes
	to end of file.

--state::
	Show task state when it switched out.

--show-prio::
	Show task priority.

--prio::
	Only show events for given task priority(ies). Multiple priorities can be
	provided as a comma-separated list with no spaces: 0,120. Ranges of
	priorities are specified with -: 120-129. A combination of both can also be
	provided: 0,120-129.

-P::
--pre-migrations::
	Show pre-migration wait time. pre-migration wait time is the time spent
	by a task waiting on a runqueue but not getting the chance to run there
	and is migrated to a different runqueue where it is finally run. This
	time between sched_wakeup and migrate_task is the pre-migration wait
	time.

OPTIONS for 'perf sched replay'
------------------------------

-r::
--repeat <n>::
	repeat the workload n times (0: infinite). Default is 10.

SEE ALSO
--------
linkperf:perf-record[1]

```

## 13. perf-bench.txt - Benchmarks

```
perf-bench(1)
=============

NAME
----
perf-bench - General framework for benchmark suites

SYNOPSIS
--------
[verse]
'perf bench' [<common options>] <subsystem> <suite> [<options>]

DESCRIPTION
-----------
This 'perf bench' command is a general framework for benchmark suites.

COMMON OPTIONS
--------------
-r::
--repeat=::
Specify number of times to repeat the run (default 10).

-f::
--format=::
Specify format style.
Current available format styles are:

'default'::
Default style. This is mainly for human reading.
---------------------
% perf bench sched pipe                      # with no style specified
(executing 1000000 pipe operations between two tasks)
        Total time:5.855 sec
                5.855061 usecs/op
		170792 ops/sec
---------------------

'simple'::
This simple style is friendly for automated
processing by scripts.
---------------------
% perf bench --format=simple sched pipe      # specified simple
5.988
---------------------

SUBSYSTEM
---------

'sched'::
	Scheduler and IPC mechanisms.

'syscall'::
	System call performance (throughput).

'mem'::
	Memory access performance.

'numa'::
	NUMA scheduling and MM benchmarks.

'futex'::
	Futex stressing benchmarks.

'epoll'::
	Eventpoll (epoll) stressing benchmarks.

'internals'::
	Benchmark internal perf functionality.

'uprobe'::
	Benchmark overhead of uprobe + BPF.

'all'::
	All benchmark subsystems.

SUITES FOR 'sched'
~~~~~~~~~~~~~~~~~~
*messaging*::
Suite for evaluating performance of scheduler and IPC mechanisms.
Based on hackbench by Rusty Russell.

Options of *messaging*
^^^^^^^^^^^^^^^^^^^^^^
-p::
--pipe::
Use pipe() instead of socketpair()

-t::
--thread::
Be multi thread instead of multi process

-g::
--group=::
Specify number of groups

-l::
--nr_loops=::
Specify number of loops

Example of *messaging*
^^^^^^^^^^^^^^^^^^^^^^

---------------------
% perf bench sched messaging                 # run with default
options (20 sender and receiver processes per group)
(10 groups == 400 processes run)

      Total time:0.308 sec

% perf bench sched messaging -t -g 20        # be multi-thread, with 20 groups
(20 sender and receiver threads per group)
(20 groups == 800 threads run)

      Total time:0.582 sec
---------------------

*pipe*::
Suite for pipe() system call.
Based on pipe-test-1m.c by Ingo Molnar.

Options of *pipe*
^^^^^^^^^^^^^^^^^
-l::
--loop=::
Specify number of loops.

-G::
--cgroups=::
Names of cgroups for sender and receiver, separated by a comma.
This is useful to check cgroup context switching overhead.
Note that perf doesn't create nor delete the cgroups, so users should
make sure that the cgroups exist and are accessible before use.


Example of *pipe*
^^^^^^^^^^^^^^^^^

---------------------
% perf bench sched pipe
(executing 1000000 pipe operations between two tasks)

        Total time:8.091 sec
                8.091833 usecs/op
                123581 ops/sec

% perf bench sched pipe -l 1000              # loop 1000
(executing 1000 pipe operations between two tasks)

        Total time:0.016 sec
                16.948000 usecs/op
                59004 ops/sec

% perf bench sched pipe -G AAA,BBB
(executing 1000000 pipe operations between cgroups)
# Running 'sched/pipe' benchmark:
# Executed 1000000 pipe operations between two processes

     Total time: 6.886 [sec]

       6.886208 usecs/op
         145217 ops/sec

---------------------

SUITES FOR 'syscall'
~~~~~~~~~~~~~~~~~~
*basic*::
Suite for evaluating performance of core system call throughput (both usecs/op and ops/sec metrics).
This uses a single thread simply doing getppid(2), which is a simple syscall where the result is not
cached by glibc.


SUITES FOR 'mem'
~~~~~~~~~~~~~~~~
*memcpy*::
Suite for evaluating performance of simple memory copy in various ways.

Options of *memcpy*
^^^^^^^^^^^^^^^^^^^
-s::
--size::
Specify size of memory to copy (default: 1MB).
Available units are B, KB, MB, GB and TB (case insensitive).

-p::
--page::
Specify page-size for mapping memory buffers (default: 4KB).
Available values are 4KB, 2MB, 1GB (case insensitive).

-k::
--chunk::
Specify the chunk-size for each invocation. (default: 0, or full-extent)
Available units are B, KB, MB, GB and TB (case insensitive).

-f::
--function::
Specify function to copy (default: default).
Available functions are depend on the architecture.
On x86-64, x86-64-unrolled, x86-64-movsq and x86-64-movsb are supported.

-l::
--nr_loops::
Repeat memcpy invocation this number of times.

-c::
--cycles::
Use perf's cpu-cycles event instead of gettimeofday syscall.

*memset*::
Suite for evaluating performance of simple memory set in various ways.

Options of *memset*
^^^^^^^^^^^^^^^^^^^
-s::
--size::
Specify size of memory to set (default: 1MB).
Available units are B, KB, MB, GB and TB (case insensitive).

-p::
--page::
Specify page-size for mapping memory buffers (default: 4KB).
Available values are 4KB, 2MB, 1GB (case insensitive).

-k::
--chunk::
Specify the chunk-size for each invocation. (default: 0, or full-extent)
Available units are B, KB, MB, GB and TB (case insensitive).

-f::
--function::
Specify function to set (default: default).
Available functions are depend on the architecture.
On x86-64, x86-64-unrolled, x86-64-stosq and x86-64-stosb are supported.

-l::
--nr_loops::
Repeat memset invocation this number of times.

-c::
--cycles::
Use perf's cpu-cycles event instead of gettimeofday syscall.

*mmap*::
Suite for evaluating memory subsystem performance for mmap()'d memory.

Options of *mmap*
^^^^^^^^^^^^^^^^^
-s::
--size::
Specify size of memory to set (default: 1MB).
Available units are B, KB, MB, GB and TB (case insensitive).

-p::
--page::
Specify page-size for mapping memory buffers (default: 4KB).
Available values are 4KB, 2MB, 1GB (case insensitive).

-r::
--randomize::
Specify seed to randomize page access offset (default: 0, or not randomized).

-f::
--function::
Specify function to set (default: all).
Available functions are 'demand' and 'populate', with the first
demand faulting pages in the region and the second using an eager
mapping.

-l::
--nr_loops::
Repeat mmap() invocation this number of times.

-c::
--cycles::
Use perf's cpu-cycles event instead of gettimeofday syscall.

SUITES FOR 'numa'
~~~~~~~~~~~~~~~~~
*mem*::
Suite for evaluating NUMA workloads.

SUITES FOR 'futex'
~~~~~~~~~~~~~~~~~~
*hash*::
Suite for evaluating hash tables.

*wake*::
Suite for evaluating wake calls.

*wake-parallel*::
Suite for evaluating parallel wake calls.

*requeue*::
Suite for evaluating requeue calls.

*lock-pi*::
Suite for evaluating futex lock_pi calls.

SUITES FOR 'epoll'
~~~~~~~~~~~~~~~~~~
*wait*::
Suite for evaluating concurrent epoll_wait calls.

*ctl*::
Suite for evaluating multiple epoll_ctl calls.

SUITES FOR 'internals'
~~~~~~~~~~~~~~~~~~~~~~
*synthesize*::
Suite for evaluating perf's event synthesis performance.

SEE ALSO
--------
linkperf:perf[1]

```

## 14. perf-probe.txt - Dynamic Probes

```
perf-probe(1)
=============

NAME
----
perf-probe - Define new dynamic tracepoints

SYNOPSIS
--------
[verse]
'perf probe' [options] --add='PROBE' [...]
or
'perf probe' [options] PROBE
or
'perf probe' [options] --del='[GROUP:]EVENT' [...]
or
'perf probe' --list[=[GROUP:]EVENT]
or
'perf probe' [options] --line='LINE'
or
'perf probe' [options] --vars='PROBEPOINT'
or
'perf probe' [options] --funcs
or
'perf probe' [options] --definition='PROBE' [...]

DESCRIPTION
-----------
This command defines dynamic tracepoint events, by symbol and registers
without debuginfo, or by C expressions (C line numbers, C function names,
and C local variables) with debuginfo.


OPTIONS
-------
-k::
--vmlinux=PATH::
	Specify vmlinux path which has debuginfo (Dwarf binary).
	Only when using this with --definition, you can give an offline
	vmlinux file.

-m::
--module=MODNAME|PATH::
	Specify module name in which perf-probe searches probe points
	or lines. If a path of module file is passed, perf-probe
	treat it as an offline module (this means you can add a probe on
        a module which has not been loaded yet).

-s::
--source=PATH::
	Specify path to kernel source.

-v::
--verbose::
        Be more verbose (show parsed arguments, etc).
	Can not use with -q.

-q::
--quiet::
	Do not show any warnings or messages.
	Can not use with -v.

-a::
--add=::
	Define a probe event (see PROBE SYNTAX for detail).

-d::
--del=::
	Delete probe events. This accepts glob wildcards('*', '?') and character
	classes(e.g. [a-z], [!A-Z]).

-l::
--list[=[GROUP:]EVENT]::
	List up current probe events. This can also accept filtering patterns of
	event names.
	When this is used with --cache, perf shows all cached probes instead of
	the live probes.

-L::
--line=::
	Show source code lines which can be probed. This needs an argument
	which specifies a range of the source code. (see LINE SYNTAX for detail)

-V::
--vars=::
	Show available local variables at given probe point. The argument
	syntax is same as PROBE SYNTAX, but NO ARGs.

--externs::
	(Only for --vars) Show external defined variables in addition to local
	variables.

--no-inlines::
	(Only for --add) Search only for non-inlined functions. The functions
	which do not have instances are ignored.

-F::
--funcs[=FILTER]::
	Show available functions in given module or kernel. With -x/--exec,
	can also list functions in a user space executable / shared library.
	This also can accept a FILTER rule argument.

-D::
--definition=::
	Show trace-event definition converted from given probe-event instead
	of write it into tracing/[k,u]probe_events.

--filter=FILTER::
	(Only for --vars and --funcs) Set filter. FILTER is a combination of glob
	pattern, see FILTER PATTERN for detail.
	Default FILTER is "!__k???tab_* & !__crc_*" for --vars, and "!_*"
	for --funcs.
	If several filters are specified, only the last filter is used.

-f::
--force::
	Forcibly add events with existing name.

-n::
--dry-run::
	Dry run. With this option, --add and --del doesn't execute actual
	adding and removal operations.

--cache::
	(With --add) Cache the probes. Any events which successfully added
	are also stored in the cache file.
	(With --list) Show cached probes.
	(With --del) Remove cached probes.

--max-probes=NUM::
	Set the maximum number of probe points for an event. Default is 128.

--target-ns=PID:
	Obtain mount namespace information from the target pid.  This is
	used when creating a uprobe for a process that resides in a
	different mount namespace from the perf(1) utility.

-x::
--exec=PATH::
	Specify path to the executable or shared library file for user
	space tracing. Can also be used with --funcs option.

--demangle::
	Demangle application symbols. --no-demangle is also available
	for disabling demangling.

--demangle-kernel::
	Demangle kernel symbols. --no-demangle-kernel is also available
	for disabling kernel demangling.

In absence of -m/-x options, perf probe checks if the first argument after
the options is an absolute path name. If its an absolute path, perf probe
uses it as a target module/target user space binary to probe.

PROBE SYNTAX
------------
Probe points are defined by following syntax.

    1) Define event based on function name
     [[GROUP:]EVENT=]FUNC[@SRC][:RLN|+OFFS|%return|;PTN] [ARG ...]

    2) Define event based on source file with line number
     [[GROUP:]EVENT=]SRC:ALN [ARG ...]

    3) Define event based on source file with lazy pattern
     [[GROUP:]EVENT=]SRC;PTN [ARG ...]

    4) Pre-defined SDT events or cached event with name
     %[sdt_PROVIDER:]SDTEVENT
     or,
     sdt_PROVIDER:SDTEVENT

'EVENT' specifies the name of new event, if omitted, it will be set the name of the probed function, and for return probes, a "\_\_return" suffix is automatically added to the function name. You can also specify a group name by 'GROUP', if omitted, set 'probe' is used for kprobe and 'probe_<bin>' is used for uprobe.
Note that using existing group name can conflict with other events. Especially, using the group name reserved for kernel modules can hide embedded events in the
modules.
'FUNC' specifies a probed function name, and it may have one of the following options; '+OFFS' is the offset from function entry address in bytes, ':RLN' is the relative-line number from function entry line, and '%return' means that it probes function return. And ';PTN' means lazy matching pattern (see LAZY MATCHING). Note that ';PTN' must be the end of the probe point definition.  In addition, '@SRC' specifies a source file which has that function.
It is also possible to specify a probe point by the source line number or lazy matching by using 'SRC:ALN' or 'SRC;PTN' syntax, where 'SRC' is the source file path, ':ALN' is the line number and ';PTN' is the lazy matching pattern.
'ARG' specifies the arguments of this probe point, (see PROBE ARGUMENT).
'SDTEVENT' and 'PROVIDER' is the pre-defined event name which is defined by user SDT (Statically Defined Tracing) or the pre-cached probes with event name.
Note that before using the SDT event, the target binary (on which SDT events are defined) must be scanned by linkperf:perf-buildid-cache[1] to make SDT events as cached events.

For details of the SDT, see below.
https://sourceware.org/gdb/onlinedocs/gdb/Static-Probe-Points.html

ESCAPED CHARACTER
-----------------

In the probe syntax, '=', '@', '+', ':' and ';' are treated as a special character. You can use a backslash ('\') to escape the special characters.
This is useful if you need to probe on a specific versioned symbols, like @GLIBC_... suffixes, or also you need to specify a source file which includes the special characters.
Note that usually single backslash is consumed by shell, so you might need to pass double backslash (\\) or wrapping with single quotes (\'AAA\@BBB').
See EXAMPLES how it is used.

PROBE ARGUMENT
--------------
Each probe argument follows below syntax.

 [NAME=]LOCALVAR|$retval|%REG|@SYMBOL[:TYPE][@user]

'NAME' specifies the name of this argument (optional). You can use the name of local variable, local data structure member (e.g. var->field, var.field2), local array with fixed index (e.g. array[1], var->array[0], var->pointer[2]), or kprobe-tracer argument format (e.g. $retval, %ax, etc). Note that the name of this argument will be set as the last member name if you specify a local data structure member (e.g. field2 for 'var->field1.field2'.)
'$vars' and '$params' special arguments are also available for NAME, '$vars' is expanded to the local variables (including function parameters) which can access at given probe point. '$params' is expanded to only the function parameters.
'TYPE' casts the type of this argument (optional). If omitted, perf probe automatically set the type based on debuginfo (*). Currently, basic types (u8/u16/u32/u64/s8/s16/s32/s64), hexadecimal integers (x/x8/x16/x32/x64), signedness casting (u/s), "string" and bitfield are supported. (see TYPES for detail)
On x86 systems %REG is always the short form of the register: for example %AX. %RAX or %EAX is not valid.
"@user" is a special attribute which means the LOCALVAR will be treated as a user-space memory. This is only valid for kprobe event.

TYPES
-----
Basic types (u8/u16/u32/u64/s8/s16/s32/s64) and hexadecimal integers (x8/x16/x32/x64) are integer types. Prefix 's' and 'u' means those types are signed and unsigned respectively, and 'x' means that is shown in hexadecimal format. Traced arguments are shown in decimal (sNN/uNN) or hex (xNN). You can also use 's' or 'u' to specify only signedness and leave its size auto-detected by perf probe. Moreover, you can use 'x' to explicitly specify to be shown in hexadecimal (the size is also auto-detected).
String type is a special type, which fetches a "null-terminated" string from kernel space. This means it will fail and store NULL if the string container has been paged out. You can specify 'string' type only for the local variable or structure member which is an array of or a pointer to 'char' or 'unsigned char' type.
Bitfield is another special type, which takes 3 parameters, bit-width, bit-offset, and container-size (usually 32). The syntax is;

 b<bit-width>@<bit-offset>/<container-size>

LINE SYNTAX
-----------
Line range is described by following syntax.

 "FUNC[@SRC][:RLN[+NUM|-RLN2]]|SRC[:ALN[+NUM|-ALN2]]"

FUNC specifies the function name of showing lines. 'RLN' is the start line
number from function entry line, and 'RLN2' is the end line number. As same as
probe syntax, 'SRC' means the source file path, 'ALN' is start line number,
and 'ALN2' is end line number in the file. It is also possible to specify how
many lines to show by using 'NUM'. Moreover, 'FUNC@SRC' combination is good
for searching a specific function when several functions share same name.
So, "source.c:100-120" shows lines between 100th to 120th in source.c file. And "func:10+20" shows 20 lines from 10th line of func function.

LAZY MATCHING
-------------
The lazy line matching is similar to glob matching but ignoring spaces in both of pattern and target. So this accepts wildcards('*', '?') and character classes(e.g. [a-z], [!A-Z]).

e.g.
 'a=*' can matches 'a=b', 'a = b', 'a == b' and so on.

This provides some sort of flexibility and robustness to probe point definitions against minor code changes. For example, actual 10th line of schedule() can be moved easily by modifying schedule(), but the same line matching 'rq=cpu_rq*' may still exist in the function.)

FILTER PATTERN
--------------
The filter pattern is a glob matching pattern(s) to filter variables.
In addition, you can use "!" for specifying filter-out rule. You also can give several rules combined with "&" or "|", and fold those rules as one rule by using "(" ")".

e.g.
 With --filter "foo* | bar*", perf probe -V shows variables which start with "foo" or "bar".
 With --filter "!foo* & *bar", perf probe -V shows variables which don't start with "foo" and end with "bar", like "fizzbar". But "foobar" is filtered out.

EXAMPLES
--------
Display which lines in schedule() can be probed:

 ./perf probe --line schedule

Add a probe on schedule() function 12th line with recording cpu local variable:

 ./perf probe schedule:12 cpu
 or
 ./perf probe --add='schedule:12 cpu'

Add one or more probes which has the name start with "schedule".

 ./perf probe schedule*
 or
 ./perf probe --add='schedule*'

Add probes on lines in schedule() function which calls update_rq_clock().

 ./perf probe 'schedule;update_rq_clock*'
 or
 ./perf probe --add='schedule;update_rq_clock*'

Delete all probes on schedule().

 ./perf probe --del='schedule*'

Add probes at zfree() function on /bin/zsh

 ./perf probe -x /bin/zsh zfree or ./perf probe /bin/zsh zfree

Add probes at malloc() function on libc

 ./perf probe -x /lib/libc.so.6 malloc or ./perf probe /lib/libc.so.6 malloc

Add a uprobe to a target process running in a different mount namespace

 ./perf probe --target-ns <target pid> -x /lib64/libc.so.6 malloc

Add a USDT probe to a target process running in a different mount namespace

 ./perf probe --target-ns <target pid> -x /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.121-0.b13.el7_3.x86_64/jre/lib/amd64/server/libjvm.so %sdt_hotspot:thread__sleep__end

Add a probe on specific versioned symbol by backslash escape

 ./perf probe -x /lib64/libc-2.25.so 'malloc_get_state\@GLIBC_2.2.5'

Add a probe in a source file using special characters by backslash escape

 ./perf probe -x /opt/test/a.out 'foo\+bar.c:4'


PERMISSIONS AND SYSCTL
----------------------
Since perf probe depends on ftrace (tracefs) and kallsyms (/proc/kallsyms), you have to care about the permission and some sysctl knobs.

 - Since tracefs and kallsyms requires root or privileged user to access it, the following perf probe commands also require it; --add, --del, --list (except for --cache option)

 - The system admin can remount the tracefs with 755 (`sudo mount -o remount,mode=755 /sys/kernel/tracing/`) to allow unprivileged user to run the perf probe --list command.

 - /proc/sys/kernel/kptr_restrict = 2 (restrict all users) also prevents perf probe to retrieve the important information from kallsyms. You also need to set to 1 (restrict non CAP_SYSLOG users) for the above commands. Since the user-space probe doesn't need to access kallsyms, this is only for probing the kernel function (kprobes).

 - Since the perf probe commands read the vmlinux (for kernel) and/or the debuginfo file (including user-space application), you need to ensure that you can read those files.


SEE ALSO
--------
linkperf:perf-trace[1], linkperf:perf-record[1], linkperf:perf-buildid-cache[1]

```

## 15. perf-ftrace.txt - Ftrace Integration

```
perf-ftrace(1)
==============

NAME
----
perf-ftrace - simple wrapper for kernel's ftrace functionality


SYNOPSIS
--------
[verse]
'perf ftrace' {trace|latency|profile} <command>

DESCRIPTION
-----------
The 'perf ftrace' command provides a collection of subcommands which use
kernel's ftrace infrastructure.

  'perf ftrace trace' is a simple wrapper of the ftrace.  It only supports
  single thread tracing currently and just reads trace_pipe in text and then
  write it to stdout.

  'perf ftrace latency' calculates execution latency of a given function
  (optionally with BPF) and display it as a histogram.

  'perf ftrace profile' show a execution profile for each function including
  total, average, max time and the number of calls.

The following options apply to perf ftrace.

COMMON OPTIONS
--------------

-p::
--pid=::
	Trace on existing process id (comma separated list).

--tid=::
	Trace on existing thread id (comma separated list).

-a::
--all-cpus::
	Force system-wide collection.  Scripts run without a <command>
	normally use -a by default, while scripts run with a <command>
	normally don't - this option allows the latter to be run in
	system-wide mode.

-C::
--cpu=::
	Only trace for the list of CPUs provided.  Multiple CPUs can
	be provided as a comma separated list with no space like: 0,1.
	Ranges of CPUs are specified with -: 0-2.
	Default is to trace on all online CPUs.

-v::
--verbose::
        Increase the verbosity level.


OPTIONS for 'perf ftrace trace'
-------------------------------

-t::
--tracer=::
	Tracer to use when neither -G nor -F option is not
	specified: function_graph or function.

-F::
--funcs::
        List available functions to trace. It accepts a pattern to
        only list interested functions.

-D::
--delay::
	Time (ms) to wait before starting tracing after program start.

-m::
--buffer-size::
	Set the size of per-cpu tracing buffer, <size> is expected to
	be a number with appended unit character - B/K/M/G.

--inherit::
	Trace children processes spawned by our target.

-T::
--trace-funcs=::
	Select function tracer and set function filter on the given
	function (or a glob pattern). Multiple functions can be given
	by using this option more than once. The function argument also
	can be a glob pattern. It will be passed to 'set_ftrace_filter'
	in tracefs.

-N::
--notrace-funcs=::
	Select function tracer and do not trace functions given by the
	argument.  Like -T option, this can be used more than once to
	specify multiple functions (or glob patterns).  It will be
	passed to 'set_ftrace_notrace' in tracefs.

--func-opts::
	List of options allowed to set:

	  - call-graph - Display kernel stack trace for function tracer.
	  - irq-info   - Display irq context info for function tracer.

-G::
--graph-funcs=::
	Select function_graph tracer and set graph filter on the given
	function (or a glob pattern). This is useful to trace for
	functions executed from the given function. This can be used more
	than once to specify multiple functions. It will be passed to
	'set_graph_function' in tracefs.

-g::
--nograph-funcs=::
	Select function_graph tracer and set graph notrace filter on the
	given function (or a glob pattern). Like -G option, this is useful
	for the function_graph tracer only and disables tracing for function
	executed from the given function. This can be used more than once to
	specify multiple functions. It will be passed to 'set_graph_notrace'
	in tracefs.

--graph-opts::
	List of options allowed to set:

	  - args         - Show function arguments.
	  - retval       - Show function return value.
	  - retval-hex   - Show function return value in hexadecimal format.
	  - retaddr      - Show function return address.
	  - nosleep-time - Measure on-CPU time only for function_graph tracer.
	  - noirqs       - Ignore functions that happen inside interrupt.
	  - verbose      - Show process names, PIDs, timestamps, etc.
	  - thresh=<n>   - Setup trace duration threshold in microseconds.
	  - depth=<n>    - Set max depth for function graph tracer to follow.
	  - tail         - Print function name at the end.


OPTIONS for 'perf ftrace latency'
---------------------------------

-T::
--trace-funcs=::
	Set the function name to get the histogram.  Unlike perf ftrace trace,
	it only allows single function to calculate the histogram.

-e::
--events=::
	Set the pair of events to get the histogram.  The histogram is calculated
	by the time difference between the two events from the same thread.  This
	requires -b/--use-bpf option.

-b::
--use-bpf::
	Use BPF to measure function latency instead of using the ftrace (it
	uses function_graph tracer internally).

-n::
--use-nsec::
	Use nano-second instead of micro-second as a base unit of the histogram.

--bucket-range=::
	Bucket range in ms or ns (according to -n/--use-nsec), default is log2() mode.

--min-latency=::
	Minimum latency for the start of the first bucket, in ms or ns (according to
	-n/--use-nsec).

--max-latency=::
	Maximum latency for the start of the last bucket, in ms or ns (according to
	-n/--use-nsec). The setting is ignored if the value results in more than
	22 buckets.

OPTIONS for 'perf ftrace profile'
---------------------------------

-T::
--trace-funcs=::
	Set function filter on the given function (or a glob pattern).
	Multiple functions can be given by using this option more than once.
	The function argument also can be a glob pattern. It will be passed
	to 'set_ftrace_filter' in tracefs.

-N::
--notrace-funcs=::
	Do not trace functions given by the argument.  Like -T option, this
	can be used more than once to specify multiple functions (or glob
	patterns).  It will be passed to 'set_ftrace_notrace' in tracefs.

-G::
--graph-funcs=::
	Set graph filter on the given function (or a glob pattern). This is
	useful to trace for functions executed from the given function. This
	can be used more than once to specify multiple functions. It will be
	passed to 'set_graph_function' in tracefs.

-g::
--nograph-funcs=::
	Set graph notrace filter on the given function (or a glob pattern).
	Like -G option, this is useful for the function_graph tracer only and
	disables tracing for function executed from the given function. This
	can be used more than once to specify multiple functions. It will be
	passed to 'set_graph_notrace' in tracefs.

-m::
--buffer-size::
	Set the size of per-cpu tracing buffer, <size> is expected to
	be a number with appended unit character - B/K/M/G.

-s::
--sort=::
	Sort the result by the given field.  Available values are:
	total, avg, max, count, name.  Default is 'total'.

--graph-opts::
	List of options allowed to set:

	  - nosleep-time - Measure on-CPU time only for function_graph tracer.
	  - noirqs       - Ignore functions that happen inside interrupt.
	  - thresh=<n>   - Setup trace duration threshold in microseconds.
	  - depth=<n>    - Set max depth for function graph tracer to follow.


SEE ALSO
--------
linkperf:perf-record[1], linkperf:perf-trace[1]

```

## 16. topdown.txt - Top-Down Analysis Methodology

```
Using TopDown metrics
---------------------

TopDown metrics break apart performance bottlenecks. Starting at level
1 it is typical to get metrics on retiring, bad speculation, frontend
bound, and backend bound. Higher levels provide more detail in to the
level 1 bottlenecks, such as at level 2: core bound, memory bound,
heavy operations, light operations, branch mispredicts, machine
clears, fetch latency and fetch bandwidth. For more details see [1][2][3].

perf stat --topdown implements this using available metrics that vary
per architecture.

% perf stat -a --topdown -I1000
#           time      %  tma_retiring %  tma_backend_bound %  tma_frontend_bound %  tma_bad_speculation
     1.001141351                 11.5                 34.9                  46.9                    6.7
     2.006141972                 13.4                 28.1                  50.4                    8.1
     3.010162040                 12.9                 28.1                  51.1                    8.0
     4.014009311                 12.5                 28.6                  51.8                    7.2
     5.017838554                 11.8                 33.0                  48.0                    7.2
     5.704818971                 14.0                 27.5                  51.3                    7.3
...

New Topdown features in Intel Ice Lake
======================================

With Ice Lake CPUs the TopDown metrics are directly available as
fixed counters and do not require generic counters. This allows
to collect TopDown always in addition to other events.

Using TopDown through RDPMC in applications on Intel Ice Lake
=============================================================

For more fine grained measurements it can be useful to
access the new  directly from user space. This is more complicated,
but drastically lowers overhead.

On Ice Lake, there is a new fixed counter 3: SLOTS, which reports
"pipeline SLOTS" (cycles multiplied by core issue width) and a
metric register that reports slots ratios for the different bottleneck
categories.

The metrics counter is CPU model specific and is not available on older
CPUs.

Example code
============

Library functions to do the functionality described below
is also available in libjevents [4]

The application opens a group with fixed counter 3 (SLOTS) and any
metric event, and allow user programs to read the performance counters.

Fixed counter 3 is mapped to a pseudo event event=0x00, umask=04,
so the perf_event_attr structure should be initialized with
{ .config = 0x0400, .type = PERF_TYPE_RAW }
The metric events are mapped to the pseudo event event=0x00, umask=0x8X.
For example, the perf_event_attr structure can be initialized with
{ .config = 0x8000, .type = PERF_TYPE_RAW } for Retiring metric event
The Fixed counter 3 must be the leader of the group.

#include <linux/perf_event.h>
#include <sys/mman.h>
#include <sys/syscall.h>
#include <unistd.h>

/* Provide own perf_event_open stub because glibc doesn't */
__attribute__((weak))
int perf_event_open(struct perf_event_attr *attr, pid_t pid,
		    int cpu, int group_fd, unsigned long flags)
{
	return syscall(__NR_perf_event_open, attr, pid, cpu, group_fd, flags);
}

/* Open slots counter file descriptor for current task. */
struct perf_event_attr slots = {
	.type = PERF_TYPE_RAW,
	.size = sizeof(struct perf_event_attr),
	.config = 0x400,
	.exclude_kernel = 1,
};

int slots_fd = perf_event_open(&slots, 0, -1, -1, 0);
if (slots_fd < 0)
	... error ...

/* Memory mapping the fd permits _rdpmc calls from userspace */
void *slots_p = mmap(0, getpagesize(), PROT_READ, MAP_SHARED, slots_fd, 0);
if (!slot_p)
	.... error ...

/*
 * Open metrics event file descriptor for current task.
 * Set slots event as the leader of the group.
 */
struct perf_event_attr metrics = {
	.type = PERF_TYPE_RAW,
	.size = sizeof(struct perf_event_attr),
	.config = 0x8000,
	.exclude_kernel = 1,
};

int metrics_fd = perf_event_open(&metrics, 0, -1, slots_fd, 0);
if (metrics_fd < 0)
	... error ...

/* Memory mapping the fd permits _rdpmc calls from userspace */
void *metrics_p = mmap(0, getpagesize(), PROT_READ, MAP_SHARED, metrics_fd, 0);
if (!metrics_p)
	... error ...

Note: the file descriptors returned by the perf_event_open calls must be memory
mapped to permit calls to the _rdpmd instruction. Permission may also be granted
by writing the /sys/devices/cpu/rdpmc sysfs node.

The RDPMC instruction (or _rdpmc compiler intrinsic) can now be used
to read slots and the topdown metrics at different points of the program:

#include <stdint.h>
#include <x86intrin.h>

#define RDPMC_FIXED	(1 << 30)	/* return fixed counters */
#define RDPMC_METRIC	(1 << 29)	/* return metric counters */

#define FIXED_COUNTER_SLOTS		3
#define METRIC_COUNTER_TOPDOWN_L1_L2	0

static inline uint64_t read_slots(void)
{
	return _rdpmc(RDPMC_FIXED | FIXED_COUNTER_SLOTS);
}

static inline uint64_t read_metrics(void)
{
	return _rdpmc(RDPMC_METRIC | METRIC_COUNTER_TOPDOWN_L1_L2);
}

Then the program can be instrumented to read these metrics at different
points.

It's not a good idea to do this with too short code regions,
as the parallelism and overlap in the CPU program execution will
cause too much measurement inaccuracy. For example instrumenting
individual basic blocks is definitely too fine grained.

_rdpmc calls should not be mixed with reading the metrics and slots counters
through system calls, as the kernel will reset these counters after each system
call.

Decoding metrics values
=======================

The value reported by read_metrics() contains four 8 bit fields
that represent a scaled ratio that represent the Level 1 bottleneck.
All four fields add up to 0xff (= 100%)

The binary ratios in the metric value can be converted to float ratios:

#define GET_METRIC(m, i) (((m) >> (i*8)) & 0xff)

/* L1 Topdown metric events */
#define TOPDOWN_RETIRING(val)	((float)GET_METRIC(val, 0) / 0xff)
#define TOPDOWN_BAD_SPEC(val)	((float)GET_METRIC(val, 1) / 0xff)
#define TOPDOWN_FE_BOUND(val)	((float)GET_METRIC(val, 2) / 0xff)
#define TOPDOWN_BE_BOUND(val)	((float)GET_METRIC(val, 3) / 0xff)

/*
 * L2 Topdown metric events.
 * Available on Sapphire Rapids and later platforms.
 */
#define TOPDOWN_HEAVY_OPS(val)		((float)GET_METRIC(val, 4) / 0xff)
#define TOPDOWN_BR_MISPREDICT(val)	((float)GET_METRIC(val, 5) / 0xff)
#define TOPDOWN_FETCH_LAT(val)		((float)GET_METRIC(val, 6) / 0xff)
#define TOPDOWN_MEM_BOUND(val)		((float)GET_METRIC(val, 7) / 0xff)

and then converted to percent for printing.

The ratios in the metric accumulate for the time when the counter
is enabled. For measuring programs it is often useful to measure
specific sections. For this it is needed to deltas on metrics.

This can be done by scaling the metrics with the slots counter
read at the same time.

Then it's possible to take deltas of these slots counts
measured at different points, and determine the metrics
for that time period.

	slots_a = read_slots();
	metric_a = read_metrics();

	... larger code region ...

	slots_b = read_slots()
	metric_b = read_metrics()

	# compute scaled metrics for measurement a
	retiring_slots_a = GET_METRIC(metric_a, 0) * slots_a
	bad_spec_slots_a = GET_METRIC(metric_a, 1) * slots_a
	fe_bound_slots_a = GET_METRIC(metric_a, 2) * slots_a
	be_bound_slots_a = GET_METRIC(metric_a, 3) * slots_a

	# compute delta scaled metrics between b and a
	retiring_slots = GET_METRIC(metric_b, 0) * slots_b - retiring_slots_a
	bad_spec_slots = GET_METRIC(metric_b, 1) * slots_b - bad_spec_slots_a
	fe_bound_slots = GET_METRIC(metric_b, 2) * slots_b - fe_bound_slots_a
	be_bound_slots = GET_METRIC(metric_b, 3) * slots_b - be_bound_slots_a

Later the individual ratios of L1 metric events for the measurement period can
be recreated from these counts.

	slots_delta = slots_b - slots_a
	retiring_ratio = (float)retiring_slots / slots_delta
	bad_spec_ratio = (float)bad_spec_slots / slots_delta
	fe_bound_ratio = (float)fe_bound_slots / slots_delta
	be_bound_ratio = (float)be_bound_slots / slota_delta

	printf("Retiring %.2f%% Bad Speculation %.2f%% FE Bound %.2f%% BE Bound %.2f%%\n",
		retiring_ratio * 100.,
		bad_spec_ratio * 100.,
		fe_bound_ratio * 100.,
		be_bound_ratio * 100.);

The individual ratios of L2 metric events for the measurement period can be
recreated from L1 and L2 metric counters. (Available on Sapphire Rapids and
later platforms)

	# compute scaled metrics for measurement a
	heavy_ops_slots_a = GET_METRIC(metric_a, 4) * slots_a
	br_mispredict_slots_a = GET_METRIC(metric_a, 5) * slots_a
	fetch_lat_slots_a = GET_METRIC(metric_a, 6) * slots_a
	mem_bound_slots_a = GET_METRIC(metric_a, 7) * slots_a

	# compute delta scaled metrics between b and a
	heavy_ops_slots = GET_METRIC(metric_b, 4) * slots_b - heavy_ops_slots_a
	br_mispredict_slots = GET_METRIC(metric_b, 5) * slots_b - br_mispredict_slots_a
	fetch_lat_slots = GET_METRIC(metric_b, 6) * slots_b - fetch_lat_slots_a
	mem_bound_slots = GET_METRIC(metric_b, 7) * slots_b - mem_bound_slots_a

	slots_delta = slots_b - slots_a
	heavy_ops_ratio = (float)heavy_ops_slots / slots_delta
	light_ops_ratio = retiring_ratio - heavy_ops_ratio;

	br_mispredict_ratio = (float)br_mispredict_slots / slots_delta
	machine_clears_ratio = bad_spec_ratio - br_mispredict_ratio;

	fetch_lat_ratio = (float)fetch_lat_slots / slots_delta
	fetch_bw_ratio = fe_bound_ratio - fetch_lat_ratio;

	mem_bound_ratio = (float)mem_bound_slots / slota_delta
	core_bound_ratio = be_bound_ratio - mem_bound_ratio;

	printf("Heavy Operations %.2f%% Light Operations %.2f%% "
	       "Branch Mispredict %.2f%% Machine Clears %.2f%% "
	       "Fetch Latency %.2f%% Fetch Bandwidth %.2f%% "
	       "Mem Bound %.2f%% Core Bound %.2f%%\n",
		heavy_ops_ratio * 100.,
		light_ops_ratio * 100.,
		br_mispredict_ratio * 100.,
		machine_clears_ratio * 100.,
		fetch_lat_ratio * 100.,
		fetch_bw_ratio * 100.,
		mem_bound_ratio * 100.,
		core_bound_ratio * 100.);

Resetting metrics counters
==========================

Since the individual metrics are only 8bit they lose precision for
short regions over time because the number of cycles covered by each
fraction bit shrinks. So the counters need to be reset regularly.

When using the kernel perf API the kernel resets on every read.
So as long as the reading is at reasonable intervals (every few
seconds) the precision is good.

When using perf stat it is recommended to always use the -I option,
with no longer interval than a few seconds

	perf stat -I 1000 --topdown ...

For user programs using RDPMC directly the counter can
be reset explicitly using ioctl:

	ioctl(perf_fd, PERF_EVENT_IOC_RESET, 0);

This "opens" a new measurement period.

A program using RDPMC for TopDown should schedule such a reset
regularly, as in every few seconds.

Limits on Intel Ice Lake
========================

Four pseudo TopDown metric events are exposed for the end-users,
topdown-retiring, topdown-bad-spec, topdown-fe-bound and topdown-be-bound.
They can be used to collect the TopDown value under the following
rules:
- All the TopDown metric events must be in a group with the SLOTS event.
- The SLOTS event must be the leader of the group.
- The PERF_FORMAT_GROUP flag must be applied for each TopDown metric
  events

The SLOTS event and the TopDown metric events can be counting members of
a sampling read group. Since the SLOTS event must be the leader of a TopDown
group, the second event of the group is the sampling event.
For example, perf record -e '{slots, $sampling_event, topdown-retiring}:S'

Extension on Intel Sapphire Rapids Server
=========================================
The metrics counter is extended to support TMA method level 2 metrics.
The lower half of the register is the TMA level 1 metrics (legacy).
The upper half is also divided into four 8-bit fields for the new level 2
metrics. Four more TopDown metric events are exposed for the end-users,
topdown-heavy-ops, topdown-br-mispredict, topdown-fetch-lat and
topdown-mem-bound.

Each of the new level 2 metrics in the upper half is a subset of the
corresponding level 1 metric in the lower half. Software can deduce the
other four level 2 metrics by subtracting corresponding metrics as below.

    Light_Operations = Retiring - Heavy_Operations
    Machine_Clears = Bad_Speculation - Branch_Mispredicts
    Fetch_Bandwidth = Frontend_Bound - Fetch_Latency
    Core_Bound = Backend_Bound - Memory_Bound

TPEBS in TopDown
================

TPEBS (Timed PEBS) is one of the new Intel PMU features provided since Granite
Rapids microarchitecture. The TPEBS feature adds a 16 bit retire_latency field
in the Basic Info group of the PEBS record. It records the Core cycles since the
retirement of the previous instruction to the retirement of current instruction.
Please refer to Section 8.4.1 of "Intel® Architecture Instruction Set Extensions
Programming Reference" for more details about this feature. Because this feature
extends PEBS record, sampling with weight option is required to get the
retire_latency value.

	perf record -e event_name -W ...

In the most recent release of TMA, the metrics begin to use event retire_latency
values in some of the metrics’ formulas on processors that support TPEBS feature.
For previous generations that do not support TPEBS, the values are static and
predefined per processor family by the hardware architects. Due to the diversity
of workloads in execution environments, retire_latency values measured at real
time are more accurate. Therefore, new TMA metrics that use TPEBS will provide
more accurate performance analysis results.

To support TPEBS in TMA metrics, a new modifier :R on event is added. Perf would
capture retire_latency value of required events(event with :R in metric formula)
with perf record. The retire_latency value would be used in metric calculation.
Currently, this feature is supported through perf stat

	perf stat -M metric_name --record-tpebs ...



[1] https://software.intel.com/en-us/top-down-microarchitecture-analysis-method-win
[2] https://sites.google.com/site/analysismethods/yasin-pubs
[3] https://perf.wiki.kernel.org/index.php/Top-Down_Analysis
[4] https://github.com/andikleen/pmu-tools/tree/master/jevents

```

## 17. examples.txt - Usage Examples

```

		------------------------------
		****** perf by examples ******
		------------------------------

[ From an e-mail by Ingo Molnar, https://lore.kernel.org/lkml/20090804195717.GA5998@elte.hu ]


First, discovery/enumeration of available counters can be done via
'perf list':

titan:~> perf list
  [...]
  kmem:kmalloc                             [Tracepoint event]
  kmem:kmem_cache_alloc                    [Tracepoint event]
  kmem:kmalloc_node                        [Tracepoint event]
  kmem:kmem_cache_alloc_node               [Tracepoint event]
  kmem:kfree                               [Tracepoint event]
  kmem:kmem_cache_free                     [Tracepoint event]
  kmem:mm_page_free                        [Tracepoint event]
  kmem:mm_page_free_batched                [Tracepoint event]
  kmem:mm_page_alloc                       [Tracepoint event]
  kmem:mm_page_alloc_zone_locked           [Tracepoint event]
  kmem:mm_page_pcpu_drain                  [Tracepoint event]
  kmem:mm_page_alloc_extfrag               [Tracepoint event]

Then any (or all) of the above event sources can be activated and
measured. For example the page alloc/free properties of a 'hackbench
run' are:

 titan:~> perf stat -e kmem:mm_page_pcpu_drain -e kmem:mm_page_alloc
 -e kmem:mm_page_free_batched -e kmem:mm_page_free ./hackbench 10
 Time: 0.575

 Performance counter stats for './hackbench 10':

          13857  kmem:mm_page_pcpu_drain
          27576  kmem:mm_page_alloc
           6025  kmem:mm_page_free_batched
          20934  kmem:mm_page_free

    0.613972165  seconds time elapsed

You can observe the statistical properties as well, by using the
'repeat the workload N times' feature of perf stat:

 titan:~> perf stat --repeat 5 -e kmem:mm_page_pcpu_drain -e
   kmem:mm_page_alloc -e kmem:mm_page_free_batched -e
   kmem:mm_page_free ./hackbench 10
 Time: 0.627
 Time: 0.644
 Time: 0.564
 Time: 0.559
 Time: 0.626

 Performance counter stats for './hackbench 10' (5 runs):

          12920  kmem:mm_page_pcpu_drain    ( +-   3.359% )
          25035  kmem:mm_page_alloc         ( +-   3.783% )
           6104  kmem:mm_page_free_batched  ( +-   0.934% )
          18376  kmem:mm_page_free	    ( +-   4.941% )

    0.643954516  seconds time elapsed   ( +-   2.363% )

Furthermore, these tracepoints can be used to sample the workload as
well. For example the page allocations done by a 'git gc' can be
captured the following way:

 titan:~/git> perf record -e kmem:mm_page_alloc -c 1 ./git gc
 Counting objects: 1148, done.
 Delta compression using up to 2 threads.
 Compressing objects: 100% (450/450), done.
 Writing objects: 100% (1148/1148), done.
 Total 1148 (delta 690), reused 1148 (delta 690)
 [ perf record: Captured and wrote 0.267 MB perf.data (~11679 samples) ]

To check which functions generated page allocations:

 titan:~/git> perf report
 # Samples: 10646
 #
 # Overhead          Command               Shared Object
 # ........  ...............  ..........................
 #
    23.57%       git-repack  /lib64/libc-2.5.so
    21.81%              git  /lib64/libc-2.5.so
    14.59%              git  ./git
    11.79%       git-repack  ./git
     7.12%              git  /lib64/ld-2.5.so
     3.16%       git-repack  /lib64/libpthread-2.5.so
     2.09%       git-repack  /bin/bash
     1.97%               rm  /lib64/libc-2.5.so
     1.39%               mv  /lib64/ld-2.5.so
     1.37%               mv  /lib64/libc-2.5.so
     1.12%       git-repack  /lib64/ld-2.5.so
     0.95%               rm  /lib64/ld-2.5.so
     0.90%  git-update-serv  /lib64/libc-2.5.so
     0.73%  git-update-serv  /lib64/ld-2.5.so
     0.68%             perf  /lib64/libpthread-2.5.so
     0.64%       git-repack  /usr/lib64/libz.so.1.2.3

Or to see it on a more finegrained level:

titan:~/git> perf report --sort comm,dso,symbol
# Samples: 10646
#
# Overhead          Command               Shared Object  Symbol
# ........  ...............  ..........................  ......
#
     9.35%       git-repack  ./git                       [.] insert_obj_hash
     9.12%              git  ./git                       [.] insert_obj_hash
     7.31%              git  /lib64/libc-2.5.so          [.] memcpy
     6.34%       git-repack  /lib64/libc-2.5.so          [.] _int_malloc
     6.24%       git-repack  /lib64/libc-2.5.so          [.] memcpy
     5.82%       git-repack  /lib64/libc-2.5.so          [.] __GI___fork
     5.47%              git  /lib64/libc-2.5.so          [.] _int_malloc
     2.99%              git  /lib64/libc-2.5.so          [.] memset

Furthermore, call-graph sampling can be done too, of page
allocations - to see precisely what kind of page allocations there
are:

 titan:~/git> perf record -g -e kmem:mm_page_alloc -c 1 ./git gc
 Counting objects: 1148, done.
 Delta compression using up to 2 threads.
 Compressing objects: 100% (450/450), done.
 Writing objects: 100% (1148/1148), done.
 Total 1148 (delta 690), reused 1148 (delta 690)
 [ perf record: Captured and wrote 0.963 MB perf.data (~42069 samples) ]

 titan:~/git> perf report -g
 # Samples: 10686
 #
 # Overhead          Command               Shared Object
 # ........  ...............  ..........................
 #
    23.25%       git-repack  /lib64/libc-2.5.so
                |
                |--50.00%-- _int_free
                |
                |--37.50%-- __GI___fork
                |          make_child
                |
                |--12.50%-- ptmalloc_unlock_all2
                |          make_child
                |
                 --6.25%-- __GI_strcpy
    21.61%              git  /lib64/libc-2.5.so
                |
                |--30.00%-- __GI_read
                |          |
                |           --83.33%-- git_config_from_file
                |                     git_config
                |                     |
   [...]

Or you can observe the whole system's page allocations for 10
seconds:

titan:~/git> perf stat -a -e kmem:mm_page_pcpu_drain -e
kmem:mm_page_alloc -e kmem:mm_page_free_batched -e
kmem:mm_page_free sleep 10

 Performance counter stats for 'sleep 10':

         171585  kmem:mm_page_pcpu_drain
         322114  kmem:mm_page_alloc
          73623  kmem:mm_page_free_batched
         254115  kmem:mm_page_free

   10.000591410  seconds time elapsed

Or observe how fluctuating the page allocations are, via statistical
analysis done over ten 1-second intervals:

 titan:~/git> perf stat --repeat 10 -a -e kmem:mm_page_pcpu_drain -e
   kmem:mm_page_alloc -e kmem:mm_page_free_batched -e
   kmem:mm_page_free sleep 1

 Performance counter stats for 'sleep 1' (10 runs):

          17254  kmem:mm_page_pcpu_drain    ( +-   3.709% )
          34394  kmem:mm_page_alloc         ( +-   4.617% )
           7509  kmem:mm_page_free_batched  ( +-   4.820% )
          25653  kmem:mm_page_free	    ( +-   3.672% )

    1.058135029  seconds time elapsed   ( +-   3.089% )

Or you can annotate the recorded 'git gc' run on a per symbol basis
and check which instructions/source-code generated page allocations:

 titan:~/git> perf annotate __GI___fork
 ------------------------------------------------
  Percent |      Source code & Disassembly of libc-2.5.so
 ------------------------------------------------
          :
          :
          :      Disassembly of section .plt:
          :      Disassembly of section .text:
          :
          :      00000031a2e95560 <__fork>:
 [...]
     0.00 :        31a2e95602:   b8 38 00 00 00          mov    $0x38,%eax
     0.00 :        31a2e95607:   0f 05                   syscall
    83.42 :        31a2e95609:   48 3d 00 f0 ff ff       cmp    $0xfffffffffffff000,%rax
     0.00 :        31a2e9560f:   0f 87 4d 01 00 00       ja     31a2e95762 <__fork+0x202>
     0.00 :        31a2e95615:   85 c0                   test   %eax,%eax

( this shows that 83.42% of __GI___fork's page allocations come from
  the 0x38 system call it performs. )

etc. etc. - a lot more is possible. I could list a dozen of
other different usecases straight away - neither of which is
possible via /proc/vmstat.

/proc/vmstat is not in the same league really, in terms of
expressive power of system analysis and performance
analysis.

All that the above results needed were those new tracepoints
in include/tracing/events/kmem.h.

	Ingo



```

## 18. tips.txt - Tips

```
For a higher level overview, try: perf report --sort comm,dso
Sample related events with: perf record -e '{cycles,instructions}:S'
Compare performance results with: perf diff [<old file> <new file>]
Boolean options have negative forms, e.g.: perf report --no-children
To not accumulate CPU time of children symbols add --no-children
Customize output of perf script with: perf script -F event,ip,sym
Generate a script for your data: perf script -g <lang>
Save output of perf stat using: perf stat record <target workload>
Create an archive with symtabs to analyse on other machine: perf archive
Search options using a keyword: perf report -h <keyword>
Use parent filter to see specific call path: perf report -p <regex>
List events using substring match: perf list <keyword>
To see list of saved events and attributes: perf evlist -v
Use --symfs <dir> if your symbol files are in non-standard locations
To see callchains in a more compact form: perf report -g folded
To see call chains by final symbol taking CPU time (bottom up) use perf report -G
Show individual samples with: perf script
Limit to show entries above 5% only: perf report --percent-limit 5
Profiling branch (mis)predictions with: perf record -b / perf report
To show assembler sample context control flow use perf record -b / perf report --samples 10 and then browse context
To adjust path to source files to local file system use perf report --prefix=... --prefix-strip=...
Treat branches as callchains: perf record -b ... ; perf report --branch-history
Show estimate cycles per function and IPC in annotate use perf record -b ... ; perf report --total-cycles
To count events every 1000 msec: perf stat -I 1000
Print event counts in machine readable CSV format with: perf stat -x\;
If you have debuginfo enabled, try: perf report -s sym,srcline
For memory address profiling, try: perf mem record / perf mem report
For tracepoint events, try: perf report -s trace_fields
To record callchains for each sample: perf record -g
If call chains don't work try perf record --call-graph dwarf or --call-graph lbr
To record every process run by a user: perf record -u <user>
To show inline functions in call traces add --inline to perf report
To not record events from perf itself add --exclude-perf
Skip collecting build-id when recording: perf record -B
To change sampling frequency to 100 Hz: perf record -F 100
To show information about system the samples were collected on use perf report --header
To only collect call graph on one event use perf record -e cpu/cpu-cycles,callgraph=1/,branches ; perf report --show-ref-call-graph
To set sampling period of individual events use perf record -e cpu/cpu-cycles,period=100001/,cpu/branches,period=10001/ ...
To group events which need to be collected together for accuracy use {}: perf record -e {cycles,branches}' ...
To compute metrics for samples use perf record -e '{cycles,instructions}' ... ; perf script -F +metric
See assembly instructions with percentage: perf annotate <symbol>
If you prefer Intel style assembly, try: perf annotate -M intel
When collecting LBR backtraces use --stitch-lbr to handle more than 32 deep entries: perf record --call-graph lbr ; perf report --stitch-lbr
For hierarchical output, try: perf report --hierarchy
Order by the overhead of source file name and line number: perf report -s srcline
System-wide collection from all CPUs: perf record -a
Show current config key-value pairs: perf config --list
To collect Processor Trace with samples use perf record -e '{intel_pt//,cycles}' ; perf script --call-trace or --insn-trace --xed -F +ipc (remove --xed if no xed)
To trace calls using Processor Trace use perf record -e intel_pt// ... ; perf script --call-trace. Then use perf script --time A-B --insn-trace to look at region of interest.
To measure approximate function latency with Processor Trace use perf record -e intel_pt// ... ; perf script --call-ret-trace
To trace only single function with Processor Trace use perf record --filter 'filter func @ program' -e intel_pt//u ./program ; perf script --insn-trace
Show user configuration overrides: perf config --user --list
To add Node.js USDT(User-Level Statically Defined Tracing): perf buildid-cache --add `which node`
To analyze cache line scalability issues use perf c2c record ... ; perf c2c report
To browse sample contexts use perf report --sample 10 and select in context menu
To separate samples by time use perf report --sort time,overhead,sym
To filter subset of samples with report or script add --time X-Y or --cpu A,B,C or --socket-filter ...
To set sample time separation other than 100ms with --sort time use --time-quantum
Add -I to perf record to sample register values, which will be visible in perf report sample context.
To show IPC for sampling periods use perf record -e '{cycles,instructions}:S' and then browse context
To show context switches in perf report sample context add --switch-events to perf record.
To show time in nanoseconds in record/report add --ns
To compare hot regions in two workloads use perf record -b -o file ... ; perf diff --stream file1 file2
To compare scalability of two workload samples use perf diff -c ratio file1 file2
For latency profiling, try: perf record/report --latency
For parallelism histogram, try: perf report --hierarchy --sort latency,parallelism,comm,symbol
To analyze particular parallelism levels, try: perf report --latency --parallelism=32-64
To see how parallelism changes over time, try: perf report -F time,latency,parallelism --time-quantum=1s

```

## 19. perf-intel-pt.txt - Intel Processor Trace

```
perf-intel-pt(1)
================

NAME
----
perf-intel-pt - Support for Intel Processor Trace within perf tools

SYNOPSIS
--------
[verse]
'perf record' -e intel_pt//

DESCRIPTION
-----------

Intel Processor Trace (Intel PT) is an extension of Intel Architecture that
collects information about software execution such as control flow, execution
modes and timings and formats it into highly compressed binary packets.
Technical details are documented in the Intel 64 and IA-32 Architectures
Software Developer Manuals, Chapter 36 Intel Processor Trace.

Intel PT is first supported in Intel Core M and 5th generation Intel Core
processors that are based on the Intel micro-architecture code name Broadwell.

Trace data is collected by 'perf record' and stored within the perf.data file.
See below for options to 'perf record'.

Trace data must be 'decoded' which involves walking the object code and matching
the trace data packets. For example a TNT packet only tells whether a
conditional branch was taken or not taken, so to make use of that packet the
decoder must know precisely which instruction was being executed.

Decoding is done on-the-fly.  The decoder outputs samples in the same format as
samples output by perf hardware events, for example as though the "instructions"
or "branches" events had been recorded.  Presently 3 tools support this:
'perf script', 'perf report' and 'perf inject'.  See below for more information
on using those tools.

The main distinguishing feature of Intel PT is that the decoder can determine
the exact flow of software execution.  Intel PT can be used to understand why
and how did software get to a certain point, or behave a certain way.  The
software does not have to be recompiled, so Intel PT works with debug or release
builds, however the executed images are needed - which makes use in JIT-compiled
environments, or with self-modified code, a challenge.  Also symbols need to be
provided to make sense of addresses.

A limitation of Intel PT is that it produces huge amounts of trace data
(hundreds of megabytes per second per core) which takes a long time to decode,
for example two or three orders of magnitude longer than it took to collect.
Another limitation is the performance impact of tracing, something that will
vary depending on the use-case and architecture.


Quickstart
----------

It is important to start small.  That is because it is easy to capture vastly
more data than can possibly be processed.

The simplest thing to do with Intel PT is userspace profiling of small programs.
Data is captured with 'perf record' e.g. to trace 'ls' userspace-only:

	perf record -e intel_pt//u ls

And profiled with 'perf report' e.g.

	perf report

To also trace kernel space presents a problem, namely kernel self-modifying
code.  A fairly good kernel image is available in /proc/kcore but to get an
accurate image a copy of /proc/kcore needs to be made under the same conditions
as the data capture. 'perf record' can make a copy of /proc/kcore if the option
--kcore is used, but access to /proc/kcore is restricted e.g.

	sudo perf record -o pt_ls --kcore -e intel_pt// -- ls

which will create a directory named 'pt_ls' and put the perf.data file (named
simply 'data') and copies of /proc/kcore, /proc/kallsyms and /proc/modules into
it.  The other tools understand the directory format, so to use 'perf report'
becomes:

	sudo perf report -i pt_ls

Because samples are synthesized after-the-fact, the sampling period can be
selected for reporting. e.g. sample every microsecond

	sudo perf report pt_ls --itrace=i1usge

See the sections below for more information about the --itrace option.

Beware the smaller the period, the more samples that are produced, and the
longer it takes to process them.

Also note that the coarseness of Intel PT timing information will start to
distort the statistical value of the sampling as the sampling period becomes
smaller.

To represent software control flow, "branches" samples are produced.  By default
a branch sample is synthesized for every single branch.  To get an idea what
data is available you can use the 'perf script' tool with all itrace sampling
options, which will list all the samples.

	perf record -e intel_pt//u ls
	perf script --itrace=iybxwpe

An interesting field that is not printed by default is 'flags' which can be
displayed as follows:

	perf script --itrace=iybxwpe -F+flags

The flags are "bcrosyiABExghDt" which stand for branch, call, return, conditional,
system, asynchronous, interrupt, transaction abort, trace begin, trace end,
in transaction, VM-entry, VM-exit, interrupt disabled, and interrupt disable
toggle respectively.

perf script also supports higher level ways to dump instruction traces:

	perf script --insn-trace=disasm

or to use the xed disassembler, which requires installing the xed tool
(see XED below):

	perf script --insn-trace --xed

Dumping all instructions in a long trace can be fairly slow. It is usually better
to start with higher level decoding, like

	perf script --call-trace

or

	perf script --call-ret-trace

and then select a time range of interest. The time range can then be examined
in detail with

	perf script --time starttime,stoptime --insn-trace=disasm

While examining the trace it's also useful to filter on specific CPUs using
the -C option

	perf script --time starttime,stoptime --insn-trace=disasm -C 1

Dump all instructions in time range on CPU 1.

Another interesting field that is not printed by default is 'ipc' which can be
displayed as follows:

	perf script --itrace=be -F+ipc

There are two ways that instructions-per-cycle (IPC) can be calculated depending
on the recording.

If the 'cyc' config term (see <<_config_terms,config terms>> section below) was used, then IPC
and cycle events are calculated using the cycle count from CYC packets, otherwise
MTC packets are used - refer to the 'mtc' config term.  When MTC is used, however,
the values are less accurate because the timing is less accurate.

Because Intel PT does not update the cycle count on every branch or instruction,
the values will often be zero.  When there are values, they will be the number
of instructions and number of cycles since the last update, and thus represent
the average IPC cycle count since the last IPC for that event type.
Note IPC for "branches" events is calculated separately from IPC for "instructions"
events.

Even with the 'cyc' config term, it is possible to produce IPC information for
every change of timestamp, but at the expense of accuracy.  That is selected by
specifying the itrace 'A' option.  Due to the granularity of timestamps, the
actual number of cycles increases even though the cycles reported does not.
The number of instructions is known, but if IPC is reported, cycles can be too
low and so IPC is too high.  Note that inaccuracy decreases as the period of
sampling increases i.e. if the number of cycles is too low by a small amount,
that becomes less significant if the number of cycles is large.  It may also be
useful to use the 'A' option in conjunction with dlfilter-show-cycles.so to
provide higher granularity cycle information.

Also note that the IPC instruction count may or may not include the current
instruction.  If the cycle count is associated with an asynchronous branch
(e.g. page fault or interrupt), then the instruction count does not include the
current instruction, otherwise it does.  That is consistent with whether or not
that instruction has retired when the cycle count is updated.

Another note, in the case of "branches" events, non-taken branches are not
presently sampled, so IPC values for them do not appear e.g. a CYC packet with a
TNT packet that starts with a non-taken branch.  To see every possible IPC
value, "instructions" events can be used e.g. --itrace=i0ns

While it is possible to create scripts to analyze the data, an alternative
approach is available to export the data to a sqlite or postgresql database.
Refer to script export-to-sqlite.py or export-to-postgresql.py for more details,
and to script exported-sql-viewer.py for an example of using the database.

There is also script intel-pt-events.py which provides an example of how to
unpack the raw data for power events and PTWRITE. The script also displays
branches, and supports 2 additional modes selected by option:

 - --insn-trace - instruction trace
 - --src-trace - source trace

The intel-pt-events.py script also has options:

 - --all-switch-events - display all switch events, not only the last consecutive.
 - --interleave [<n>] - interleave sample output for the same timestamp so that
 no more than n samples for a CPU are displayed in a row. 'n' defaults to 4.
 Note this only affects the order of output, and only when the timestamp is the
 same.

As mentioned above, it is easy to capture too much data.  One way to limit the
data captured is to use 'snapshot' mode which is explained further below.
Refer to 'new snapshot option' and 'Intel PT modes of operation' further below.

Another problem that will be experienced is decoder errors.  They can be caused
by inability to access the executed image, self-modified or JIT-ed code, or the
inability to match side-band information (such as context switches and mmaps)
which results in the decoder not knowing what code was executed.

There is also the problem of perf not being able to copy the data fast enough,
resulting in data lost because the buffer was full.  See 'Buffer handling' below
for more details.


perf record
-----------

new event
~~~~~~~~~

The Intel PT kernel driver creates a new PMU for Intel PT.  PMU events are
selected by providing the PMU name followed by the "config" separated by slashes.
An enhancement has been made to allow default "config" e.g. the option

	-e intel_pt//

will use a default config value.  Currently that is the same as

	-e intel_pt/tsc,noretcomp=0/

which is the same as

	-e intel_pt/tsc=1,noretcomp=0/

Note there are other config terms - see section <<_config_terms,config terms>> further below.

The config terms are listed in /sys/devices/intel_pt/format.  They are bit
fields within the config member of the struct perf_event_attr which is
passed to the kernel by the perf_event_open system call.  They correspond to bit
fields in the IA32_RTIT_CTL MSR.  Here is a list of them and their definitions:

	$ grep -H . /sys/bus/event_source/devices/intel_pt/format/*
	/sys/bus/event_source/devices/intel_pt/format/cyc:config:1
	/sys/bus/event_source/devices/intel_pt/format/cyc_thresh:config:19-22
	/sys/bus/event_source/devices/intel_pt/format/mtc:config:9
	/sys/bus/event_source/devices/intel_pt/format/mtc_period:config:14-17
	/sys/bus/event_source/devices/intel_pt/format/noretcomp:config:11
	/sys/bus/event_source/devices/intel_pt/format/psb_period:config:24-27
	/sys/bus/event_source/devices/intel_pt/format/tsc:config:10

Note that the default config must be overridden for each term i.e.

	-e intel_pt/noretcomp=0/

is the same as:

	-e intel_pt/tsc=1,noretcomp=0/

So, to disable TSC packets use:

	-e intel_pt/tsc=0/

It is also possible to specify the config value explicitly:

	-e intel_pt/config=0x400/

Note that, as with all events, the event is suffixed with event modifiers:

	u	userspace
	k	kernel
	h	hypervisor
	G	guest
	H	host
	p	precise ip

'h', 'G' and 'H' are for virtualization which are not used by Intel PT.
'p' is also not relevant to Intel PT.  So only options 'u' and 'k' are
meaningful for Intel PT.

perf_event_attr is displayed if the -vv option is used e.g.

	------------------------------------------------------------
	perf_event_attr:
	type                             6
	size                             112
	config                           0x400
	{ sample_period, sample_freq }   1
	sample_type                      IP|TID|TIME|CPU|IDENTIFIER
	read_format                      ID
	disabled                         1
	inherit                          1
	exclude_kernel                   1
	exclude_hv                       1
	enable_on_exec                   1
	sample_id_all                    1
	------------------------------------------------------------
	sys_perf_event_open: pid 31104  cpu 0  group_fd -1  flags 0x8
	sys_perf_event_open: pid 31104  cpu 1  group_fd -1  flags 0x8
	sys_perf_event_open: pid 31104  cpu 2  group_fd -1  flags 0x8
	sys_perf_event_open: pid 31104  cpu 3  group_fd -1  flags 0x8
	------------------------------------------------------------


config terms
~~~~~~~~~~~~

Config terms are parameters specified with the -e intel_pt// event option,
for example:

	-e intel_pt/cyc/

which selects cycle accurate mode. Each config term can have a value which
defaults to 1, so the above is the same as:

	-e intel_pt/cyc=1/

Some terms are set by default, so must be set to 0 to turn them off. For
example, to turn off branch tracing:

	-e intel_pt/branch=0/

Multiple config terms are separated by commas, for example:

	-e intel_pt/cyc,mtc_period=9/

There are also common config terms, see linkperf:perf-record[1] documentation.

Intel PT config terms are described below.

*tsc*::
Always supported.  Produces TSC timestamp packets to provide
timing information.  In some cases it is possible to decode
without timing information, for example a per-thread context
that does not overlap executable memory maps.
+
The default config selects tsc (i.e. tsc=1).

*noretcomp*::
Always supported.  Disables "return compression" so a TIP packet
is produced when a function returns.  Causes more packets to be
produced but might make decoding more reliable.
+
The default config does not select noretcomp (i.e. noretcomp=0).

*psb_period*::
Allows the frequency of PSB packets to be specified.
+
The PSB packet is a synchronization packet that provides a
starting point for decoding or recovery from errors.
+
Support for psb_period is indicated by:
+
	/sys/bus/event_source/devices/intel_pt/caps/psb_cyc
+
which contains "1" if the feature is supported and "0"
otherwise.
+
Valid values are given by:
+
	/sys/bus/event_source/devices/intel_pt/caps/psb_periods
+
which contains a hexadecimal value, the bits of which represent
valid values e.g. bit 2 set means value 2 is valid.
+
The psb_period value is converted to the approximate number of
trace bytes between PSB packets as:
+
	2 ^ (value + 11)
+
e.g. value 3 means 16KiB bytes between PSBs
+
If an invalid value is entered, the error message
will give a list of valid values e.g.
+
	$ perf record -e intel_pt/psb_period=15/u uname
	Invalid psb_period for intel_pt. Valid values are: 0-5
+
If MTC packets are selected, the default config selects a value
of 3 (i.e. psb_period=3) or the nearest lower value that is
supported (0 is always supported).  Otherwise the default is 0.
+
If decoding is expected to be reliable and the buffer is large
then a large PSB period can be used.
+
Because a TSC packet is produced with PSB, the PSB period can
also affect the granularity to timing information in the absence
of MTC or CYC.

*mtc*::
Produces MTC timing packets.
+
MTC packets provide finer grain timestamp information than TSC
packets.  MTC packets record time using the hardware crystal
clock (CTC) which is related to TSC packets using a TMA packet.
+
Support for this feature is indicated by:
+
	/sys/bus/event_source/devices/intel_pt/caps/mtc
+
which contains "1" if the feature is supported and
"0" otherwise.
+
The frequency of MTC packets can also be specified - see
mtc_period below.

*mtc_period*::
Specifies how frequently MTC packets are produced - see mtc
above for how to determine if MTC packets are supported.
+
Valid values are given by:
+
	/sys/bus/event_source/devices/intel_pt/caps/mtc_periods
+
which contains a hexadecimal value, the bits of which represent
valid values e.g. bit 2 set means value 2 is valid.
+
The mtc_period value is converted to the MTC frequency as:

	CTC-frequency / (2 ^ value)
+
e.g. value 3 means one eighth of CTC-frequency
+
Where CTC is the hardware crystal clock, the frequency of which
can be related to TSC via values provided in cpuid leaf 0x15.
+
If an invalid value is entered, the error message
will give a list of valid values e.g.
+
	$ perf record -e intel_pt/mtc_period=15/u uname
	Invalid mtc_period for intel_pt. Valid values are: 0,3,6,9
+
The default value is 3 or the nearest lower value
that is supported (0 is always supported).

*cyc*::
Produces CYC timing packets.
+
CYC packets provide even finer grain timestamp information than
MTC and TSC packets.  A CYC packet contains the number of CPU
cycles since the last CYC packet. Unlike MTC and TSC packets,
CYC packets are only sent when another packet is also sent.
+
Support for this feature is indicated by:
+
	/sys/bus/event_source/devices/intel_pt/caps/psb_cyc
+
which contains "1" if the feature is supported and
"0" otherwise.
+
The number of CYC packets produced can be reduced by specifying
a threshold - see cyc_thresh below.

*cyc_thresh*::
Specifies how frequently CYC packets are produced - see cyc
above for how to determine if CYC packets are supported.
+
Valid cyc_thresh values are given by:
+
	/sys/bus/event_source/devices/intel_pt/caps/cycle_thresholds
+
which contains a hexadecimal value, the bits of which represent
valid values e.g. bit 2 set means value 2 is valid.
+
The cyc_thresh value represents the minimum number of CPU cycles
that must have passed before a CYC packet can be sent.  The
number of CPU cycles is:
+
	2 ^ (value - 1)
+
e.g. value 4 means 8 CPU cycles must pass before a CYC packet
can be sent.  Note a CYC packet is still only sent when another
packet is sent, not at, e.g. every 8 CPU cycles.
+
If an invalid value is entered, the error message
will give a list of valid values e.g.
+
	$ perf record -e intel_pt/cyc,cyc_thresh=15/u uname
	Invalid cyc_thresh for intel_pt. Valid values are: 0-12
+
CYC packets are not requested by default.

*pt*::
Specifies pass-through which enables the 'branch' config term.
+
The default config selects 'pt' if it is available, so a user will
never need to specify this term.

*branch*::
Enable branch tracing.  Branch tracing is enabled by default so to
disable branch tracing use 'branch=0'.
+
The default config selects 'branch' if it is available.

*ptw*::
Enable PTWRITE packets which are produced when a ptwrite instruction
is executed.
+
Support for this feature is indicated by:
+
	/sys/bus/event_source/devices/intel_pt/caps/ptwrite
+
which contains "1" if the feature is supported and
"0" otherwise.
+
As an alternative, refer to "Emulated PTWRITE" further below.

*fup_on_ptw*::
Enable a FUP packet to follow the PTWRITE packet.  The FUP packet
provides the address of the ptwrite instruction.  In the absence of
fup_on_ptw, the decoder will use the address of the previous branch
if branch tracing is enabled, otherwise the address will be zero.
Note that fup_on_ptw will work even when branch tracing is disabled.

*pwr_evt*::
Enable power events.  The power events provide information about
changes to the CPU C-state.
+
Support for this feature is indicated by:
+
	/sys/bus/event_source/devices/intel_pt/caps/power_event_trace
+
which contains "1" if the feature is supported and
"0" otherwise.

*event*::
Enable Event Trace.  The events provide information about asynchronous
events.
+
Support for this feature is indicated by:
+
	/sys/bus/event_source/devices/intel_pt/caps/event_trace
+
which contains "1" if the feature is supported and
"0" otherwise.

*notnt*::
Disable TNT packets.  Without TNT packets, it is not possible to walk
executable code to reconstruct control flow, however FUP, TIP, TIP.PGE
and TIP.PGD packets still indicate asynchronous control flow, and (if
return compression is disabled - see noretcomp) return statements.
The advantage of eliminating TNT packets is reducing the size of the
trace and corresponding tracing overhead.
+
Support for this feature is indicated by:
+
	/sys/bus/event_source/devices/intel_pt/caps/tnt_disable
+
which contains "1" if the feature is supported and
"0" otherwise.

*aux-action=start-paused*::
Start tracing paused, refer to the section <<_pause_or_resume_tracing,Pause or Resume Tracing>>


config terms on other events
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Some Intel PT features work with other events, features such as AUX area sampling
and PEBS-via-PT.  In those cases, the other events can have config terms below:

*aux-sample-size*::
		Used to set the AUX area sample size, refer to the section
		<<_aux_area_sampling_option,AUX area sampling option>>

*aux-output*::
		Used to select PEBS-via-PT, refer to the
		section <<_pebs_via_intel_pt,PEBS via Intel PT>>

*aux-action*::
		Used to pause or resume tracing, refer to the section
		<<_pause_or_resume_tracing,Pause or Resume Tracing>>

AUX area sampling option
~~~~~~~~~~~~~~~~~~~~~~~~

To select Intel PT "sampling" the AUX area sampling option can be used:

	--aux-sample

Optionally it can be followed by the sample size in bytes e.g.

	--aux-sample=8192

In addition, the Intel PT event to sample must be defined e.g.

	-e intel_pt//u

Samples on other events will be created containing Intel PT data e.g. the
following will create Intel PT samples on the branch-misses event, note the
events must be grouped using {}:

	perf record --aux-sample -e '{intel_pt//u,branch-misses:u}'

An alternative to '--aux-sample' is to add the config term 'aux-sample-size' to
events.  In this case, the grouping is implied e.g.

	perf record -e intel_pt//u -e branch-misses/aux-sample-size=8192/u

is the same as:

	perf record -e '{intel_pt//u,branch-misses/aux-sample-size=8192/u}'

but allows for also using an address filter e.g.:

	perf record -e intel_pt//u --filter 'filter * @/bin/ls' -e branch-misses/aux-sample-size=8192/u -- ls

It is important to select a sample size that is big enough to contain at least
one PSB packet.  If not a warning will be displayed:

	Intel PT sample size (%zu) may be too small for PSB period (%zu)

The calculation used for that is: if sample_size <= psb_period + 256 display the
warning.  When sampling is used, psb_period defaults to 0 (2KiB).

The default sample size is 4KiB.

The sample size is passed in aux_sample_size in struct perf_event_attr.  The
sample size is limited by the maximum event size which is 64KiB.  It is
difficult to know how big the event might be without the trace sample attached,
but the tool validates that the sample size is not greater than 60KiB.


new snapshot option
~~~~~~~~~~~~~~~~~~~

The difference between full trace and snapshot from the kernel's perspective is
that in full trace we don't overwrite trace data that the user hasn't collected
yet (and indicated that by advancing aux_tail), whereas in snapshot mode we let
the trace run and overwrite older data in the buffer so that whenever something
interesting happens, we can stop it and grab a snapshot of what was going on
around that interesting moment.

To select snapshot mode a new option has been added:

	-S

Optionally it can be followed by the snapshot size e.g.

	-S0x100000

The default snapshot size is the auxtrace mmap size.  If neither auxtrace mmap size
nor snapshot size is specified, then the default is 4MiB for privileged users
(or if /proc/sys/kernel/perf_event_paranoid < 0), 128KiB for unprivileged users.
If an unprivileged user does not specify mmap pages, the mmap pages will be
reduced as described in the <<_new_auxtrace_mmap_size_option,new auxtrace mmap size option>>
section below.

The snapshot size is displayed if the option -vv is used e.g.

	Intel PT snapshot size: %zu


new auxtrace mmap size option
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Intel PT buffer size is specified by an addition to the -m option e.g.

	-m,16

selects a buffer size of 16 pages i.e. 64KiB.

Note that the existing functionality of -m is unchanged.  The auxtrace mmap size
is specified by the optional addition of a comma and the value.

The default auxtrace mmap size for Intel PT is 4MiB/page_size for privileged users
(or if /proc/sys/kernel/perf_event_paranoid < 0), 128KiB for unprivileged users.
If an unprivileged user does not specify mmap pages, the mmap pages will be
reduced from the default 512KiB/page_size to 256KiB/page_size, otherwise the
user is likely to get an error as they exceed their mlock limit (Max locked
memory as shown in /proc/self/limits).  Note that perf does not count the first
512KiB (actually /proc/sys/kernel/perf_event_mlock_kb minus 1 page) per cpu
against the mlock limit so an unprivileged user is allowed 512KiB per cpu plus
their mlock limit (which defaults to 64KiB but is not multiplied by the number
of cpus).

In full-trace mode, powers of two are allowed for buffer size, with a minimum
size of 2 pages.  In snapshot mode or sampling mode, it is the same but the
minimum size is 1 page.

The mmap size and auxtrace mmap size are displayed if the -vv option is used e.g.

	mmap length 528384
	auxtrace mmap length 4198400


Intel PT modes of operation
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Intel PT can be used in 3 modes:
	full-trace mode
	sample mode
	snapshot mode

Full-trace mode traces continuously e.g.

	perf record -e intel_pt//u uname

Sample mode attaches a Intel PT sample to other events e.g.

	perf record --aux-sample -e intel_pt//u -e branch-misses:u

Snapshot mode captures the available data when a signal is sent or "snapshot"
control command is issued. e.g. using a signal

	perf record -v -e intel_pt//u -S ./loopy 1000000000 &
	[1] 11435
	kill -USR2 11435
	Recording AUX area tracing snapshot

Note that the signal sent is SIGUSR2.
Note that "Recording AUX area tracing snapshot" is displayed because the -v
option is used.

The advantage of using "snapshot" control command is that the access is
controlled by access to a FIFO e.g.

	$ mkfifo perf.control
	$ mkfifo perf.ack
	$ cat perf.ack &
	[1] 15235
	$ sudo ~/bin/perf record --control fifo:perf.control,perf.ack -S -e intel_pt//u -- sleep 60 &
	[2] 15243
	$ ps -e | grep perf
	15244 pts/1    00:00:00 perf
	$ kill -USR2 15244
	bash: kill: (15244) - Operation not permitted
	$ echo snapshot > perf.control
	ack

The 3 Intel PT modes of operation cannot be used together.


Buffer handling
~~~~~~~~~~~~~~~

There may be buffer limitations (i.e. single ToPa entry) which means that actual
buffer sizes are limited to powers of 2 up to 4MiB (MAX_PAGE_ORDER).  In order to
provide other sizes, and in particular an arbitrarily large size, multiple
buffers are logically concatenated.  However an interrupt must be used to switch
between buffers.  That has two potential problems:
	a) the interrupt may not be handled in time so that the current buffer
	becomes full and some trace data is lost.
	b) the interrupts may slow the system and affect the performance
	results.

If trace data is lost, the driver sets 'truncated' in the PERF_RECORD_AUX event
which the tools report as an error.

In full-trace mode, the driver waits for data to be copied out before allowing
the (logical) buffer to wrap-around.  If data is not copied out quickly enough,
again 'truncated' is set in the PERF_RECORD_AUX event.  If the driver has to
wait, the intel_pt event gets disabled.  Because it is difficult to know when
that happens, perf tools always re-enable the intel_pt event after copying out
data.


Intel PT and build ids
~~~~~~~~~~~~~~~~~~~~~~

By default "perf record" post-processes the event stream to find all build ids
for executables for all addresses sampled.  Deliberately, Intel PT is not
decoded for that purpose (it would take too long).  Instead the build ids for
all executables encountered (due to mmap, comm or task events) are included
in the perf.data file.

To see buildids included in the perf.data file use the command:

	perf buildid-list

If the perf.data file contains Intel PT data, that is the same as:

	perf buildid-list --with-hits


Snapshot mode and event disabling
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In order to make a snapshot, the intel_pt event is disabled using an IOCTL,
namely PERF_EVENT_IOC_DISABLE.  However doing that can also disable the
collection of side-band information.  In order to prevent that,  a dummy
software event has been introduced that permits tracking events (like mmaps) to
continue to be recorded while intel_pt is disabled.  That is important to ensure
there is complete side-band information to allow the decoding of subsequent
snapshots.

A test has been created for that.  To find the test:

	perf test list
	...
	23: Test using a dummy software event to keep tracking

To run the test:

	perf test 23
	23: Test using a dummy software event to keep tracking     : Ok


perf record modes (nothing new here)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

perf record essentially operates in one of three modes:
	per thread
	per cpu
	workload only

"per thread" mode is selected by -t or by --per-thread (with -p or -u or just a
workload).
"per cpu" is selected by -C or -a.
"workload only" mode is selected by not using the other options but providing a
command to run (i.e. the workload).

In per-thread mode an exact list of threads is traced.  There is no inheritance.
Each thread has its own event buffer.

In per-cpu mode all processes (or processes from the selected cgroup i.e. -G
option, or processes selected with -p or -u) are traced.  Each cpu has its own
buffer. Inheritance is allowed.

In workload-only mode, the workload is traced but with per-cpu buffers.
Inheritance is allowed.  Note that you can now trace a workload in per-thread
mode by using the --per-thread option.


Privileged vs non-privileged users
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Unless /proc/sys/kernel/perf_event_paranoid is set to -1, unprivileged users
have memory limits imposed upon them.  That affects what buffer sizes they can
have as outlined above.

The v4.2 kernel introduced support for a context switch metadata event,
PERF_RECORD_SWITCH, which allows unprivileged users to see when their processes
are scheduled out and in, just not by whom, which is left for the
PERF_RECORD_SWITCH_CPU_WIDE, that is only accessible in system wide context,
which in turn requires CAP_PERFMON or CAP_SYS_ADMIN.

Please see the 45ac1403f564 ("perf: Add PERF_RECORD_SWITCH to indicate context
switches") commit, that introduces these metadata events for further info.

When working with kernels < v4.2, the following considerations must be taken,
as the sched:sched_switch tracepoints will be used to receive such information:

Unless /proc/sys/kernel/perf_event_paranoid is set to -1, unprivileged users are
not permitted to use tracepoints which means there is insufficient side-band
information to decode Intel PT in per-cpu mode, and potentially workload-only
mode too if the workload creates new processes.

Note also, that to use tracepoints, read-access to debugfs is required.  So if
debugfs is not mounted or the user does not have read-access, it will again not
be possible to decode Intel PT in per-cpu mode.


sched_switch tracepoint
~~~~~~~~~~~~~~~~~~~~~~~

The sched_switch tracepoint is used to provide side-band data for Intel PT
decoding in kernels where the PERF_RECORD_SWITCH metadata event isn't
available.

The sched_switch events are automatically added. e.g. the second event shown
below:

	$ perf record -vv -e intel_pt//u uname
	------------------------------------------------------------
	perf_event_attr:
	type                             6
	size                             112
	config                           0x400
	{ sample_period, sample_freq }   1
	sample_type                      IP|TID|TIME|CPU|IDENTIFIER
	read_format                      ID
	disabled                         1
	inherit                          1
	exclude_kernel                   1
	exclude_hv                       1
	enable_on_exec                   1
	sample_id_all                    1
	------------------------------------------------------------
	sys_perf_event_open: pid 31104  cpu 0  group_fd -1  flags 0x8
	sys_perf_event_open: pid 31104  cpu 1  group_fd -1  flags 0x8
	sys_perf_event_open: pid 31104  cpu 2  group_fd -1  flags 0x8
	sys_perf_event_open: pid 31104  cpu 3  group_fd -1  flags 0x8
	------------------------------------------------------------
	perf_event_attr:
	type                             2
	size                             112
	config                           0x108
	{ sample_period, sample_freq }   1
	sample_type                      IP|TID|TIME|CPU|PERIOD|RAW|IDENTIFIER
	read_format                      ID
	inherit                          1
	sample_id_all                    1
	exclude_guest                    1
	------------------------------------------------------------
	sys_perf_event_open: pid -1  cpu 0  group_fd -1  flags 0x8
	sys_perf_event_open: pid -1  cpu 1  group_fd -1  flags 0x8
	sys_perf_event_open: pid -1  cpu 2  group_fd -1  flags 0x8
	sys_perf_event_open: pid -1  cpu 3  group_fd -1  flags 0x8
	------------------------------------------------------------
	perf_event_attr:
	type                             1
	size                             112
	config                           0x9
	{ sample_period, sample_freq }   1
	sample_type                      IP|TID|TIME|IDENTIFIER
	read_format                      ID
	disabled                         1
	inherit                          1
	exclude_kernel                   1
	exclude_hv                       1
	mmap                             1
	comm                             1
	enable_on_exec                   1
	task                             1
	sample_id_all                    1
	mmap2                            1
	comm_exec                        1
	------------------------------------------------------------
	sys_perf_event_open: pid 31104  cpu 0  group_fd -1  flags 0x8
	sys_perf_event_open: pid 31104  cpu 1  group_fd -1  flags 0x8
	sys_perf_event_open: pid 31104  cpu 2  group_fd -1  flags 0x8
	sys_perf_event_open: pid 31104  cpu 3  group_fd -1  flags 0x8
	mmap size 528384B
	AUX area mmap length 4194304
	perf event ring buffer mmapped per cpu
	Synthesizing auxtrace information
	Linux
	[ perf record: Woken up 1 times to write data ]
	[ perf record: Captured and wrote 0.042 MB perf.data ]

Note, the sched_switch event is only added if the user is permitted to use it
and only in per-cpu mode.

Note also, the sched_switch event is only added if TSC packets are requested.
That is because, in the absence of timing information, the sched_switch events
cannot be matched against the Intel PT trace.


perf script
-----------

By default, perf script will decode trace data found in the perf.data file.
This can be further controlled by new option --itrace.


New --itrace option
~~~~~~~~~~~~~~~~~~~

Having no option is the same as

	--itrace

which, in turn, is the same as

	--itrace=cepwxy

The letters are:

	i	synthesize "instructions" events
	y	synthesize "cycles" events
	b	synthesize "branches" events
	x	synthesize "transactions" events
	w	synthesize "ptwrite" events
	p	synthesize "power" events (incl. PSB events)
	c	synthesize branches events (calls only)
	r	synthesize branches events (returns only)
	o	synthesize PEBS-via-PT events
	I	synthesize Event Trace events
	e	synthesize tracing error events
	d	create a debug log
	g	synthesize a call chain (use with i or x)
	G	synthesize a call chain on existing event records
	l	synthesize last branch entries (use with i or x)
	L	synthesize last branch entries on existing event records
	s	skip initial number of events
	q	quicker (less detailed) decoding
	A	approximate IPC
	Z	prefer to ignore timestamps (so-called "timeless" decoding)

"Instructions" events look like they were recorded by "perf record -e
instructions".

"Cycles" events look like they were recorded by "perf record -e cycles"
(ie., the default). Note that even with CYC packets enabled and no sampling,
these are not fully accurate, since CYC packets are not emitted for each
instruction, only when some other event (like an indirect branch, or a
TNT packet representing multiple branches) happens causes a packet to
be emitted. Thus, it is more effective for attributing cycles to functions
(and possibly basic blocks) than to individual instructions, although it
is not even perfect for functions (although it becomes better if the noretcomp
option is active).

"Branches" events look like they were recorded by "perf record -e branches". "c"
and "r" can be combined to get calls and returns.

"Transactions" events correspond to the start or end of transactions. The
'flags' field can be used in perf script to determine whether the event is a
transaction start, commit or abort.

Note that "instructions", "cycles", "branches" and "transactions" events
depend on code flow packets which can be disabled by using the config term
"branch=0".  Refer to the <<_config_terms,config terms>> section above.

"ptwrite" events record the payload of the ptwrite instruction and whether
"fup_on_ptw" was used.  "ptwrite" events depend on PTWRITE packets which are
recorded only if the "ptw" config term was used.  Refer to the <<_config_terms,config terms>>
section above.  perf script "synth" field displays "ptwrite" information like
this: "ip: 0 payload: 0x123456789abcdef0"  where "ip" is 1 if "fup_on_ptw" was
used.

"Power" events correspond to power event packets and CBR (core-to-bus ratio)
packets.  While CBR packets are always recorded when tracing is enabled, power
event packets are recorded only if the "pwr_evt" config term was used.  Refer to
the <<_config_terms,config terms>> section above.  The power events record information about
C-state changes, whereas CBR is indicative of CPU frequency.  perf script
"event,synth" fields display information like this:

	cbr:  cbr: 22 freq: 2189 MHz (200%)
	mwait:  hints: 0x60 extensions: 0x1
	pwre:  hw: 0 cstate: 2 sub-cstate: 0
	exstop:  ip: 1
	pwrx:  deepest cstate: 2 last cstate: 2 wake reason: 0x4

Where:

	"cbr" includes the frequency and the percentage of maximum non-turbo
	"mwait" shows mwait hints and extensions
	"pwre" shows C-state transitions (to a C-state deeper than C0) and
	whether	initiated by hardware
	"exstop" indicates execution stopped and whether the IP was recorded
	exactly,
	"pwrx" indicates return to C0

For more details refer to the Intel 64 and IA-32 Architectures Software
Developer Manuals.

PSB events show when a PSB+ occurred and also the byte-offset in the trace.
Emitting a PSB+ can cause a CPU a slight delay. When doing timing analysis
of code with Intel PT, it is useful to know if a timing bubble was caused
by Intel PT or not.

Error events show where the decoder lost the trace.  Error events
are quite important.  Users must know if what they are seeing is a complete
picture or not. The "e" option may be followed by flags which affect what errors
will or will not be reported.  Each flag must be preceded by either '+' or '-'.
The flags supported by Intel PT are:

		-o	Suppress overflow errors
		-l	Suppress trace data lost errors

For example, for errors but not overflow or data lost errors:

	--itrace=e-o-l

The "d" option will cause the creation of a file "intel_pt.log" containing all
decoded packets and instructions.  Note that this option slows down the decoder
and that the resulting file may be very large.  The "d" option may be followed
by flags which affect what debug messages will or will not be logged. Each flag
must be preceded by either '+' or '-'. The flags support by Intel PT are:

		-a	Suppress logging of perf events
		+a	Log all perf events
		+e	Output only on decoding errors (size configurable)
		+o	Output to stdout instead of "intel_pt.log"

By default, logged perf events are filtered by any specified time ranges, but
flag +a overrides that.  The +e flag can be useful for analyzing errors.  By
default, the log size in that case is 16384 bytes, but can be altered by
linkperf:perf-config[1] e.g. perf config itrace.debug-log-buffer-size=30000

In addition, the period of the "instructions" event can be specified. e.g.

	--itrace=i10us

sets the period to 10us i.e. one  instruction sample is synthesized for each 10
microseconds of trace.  Alternatives to "us" are "ms" (milliseconds),
"ns" (nanoseconds), "t" (TSC ticks) or "i" (instructions).

"ms", "us" and "ns" are converted to TSC ticks.

The timing information included with Intel PT does not give the time of every
instruction.  Consequently, for the purpose of sampling, the decoder estimates
the time since the last timing packet based on 1 tick per instruction.  The time
on the sample is *not* adjusted and reflects the last known value of TSC.

For Intel PT, the default period is 100us.

Setting it to a zero period means "as often as possible".

In the case of Intel PT that is the same as a period of 1 and a unit of
'instructions' (i.e. --itrace=i1i).

Also the call chain size (default 16, max. 1024) for instructions or
transactions events can be specified. e.g.

	--itrace=ig32
	--itrace=xg32

Also the number of last branch entries (default 64, max. 1024) for instructions or
transactions events can be specified. e.g.

       --itrace=il10
       --itrace=xl10

Note that last branch entries are cleared for each sample, so there is no overlap
from one sample to the next.

The G and L options are designed in particular for sample mode, and work much
like g and l but add call chain and branch stack to the other selected events
instead of synthesized events. For example, to record branch-misses events for
'ls' and then add a call chain derived from the Intel PT trace:

	perf record --aux-sample -e '{intel_pt//u,branch-misses:u}' -- ls
	perf report --itrace=Ge

Although in fact G is a default for perf report, so that is the same as just:

	perf report

One caveat with the G and L options is that they work poorly with "Large PEBS".
Large PEBS means PEBS records will be accumulated by hardware and the written
into the event buffer in one go.  That reduces interrupts, but can give very
late timestamps.  Because the Intel PT trace is synchronized by timestamps,
the PEBS events do not match the trace.  Currently, Large PEBS is used only in
certain circumstances:
	- hardware supports it
	- PEBS is used
	- event period is specified, instead of frequency
	- the sample type is limited to the following flags:
		PERF_SAMPLE_IP | PERF_SAMPLE_TID | PERF_SAMPLE_ADDR |
		PERF_SAMPLE_ID | PERF_SAMPLE_CPU | PERF_SAMPLE_STREAM_ID |
		PERF_SAMPLE_DATA_SRC | PERF_SAMPLE_IDENTIFIER |
		PERF_SAMPLE_TRANSACTION | PERF_SAMPLE_PHYS_ADDR |
		PERF_SAMPLE_REGS_INTR | PERF_SAMPLE_REGS_USER |
		PERF_SAMPLE_PERIOD (and sometimes) | PERF_SAMPLE_TIME
Because Intel PT sample mode uses a different sample type to the list above,
Large PEBS is not used with Intel PT sample mode. To avoid Large PEBS in other
cases, avoid specifying the event period i.e. avoid the 'perf record' -c option,
--count option, or 'period' config term.

To disable trace decoding entirely, use the option --no-itrace.

It is also possible to skip events generated (instructions, branches, transactions)
at the beginning. This is useful to ignore initialization code.

	--itrace=i0nss1000000

skips the first million instructions.

The q option changes the way the trace is decoded.  The decoding is much faster
but much less detailed.  Specifically, with the q option, the decoder does not
decode TNT packets, and does not walk object code, but gets the ip from FUP and
TIP packets.  The q option can be used with the b and i options but the period
is not used.  The q option decodes more quickly, but is useful only if the
control flow of interest is represented or indicated by FUP, TIP, TIP.PGE, or
TIP.PGD packets (refer below).  However the q option could be used to find time
ranges that could then be decoded fully using the --time option.

What will *not* be decoded with the (single) q option:

	- direct calls and jmps
	- conditional branches
	- non-branch instructions

What *will* be decoded with the (single) q option:

	- asynchronous branches such as interrupts
	- indirect branches
	- function return target address *if* the noretcomp config term (refer
	<<_config_terms,config terms>> section) was used
	- start of (control-flow) tracing
	- end of (control-flow) tracing, if it is not out of context
	- power events, ptwrite, transaction start and abort
	- instruction pointer associated with PSB packets

Note the q option does not specify what events will be synthesized e.g. the p
option must be used also to show power events.

Repeating the q option (double-q i.e. qq) results in even faster decoding and even
less detail.  The decoder decodes only extended PSB (PSB+) packets, getting the
instruction pointer if there is a FUP packet within PSB+ (i.e. between PSB and
PSBEND).  Note PSB packets occur regularly in the trace based on the psb_period
config term (refer <<_config_terms,config terms>> section).  There will be a FUP packet if the
PSB+ occurs while control flow is being traced.

What will *not* be decoded with the qq option:

	- everything except instruction pointer associated with PSB packets

What *will* be decoded with the qq option:

	- instruction pointer associated with PSB packets

The Z option is equivalent to having recorded a trace without TSC
(i.e. config term tsc=0). It can be useful to avoid timestamp issues when
decoding a trace of a virtual machine.


dlfilter-show-cycles.so
~~~~~~~~~~~~~~~~~~~~~~~

Cycles can be displayed using dlfilter-show-cycles.so in which case the itrace A
option can be useful to provide higher granularity cycle information:

	perf script --itrace=A --call-trace --dlfilter dlfilter-show-cycles.so

To see a list of dlfilters:

	perf script -v --list-dlfilters

See also linkperf:perf-dlfilters[1]


dump option
~~~~~~~~~~~

perf script has an option (-D) to "dump" the events i.e. display the binary
data.

When -D is used, Intel PT packets are displayed.  The packet decoder does not
pay attention to PSB packets, but just decodes the bytes - so the packets seen
by the actual decoder may not be identical in places where the data is corrupt.
One example of that would be when the buffer-switching interrupt has been too
slow, and the buffer has been filled completely.  In that case, the last packet
in the buffer might be truncated and immediately followed by a PSB as the trace
continues in the next buffer.

To disable the display of Intel PT packets, combine the -D option with
--no-itrace.


perf report
-----------

By default, perf report will decode trace data found in the perf.data file.
This can be further controlled by new option --itrace exactly the same as
perf script, with the exception that the default is --itrace=igxe.


perf inject
-----------

perf inject also accepts the --itrace option in which case tracing data is
removed and replaced with the synthesized events. e.g.

	perf inject --itrace -i perf.data -o perf.data.new

Below is an example of using Intel PT with autofdo.  It requires autofdo
(https://github.com/google/autofdo) and gcc version 5.  The bubble
sort example is from the AutoFDO tutorial (https://gcc.gnu.org/wiki/AutoFDO/Tutorial)
amended to take the number of elements as a parameter.

	$ gcc-5 -O3 sort.c -o sort_optimized
	$ ./sort_optimized 30000
	Bubble sorting array of 30000 elements
	2254 ms

	$ cat ~/.perfconfig
	[intel-pt]
		mispred-all = on

	$ perf record -e intel_pt//u ./sort 3000
	Bubble sorting array of 3000 elements
	58 ms
	[ perf record: Woken up 2 times to write data ]
	[ perf record: Captured and wrote 3.939 MB perf.data ]
	$ perf inject -i perf.data -o inj --itrace=i100usle --strip
	$ ./create_gcov --binary=./sort --profile=inj --gcov=sort.gcov -gcov_version=1
	$ gcc-5 -O3 -fauto-profile=sort.gcov sort.c -o sort_autofdo
	$ ./sort_autofdo 30000
	Bubble sorting array of 30000 elements
	2155 ms

Note there is currently no advantage to using Intel PT instead of LBR, but
that may change in the future if greater use is made of the data.


PEBS via Intel PT
-----------------

Some hardware has the feature to redirect PEBS records to the Intel PT trace.
Recording is selected by using the aux-output config term e.g.

	perf record -c 10000 -e '{intel_pt/branch=0/,cycles/aux-output/ppp}' uname

Originally, software only supported redirecting at most one PEBS event because it
was not able to differentiate one event from another. To overcome that, more recent
kernels and perf tools add support for the PERF_RECORD_AUX_OUTPUT_HW_ID side-band event.
To check for the presence of that event in a PEBS-via-PT trace:

	perf script -D --no-itrace | grep PERF_RECORD_AUX_OUTPUT_HW_ID

To display PEBS events from the Intel PT trace, use the itrace 'o' option e.g.

	perf script --itrace=oe

XED
---

include::build-xed.txt[]


Tracing Virtual Machines (kernel only)
--------------------------------------

Currently, kernel tracing is supported with either "timeless" decoding
(i.e. no TSC timestamps) or VM Time Correlation. VM Time Correlation is an extra step
using 'perf inject' and requires unchanging VMX TSC Offset and no VMX TSC Scaling.

Other limitations and caveats

 VMX controls may suppress packets needed for decoding resulting in decoding errors
 VMX controls may block the perf NMI to the host potentially resulting in lost trace data
 Guest kernel self-modifying code (e.g. jump labels or JIT-compiled eBPF) will result in decoding errors
 Guest thread information is unknown
 Guest VCPU is unknown but may be able to be inferred from the host thread
 Callchains are not supported

Example using "timeless" decoding

Start VM

 $ sudo virsh start kubuntu20.04
 Domain kubuntu20.04 started

Mount the guest file system.  Note sshfs needs -o direct_io to enable reading of proc files.  root access is needed to read /proc/kcore.

 $ mkdir vm0
 $ sshfs -o direct_io root@vm0:/ vm0

Copy the guest /proc/kallsyms, /proc/modules and /proc/kcore

 $ perf buildid-cache -v --kcore vm0/proc/kcore
 kcore added to build-id cache directory /home/user/.debug/[kernel.kcore]/9600f316a53a0f54278885e8d9710538ec5f6a08/2021021807494306
 $ KALLSYMS=/home/user/.debug/[kernel.kcore]/9600f316a53a0f54278885e8d9710538ec5f6a08/2021021807494306/kallsyms

Find the VM process

 $ ps -eLl | grep 'KVM\|PID'
 F S   UID     PID    PPID     LWP  C PRI  NI ADDR SZ WCHAN  TTY          TIME CMD
 3 S 64055    1430       1    1440  1  80   0 - 1921718 -    ?        00:02:47 CPU 0/KVM
 3 S 64055    1430       1    1441  1  80   0 - 1921718 -    ?        00:02:41 CPU 1/KVM
 3 S 64055    1430       1    1442  1  80   0 - 1921718 -    ?        00:02:38 CPU 2/KVM
 3 S 64055    1430       1    1443  2  80   0 - 1921718 -    ?        00:03:18 CPU 3/KVM

Start an open-ended perf record, tracing the VM process, do something on the VM, and then ctrl-C to stop.
TSC is not supported and tsc=0 must be specified.  That means mtc is useless, so add mtc=0.
However, IPC can still be determined, hence cyc=1 can be added.
Only kernel decoding is supported, so 'k' must be specified.
Intel PT traces both the host and the guest so --guest and --host need to be specified.
Without timestamps, --per-thread must be specified to distinguish threads.

 $ sudo perf kvm --guest --host --guestkallsyms $KALLSYMS record --kcore -e intel_pt/tsc=0,mtc=0,cyc=1/k -p 1430 --per-thread
 ^C
 [ perf record: Woken up 1 times to write data ]
 [ perf record: Captured and wrote 5.829 MB ]

perf script can be used to provide an instruction trace

 $ perf script --guestkallsyms $KALLSYMS --insn-trace=disasm -F+ipc | grep -C10 vmresume | head -21
       CPU 0/KVM  1440  ffffffff82133cdd __vmx_vcpu_run+0x3d ([kernel.kallsyms])                movq  0x48(%rax), %r9
       CPU 0/KVM  1440  ffffffff82133ce1 __vmx_vcpu_run+0x41 ([kernel.kallsyms])                movq  0x50(%rax), %r10
       CPU 0/KVM  1440  ffffffff82133ce5 __vmx_vcpu_run+0x45 ([kernel.kallsyms])                movq  0x58(%rax), %r11
       CPU 0/KVM  1440  ffffffff82133ce9 __vmx_vcpu_run+0x49 ([kernel.kallsyms])                movq  0x60(%rax), %r12
       CPU 0/KVM  1440  ffffffff82133ced __vmx_vcpu_run+0x4d ([kernel.kallsyms])                movq  0x68(%rax), %r13
       CPU 0/KVM  1440  ffffffff82133cf1 __vmx_vcpu_run+0x51 ([kernel.kallsyms])                movq  0x70(%rax), %r14
       CPU 0/KVM  1440  ffffffff82133cf5 __vmx_vcpu_run+0x55 ([kernel.kallsyms])                movq  0x78(%rax), %r15
       CPU 0/KVM  1440  ffffffff82133cf9 __vmx_vcpu_run+0x59 ([kernel.kallsyms])                movq  (%rax), %rax
       CPU 0/KVM  1440  ffffffff82133cfc __vmx_vcpu_run+0x5c ([kernel.kallsyms])                callq  0xffffffff82133c40
       CPU 0/KVM  1440  ffffffff82133c40 vmx_vmenter+0x0 ([kernel.kallsyms])            jz 0xffffffff82133c46
       CPU 0/KVM  1440  ffffffff82133c42 vmx_vmenter+0x2 ([kernel.kallsyms])            vmresume         IPC: 0.11 (50/445)
           :1440  1440  ffffffffbb678b06 native_write_msr+0x6 ([guest.kernel.kallsyms])                 nopl  %eax, (%rax,%rax,1)
           :1440  1440  ffffffffbb678b0b native_write_msr+0xb ([guest.kernel.kallsyms])                 retq     IPC: 0.04 (2/41)
           :1440  1440  ffffffffbb666646 lapic_next_deadline+0x26 ([guest.kernel.kallsyms])             data16 nop
           :1440  1440  ffffffffbb666648 lapic_next_deadline+0x28 ([guest.kernel.kallsyms])             xor %eax, %eax
           :1440  1440  ffffffffbb66664a lapic_next_deadline+0x2a ([guest.kernel.kallsyms])             popq  %rbp
           :1440  1440  ffffffffbb66664b lapic_next_deadline+0x2b ([guest.kernel.kallsyms])             retq     IPC: 0.16 (4/25)
           :1440  1440  ffffffffbb74607f clockevents_program_event+0x8f ([guest.kernel.kallsyms])               test %eax, %eax
           :1440  1440  ffffffffbb746081 clockevents_program_event+0x91 ([guest.kernel.kallsyms])               jz 0xffffffffbb74603c    IPC: 0.06 (2/30)
           :1440  1440  ffffffffbb74603c clockevents_program_event+0x4c ([guest.kernel.kallsyms])               popq  %rbx
           :1440  1440  ffffffffbb74603d clockevents_program_event+0x4d ([guest.kernel.kallsyms])               popq  %r12

Example using VM Time Correlation

Start VM

 $ sudo virsh start kubuntu20.04
 Domain kubuntu20.04 started

Mount the guest file system.  Note sshfs needs -o direct_io to enable reading of proc files.  root access is needed to read /proc/kcore.

 $ mkdir -p vm0
 $ sshfs -o direct_io root@vm0:/ vm0

Copy the guest /proc/kallsyms, /proc/modules and /proc/kcore

 $ perf buildid-cache -v --kcore vm0/proc/kcore
 same kcore found in /home/user/.debug/[kernel.kcore]/cc9c55a98c5e4ec0aeda69302554aabed5cd6491/2021021312450777
 $ KALLSYMS=/home/user/.debug/\[kernel.kcore\]/cc9c55a98c5e4ec0aeda69302554aabed5cd6491/2021021312450777/kallsyms

Find the VM process

 $ ps -eLl | grep 'KVM\|PID'
 F S   UID     PID    PPID     LWP  C PRI  NI ADDR SZ WCHAN  TTY          TIME CMD
 3 S 64055   16998       1   17005 13  80   0 - 1818189 -    ?        00:00:16 CPU 0/KVM
 3 S 64055   16998       1   17006  4  80   0 - 1818189 -    ?        00:00:05 CPU 1/KVM
 3 S 64055   16998       1   17007  3  80   0 - 1818189 -    ?        00:00:04 CPU 2/KVM
 3 S 64055   16998       1   17008  4  80   0 - 1818189 -    ?        00:00:05 CPU 3/KVM

Start an open-ended perf record, tracing the VM process, do something on the VM, and then ctrl-C to stop.
IPC can be determined, hence cyc=1 can be added.
Only kernel decoding is supported, so 'k' must be specified.
Intel PT traces both the host and the guest so --guest and --host need to be specified.

 $ sudo perf kvm --guest --host --guestkallsyms $KALLSYMS record --kcore -e intel_pt/cyc=1/k -p 16998
 ^C[ perf record: Woken up 1 times to write data ]
 [ perf record: Captured and wrote 9.041 MB perf.data.kvm ]

Now 'perf inject' can be used to determine the VMX TCS Offset. Note, Intel PT TSC packets are
only 7-bytes, so the TSC Offset might differ from the actual value in the 8th byte. That will
have no effect i.e. the resulting timestamps will be correct anyway.

 $ perf inject -i perf.data.kvm --vm-time-correlation=dry-run
 ERROR: Unknown TSC Offset for VMCS 0x1bff6a
 VMCS: 0x1bff6a  TSC Offset 0xffffe42722c64c41
 ERROR: Unknown TSC Offset for VMCS 0x1cbc08
 VMCS: 0x1cbc08  TSC Offset 0xffffe42722c64c41
 ERROR: Unknown TSC Offset for VMCS 0x1c3ce8
 VMCS: 0x1c3ce8  TSC Offset 0xffffe42722c64c41
 ERROR: Unknown TSC Offset for VMCS 0x1cbce9
 VMCS: 0x1cbce9  TSC Offset 0xffffe42722c64c41

Each virtual CPU has a different Virtual Machine Control Structure (VMCS)
shown above with the calculated TSC Offset. For an unchanging TSC Offset
they should all be the same for the same virtual machine.

Now that the TSC Offset is known, it can be provided to 'perf inject'

 $ perf inject -i perf.data.kvm --vm-time-correlation="dry-run 0xffffe42722c64c41"

Note the options for 'perf inject' --vm-time-correlation are:

 [ dry-run ] [ <TSC Offset> [ : <VMCS> [ , <VMCS> ]... ]  ]...

So it is possible to specify different TSC Offsets for different VMCS.
The option "dry-run" will cause the file to be processed but without updating it.
Note it is also possible to get a intel_pt.log file by adding option --itrace=d

There were no errors so, do it for real

 $ perf inject -i perf.data.kvm --vm-time-correlation=0xffffe42722c64c41 --force

'perf script' can be used to see if there are any decoder errors

 $ perf script -i perf.data.kvm --guestkallsyms $KALLSYMS --itrace=e-o

There were none.

'perf script' can be used to provide an instruction trace showing timestamps

 $ perf script -i perf.data.kvm --guestkallsyms $KALLSYMS --insn-trace=disasm -F+ipc | grep -C10 vmresume | head -21
       CPU 1/KVM 17006 [001] 11500.262865593:  ffffffff82133cdd __vmx_vcpu_run+0x3d ([kernel.kallsyms])                 movq  0x48(%rax), %r9
       CPU 1/KVM 17006 [001] 11500.262865593:  ffffffff82133ce1 __vmx_vcpu_run+0x41 ([kernel.kallsyms])                 movq  0x50(%rax), %r10
       CPU 1/KVM 17006 [001] 11500.262865593:  ffffffff82133ce5 __vmx_vcpu_run+0x45 ([kernel.kallsyms])                 movq  0x58(%rax), %r11
       CPU 1/KVM 17006 [001] 11500.262865593:  ffffffff82133ce9 __vmx_vcpu_run+0x49 ([kernel.kallsyms])                 movq  0x60(%rax), %r12
       CPU 1/KVM 17006 [001] 11500.262865593:  ffffffff82133ced __vmx_vcpu_run+0x4d ([kernel.kallsyms])                 movq  0x68(%rax), %r13
       CPU 1/KVM 17006 [001] 11500.262865593:  ffffffff82133cf1 __vmx_vcpu_run+0x51 ([kernel.kallsyms])                 movq  0x70(%rax), %r14
       CPU 1/KVM 17006 [001] 11500.262865593:  ffffffff82133cf5 __vmx_vcpu_run+0x55 ([kernel.kallsyms])                 movq  0x78(%rax), %r15
       CPU 1/KVM 17006 [001] 11500.262865593:  ffffffff82133cf9 __vmx_vcpu_run+0x59 ([kernel.kallsyms])                 movq  (%rax), %rax
       CPU 1/KVM 17006 [001] 11500.262865593:  ffffffff82133cfc __vmx_vcpu_run+0x5c ([kernel.kallsyms])                 callq  0xffffffff82133c40
       CPU 1/KVM 17006 [001] 11500.262865593:  ffffffff82133c40 vmx_vmenter+0x0 ([kernel.kallsyms])             jz 0xffffffff82133c46
       CPU 1/KVM 17006 [001] 11500.262866075:  ffffffff82133c42 vmx_vmenter+0x2 ([kernel.kallsyms])             vmresume         IPC: 0.05 (40/769)
          :17006 17006 [001] 11500.262869216:  ffffffff82200cb0 asm_sysvec_apic_timer_interrupt+0x0 ([guest.kernel.kallsyms])           clac
          :17006 17006 [001] 11500.262869216:  ffffffff82200cb3 asm_sysvec_apic_timer_interrupt+0x3 ([guest.kernel.kallsyms])           pushq  $0xffffffffffffffff
          :17006 17006 [001] 11500.262869216:  ffffffff82200cb5 asm_sysvec_apic_timer_interrupt+0x5 ([guest.kernel.kallsyms])           callq  0xffffffff82201160
          :17006 17006 [001] 11500.262869216:  ffffffff82201160 error_entry+0x0 ([guest.kernel.kallsyms])               cld
          :17006 17006 [001] 11500.262869216:  ffffffff82201161 error_entry+0x1 ([guest.kernel.kallsyms])               pushq  %rsi
          :17006 17006 [001] 11500.262869216:  ffffffff82201162 error_entry+0x2 ([guest.kernel.kallsyms])               movq  0x8(%rsp), %rsi
          :17006 17006 [001] 11500.262869216:  ffffffff82201167 error_entry+0x7 ([guest.kernel.kallsyms])               movq  %rdi, 0x8(%rsp)
          :17006 17006 [001] 11500.262869216:  ffffffff8220116c error_entry+0xc ([guest.kernel.kallsyms])               pushq  %rdx
          :17006 17006 [001] 11500.262869216:  ffffffff8220116d error_entry+0xd ([guest.kernel.kallsyms])               pushq  %rcx
          :17006 17006 [001] 11500.262869216:  ffffffff8220116e error_entry+0xe ([guest.kernel.kallsyms])               pushq  %rax


Tracing Virtual Machines (including user space)
-----------------------------------------------

It is possible to use perf record to record sideband events within a virtual machine, so that an Intel PT trace on the host can be decoded.
Sideband events from the guest perf.data file can be injected into the host perf.data file using perf inject.

Here is an example of the steps needed:

On the guest machine:

Check that no-kvmclock kernel command line option was used to boot:

Note, this is essential to enable time correlation between host and guest machines.

 $ cat /proc/cmdline
 BOOT_IMAGE=/boot/vmlinuz-5.10.0-16-amd64 root=UUID=cb49c910-e573-47e0-bce7-79e293df8e1d ro no-kvmclock

There is no BPF support at present so, if possible, disable JIT compiling:

 $ echo 0 | sudo tee /proc/sys/net/core/bpf_jit_enable
 0

Start perf record to collect sideband events:

 $ sudo perf record -o guest-sideband-testing-guest-perf.data --sample-identifier --buildid-all --switch-events --kcore -a -e dummy

On the host machine:

Start perf record to collect Intel PT trace:

Note, the host trace will get very big, very fast, so the steps from starting to stopping the host trace really need to be done so that they happen in the shortest time possible.

 $ sudo perf record -o guest-sideband-testing-host-perf.data -m,64M --kcore -a -e intel_pt/cyc/

On the guest machine:

Run a small test case, just 'uname' in this example:

 $ uname
 Linux

On the host machine:

Stop the Intel PT trace:

 ^C
 [ perf record: Woken up 1 times to write data ]
 [ perf record: Captured and wrote 76.122 MB guest-sideband-testing-host-perf.data ]

On the guest machine:

Stop the Intel PT trace:

 ^C
 [ perf record: Woken up 1 times to write data ]
 [ perf record: Captured and wrote 1.247 MB guest-sideband-testing-guest-perf.data ]

And then copy guest-sideband-testing-guest-perf.data to the host (not shown here).

On the host machine:

With the 2 perf.data recordings, and with their ownership changed to the user.

Identify the TSC Offset:

 $ perf inject -i guest-sideband-testing-host-perf.data --vm-time-correlation=dry-run
 VMCS: 0x103fc6  TSC Offset 0xfffffa6ae070cb20
 VMCS: 0x103ff2  TSC Offset 0xfffffa6ae070cb20
 VMCS: 0x10fdaa  TSC Offset 0xfffffa6ae070cb20
 VMCS: 0x24d57c  TSC Offset 0xfffffa6ae070cb20

Correct Intel PT TSC timestamps for the guest machine:

 $ perf inject -i guest-sideband-testing-host-perf.data --vm-time-correlation=0xfffffa6ae070cb20 --force

Identify the guest machine PID:

 $ perf script -i guest-sideband-testing-host-perf.data --no-itrace --show-task-events | grep KVM
       CPU 0/KVM     0 [000]     0.000000: PERF_RECORD_COMM: CPU 0/KVM:13376/13381
       CPU 1/KVM     0 [000]     0.000000: PERF_RECORD_COMM: CPU 1/KVM:13376/13382
       CPU 2/KVM     0 [000]     0.000000: PERF_RECORD_COMM: CPU 2/KVM:13376/13383
       CPU 3/KVM     0 [000]     0.000000: PERF_RECORD_COMM: CPU 3/KVM:13376/13384

Note, the QEMU option -name debug-threads=on is needed so that thread names
can be used to determine which thread is running which VCPU as above. libvirt seems to use this by default.

Create a guestmount, assuming the guest machine is 'vm_to_test':

 $ mkdir -p ~/guestmount/13376
 $ sshfs -o direct_io vm_to_test:/ ~/guestmount/13376

Inject the guest perf.data file into the host perf.data file:

Note, due to the guestmount option, guest object files and debug files will be copied into the build ID cache from the guest machine, with the notable exception of VDSO.
If needed, VDSO can be copied manually in a fashion similar to that used by the perf-archive script.

 $ perf inject -i guest-sideband-testing-host-perf.data -o inj --guestmount ~/guestmount --guest-data=guest-sideband-testing-guest-perf.data,13376,0xfffffa6ae070cb20

Show an excerpt from the result.  In this case the CPU and time range have been to chosen to show interaction between guest and host when 'uname' is starting to run on the guest machine:

Notes:

	- the CPU displayed, [002] in this case, is always the host CPU
	- events happening in the virtual machine start with VM:13376 VCPU:003, which shows the hypervisor PID 13376 and the VCPU number
	- only calls and errors are displayed i.e. --itrace=ce
	- branches entering and exiting the virtual machine are split, and show as 2 branches to/from "0 [unknown] ([unknown])"

 $ perf script -i inj --itrace=ce -F+machine_pid,+vcpu,+addr,+pid,+tid,-period --ns --time 7919.408803365,7919.408804631 -C 2
       CPU 3/KVM 13376/13384 [002]  7919.408803365:      branches:  ffffffffc0f8ebe0 vmx_vcpu_enter_exit+0xc0 ([kernel.kallsyms]) => ffffffffc0f8edc0 __vmx_vcpu_run+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408803365:      branches:  ffffffffc0f8edd5 __vmx_vcpu_run+0x15 ([kernel.kallsyms]) => ffffffffc0f8eca0 vmx_update_host_rsp+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408803365:      branches:  ffffffffc0f8ee1b __vmx_vcpu_run+0x5b ([kernel.kallsyms]) => ffffffffc0f8ed60 vmx_vmenter+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408803461:      branches:  ffffffffc0f8ed62 vmx_vmenter+0x2 ([kernel.kallsyms]) =>                0 [unknown] ([unknown])
 VM:13376 VCPU:003            uname  3404/3404  [002]  7919.408803461:      branches:                 0 [unknown] ([unknown]) =>     7f851c9b5a5c init_cacheinfo+0x3ac (/usr/lib/x86_64-linux-gnu/libc-2.31.so)
 VM:13376 VCPU:003            uname  3404/3404  [002]  7919.408803567:      branches:      7f851c9b5a5a init_cacheinfo+0x3aa (/usr/lib/x86_64-linux-gnu/libc-2.31.so) =>                0 [unknown] ([unknown])
       CPU 3/KVM 13376/13384 [002]  7919.408803567:      branches:                 0 [unknown] ([unknown]) => ffffffffc0f8ed80 vmx_vmexit+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408803596:      branches:  ffffffffc0f6619a vmx_vcpu_run+0x26a ([kernel.kallsyms]) => ffffffffb2255c60 x86_virt_spec_ctrl+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408803801:      branches:  ffffffffc0f66445 vmx_vcpu_run+0x515 ([kernel.kallsyms]) => ffffffffb2290b30 native_write_msr+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408803850:      branches:  ffffffffc0f661f8 vmx_vcpu_run+0x2c8 ([kernel.kallsyms]) => ffffffffc1092300 kvm_load_host_xsave_state+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408803850:      branches:  ffffffffc1092327 kvm_load_host_xsave_state+0x27 ([kernel.kallsyms]) => ffffffffc1092220 kvm_load_host_xsave_state.part.0+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408803862:      branches:  ffffffffc0f662cf vmx_vcpu_run+0x39f ([kernel.kallsyms]) => ffffffffc0f63f90 vmx_recover_nmi_blocking+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408803862:      branches:  ffffffffc0f662e9 vmx_vcpu_run+0x3b9 ([kernel.kallsyms]) => ffffffffc0f619a0 __vmx_complete_interrupts+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408803872:      branches:  ffffffffc109cfb2 vcpu_enter_guest+0x752 ([kernel.kallsyms]) => ffffffffc0f5f570 vmx_handle_exit_irqoff+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408803881:      branches:  ffffffffc109d028 vcpu_enter_guest+0x7c8 ([kernel.kallsyms]) => ffffffffb234f900 __srcu_read_lock+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408803897:      branches:  ffffffffc109d06f vcpu_enter_guest+0x80f ([kernel.kallsyms]) => ffffffffc0f72e30 vmx_handle_exit+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408803897:      branches:  ffffffffc0f72e3d vmx_handle_exit+0xd ([kernel.kallsyms]) => ffffffffc0f727c0 __vmx_handle_exit+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408803897:      branches:  ffffffffc0f72b15 __vmx_handle_exit+0x355 ([kernel.kallsyms]) => ffffffffc0f60ae0 vmx_flush_pml_buffer+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408803903:      branches:  ffffffffc0f72994 __vmx_handle_exit+0x1d4 ([kernel.kallsyms]) => ffffffffc10b7090 kvm_emulate_cpuid+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408803903:      branches:  ffffffffc10b70f1 kvm_emulate_cpuid+0x61 ([kernel.kallsyms]) => ffffffffc10b6e10 kvm_cpuid+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408803941:      branches:  ffffffffc10b7125 kvm_emulate_cpuid+0x95 ([kernel.kallsyms]) => ffffffffc1093110 kvm_skip_emulated_instruction+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408803941:      branches:  ffffffffc109311f kvm_skip_emulated_instruction+0xf ([kernel.kallsyms]) => ffffffffc0f5e180 vmx_get_rflags+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408803951:      branches:  ffffffffc109312a kvm_skip_emulated_instruction+0x1a ([kernel.kallsyms]) => ffffffffc0f5fd30 vmx_skip_emulated_instruction+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408803951:      branches:  ffffffffc0f5fd79 vmx_skip_emulated_instruction+0x49 ([kernel.kallsyms]) => ffffffffc0f5fb50 skip_emulated_instruction+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408803956:      branches:  ffffffffc0f5fc68 skip_emulated_instruction+0x118 ([kernel.kallsyms]) => ffffffffc0f6a940 vmx_cache_reg+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408803964:      branches:  ffffffffc0f5fc11 skip_emulated_instruction+0xc1 ([kernel.kallsyms]) => ffffffffc0f5f9e0 vmx_set_interrupt_shadow+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408803980:      branches:  ffffffffc109f8b1 vcpu_run+0x71 ([kernel.kallsyms]) => ffffffffc10ad2f0 kvm_cpu_has_pending_timer+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408803980:      branches:  ffffffffc10ad2fb kvm_cpu_has_pending_timer+0xb ([kernel.kallsyms]) => ffffffffc10b0490 apic_has_pending_timer+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408803991:      branches:  ffffffffc109f899 vcpu_run+0x59 ([kernel.kallsyms]) => ffffffffc109c860 vcpu_enter_guest+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408803993:      branches:  ffffffffc109cd4c vcpu_enter_guest+0x4ec ([kernel.kallsyms]) => ffffffffc0f69140 vmx_prepare_switch_to_guest+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408803996:      branches:  ffffffffc109cd7d vcpu_enter_guest+0x51d ([kernel.kallsyms]) => ffffffffb234f930 __srcu_read_unlock+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408803996:      branches:  ffffffffc109cd9c vcpu_enter_guest+0x53c ([kernel.kallsyms]) => ffffffffc0f609b0 vmx_sync_pir_to_irr+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408803996:      branches:  ffffffffc0f60a6d vmx_sync_pir_to_irr+0xbd ([kernel.kallsyms]) => ffffffffc10adc20 kvm_lapic_find_highest_irr+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408804010:      branches:  ffffffffc0f60abd vmx_sync_pir_to_irr+0x10d ([kernel.kallsyms]) => ffffffffc0f60820 vmx_set_rvi+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408804019:      branches:  ffffffffc109ceca vcpu_enter_guest+0x66a ([kernel.kallsyms]) => ffffffffb2249840 fpregs_assert_state_consistent+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408804021:      branches:  ffffffffc109cf10 vcpu_enter_guest+0x6b0 ([kernel.kallsyms]) => ffffffffc0f65f30 vmx_vcpu_run+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408804024:      branches:  ffffffffc0f6603b vmx_vcpu_run+0x10b ([kernel.kallsyms]) => ffffffffb229bed0 __get_current_cr3_fast+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408804024:      branches:  ffffffffc0f66055 vmx_vcpu_run+0x125 ([kernel.kallsyms]) => ffffffffb2253050 cr4_read_shadow+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408804030:      branches:  ffffffffc0f6608d vmx_vcpu_run+0x15d ([kernel.kallsyms]) => ffffffffc10921e0 kvm_load_guest_xsave_state+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408804030:      branches:  ffffffffc1092207 kvm_load_guest_xsave_state+0x27 ([kernel.kallsyms]) => ffffffffc1092110 kvm_load_guest_xsave_state.part.0+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408804032:      branches:  ffffffffc0f660c6 vmx_vcpu_run+0x196 ([kernel.kallsyms]) => ffffffffb22061a0 perf_guest_get_msrs+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408804032:      branches:  ffffffffb22061a9 perf_guest_get_msrs+0x9 ([kernel.kallsyms]) => ffffffffb220cda0 intel_guest_get_msrs+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408804039:      branches:  ffffffffc0f66109 vmx_vcpu_run+0x1d9 ([kernel.kallsyms]) => ffffffffc0f652c0 clear_atomic_switch_msr+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408804040:      branches:  ffffffffc0f66119 vmx_vcpu_run+0x1e9 ([kernel.kallsyms]) => ffffffffc0f73f60 intel_pmu_lbr_is_enabled+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408804042:      branches:  ffffffffc0f73f81 intel_pmu_lbr_is_enabled+0x21 ([kernel.kallsyms]) => ffffffffc10b68e0 kvm_find_cpuid_entry+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408804045:      branches:  ffffffffc0f66454 vmx_vcpu_run+0x524 ([kernel.kallsyms]) => ffffffffc0f61ff0 vmx_update_hv_timer+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408804057:      branches:  ffffffffc0f66142 vmx_vcpu_run+0x212 ([kernel.kallsyms]) => ffffffffc10af100 kvm_wait_lapic_expire+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408804057:      branches:  ffffffffc0f66156 vmx_vcpu_run+0x226 ([kernel.kallsyms]) => ffffffffb2255c60 x86_virt_spec_ctrl+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408804057:      branches:  ffffffffc0f66161 vmx_vcpu_run+0x231 ([kernel.kallsyms]) => ffffffffc0f8eb20 vmx_vcpu_enter_exit+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408804057:      branches:  ffffffffc0f8eb44 vmx_vcpu_enter_exit+0x24 ([kernel.kallsyms]) => ffffffffb2353e10 rcu_note_context_switch+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408804057:      branches:  ffffffffb2353e1c rcu_note_context_switch+0xc ([kernel.kallsyms]) => ffffffffb2353db0 rcu_qs+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408804066:      branches:  ffffffffc0f8ebe0 vmx_vcpu_enter_exit+0xc0 ([kernel.kallsyms]) => ffffffffc0f8edc0 __vmx_vcpu_run+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408804066:      branches:  ffffffffc0f8edd5 __vmx_vcpu_run+0x15 ([kernel.kallsyms]) => ffffffffc0f8eca0 vmx_update_host_rsp+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408804066:      branches:  ffffffffc0f8ee1b __vmx_vcpu_run+0x5b ([kernel.kallsyms]) => ffffffffc0f8ed60 vmx_vmenter+0x0 ([kernel.kallsyms])
       CPU 3/KVM 13376/13384 [002]  7919.408804162:      branches:  ffffffffc0f8ed62 vmx_vmenter+0x2 ([kernel.kallsyms]) =>                0 [unknown] ([unknown])
 VM:13376 VCPU:003            uname  3404/3404  [002]  7919.408804162:      branches:                 0 [unknown] ([unknown]) =>     7f851c9b5a5c init_cacheinfo+0x3ac (/usr/lib/x86_64-linux-gnu/libc-2.31.so)
 VM:13376 VCPU:003            uname  3404/3404  [002]  7919.408804273:      branches:      7f851cb7c0e4 _dl_init+0x74 (/usr/lib/x86_64-linux-gnu/ld-2.31.so) =>     7f851cb7bf50 call_init.part.0+0x0 (/usr/lib/x86_64-linux-gnu/ld-2.31.so)
 VM:13376 VCPU:003            uname  3404/3404  [002]  7919.408804526:      branches:      55e0c00136f0 _start+0x0 (/usr/bin/uname) => ffffffff83200ac0 asm_exc_page_fault+0x0 ([kernel.kallsyms])
 VM:13376 VCPU:003            uname  3404/3404  [002]  7919.408804526:      branches:  ffffffff83200ac3 asm_exc_page_fault+0x3 ([kernel.kallsyms]) => ffffffff83201290 error_entry+0x0 ([kernel.kallsyms])
 VM:13376 VCPU:003            uname  3404/3404  [002]  7919.408804534:      branches:  ffffffff832012fa error_entry+0x6a ([kernel.kallsyms]) => ffffffff830b59a0 sync_regs+0x0 ([kernel.kallsyms])
 VM:13376 VCPU:003            uname  3404/3404  [002]  7919.408804631:      branches:  ffffffff83200ad9 asm_exc_page_fault+0x19 ([kernel.kallsyms]) => ffffffff830b8210 exc_page_fault+0x0 ([kernel.kallsyms])
 VM:13376 VCPU:003            uname  3404/3404  [002]  7919.408804631:      branches:  ffffffff830b82a4 exc_page_fault+0x94 ([kernel.kallsyms]) => ffffffff830b80e0 __kvm_handle_async_pf+0x0 ([kernel.kallsyms])
 VM:13376 VCPU:003            uname  3404/3404  [002]  7919.408804631:      branches:  ffffffff830b80ed __kvm_handle_async_pf+0xd ([kernel.kallsyms]) => ffffffff830b80c0 kvm_read_and_reset_apf_flags+0x0 ([kernel.kallsyms])


Tracing Virtual Machines - Guest Code
-------------------------------------

A common case for KVM test programs is that the test program acts as the
hypervisor, creating, running and destroying the virtual machine, and
providing the guest object code from its own object code. In this case,
the VM is not running an OS, but only the functions loaded into it by the
hypervisor test program, and conveniently, loaded at the same virtual
addresses. To support that, option "--guest-code" has been added to perf script
and perf kvm report.

Here is an example tracing a test program from the kernel's KVM selftests:

 # perf record --kcore -e intel_pt/cyc/ -- tools/testing/selftests/kselftest_install/kvm/tsc_msrs_test
 [ perf record: Woken up 1 times to write data ]
 [ perf record: Captured and wrote 0.280 MB perf.data ]
 # perf script --guest-code --itrace=bep --ns -F-period,+addr,+flags
 [SNIP]
   tsc_msrs_test 18436 [007] 10897.962087733:      branches:   call                   ffffffffc13b2ff5 __vmx_vcpu_run+0x15 (vmlinux) => ffffffffc13b2f50 vmx_update_host_rsp+0x0 (vmlinux)
   tsc_msrs_test 18436 [007] 10897.962087733:      branches:   return                 ffffffffc13b2f5d vmx_update_host_rsp+0xd (vmlinux) => ffffffffc13b2ffa __vmx_vcpu_run+0x1a (vmlinux)
   tsc_msrs_test 18436 [007] 10897.962087733:      branches:   call                   ffffffffc13b303b __vmx_vcpu_run+0x5b (vmlinux) => ffffffffc13b2f80 vmx_vmenter+0x0 (vmlinux)
   tsc_msrs_test 18436 [007] 10897.962087836:      branches:   vmentry                ffffffffc13b2f82 vmx_vmenter+0x2 (vmlinux) =>                0 [unknown] ([unknown])
   [guest/18436] 18436 [007] 10897.962087836:      branches:   vmentry                               0 [unknown] ([unknown]) =>           402c81 guest_code+0x131 (/home/user/git/work/tools/testing/selftests/kselftest_install/kvm/tsc_msrs_test)
   [guest/18436] 18436 [007] 10897.962087836:      branches:   call                             402c81 guest_code+0x131 (/home/user/git/work/tools/testing/selftests/kselftest_install/kvm/tsc_msrs_test) =>           40dba0 ucall+0x0 (/home/user/git/work/tools/testing/selftests/kselftest_install/kvm/tsc_msrs_test)
   [guest/18436] 18436 [007] 10897.962088248:      branches:   vmexit                           40dba0 ucall+0x0 (/home/user/git/work/tools/testing/selftests/kselftest_install/kvm/tsc_msrs_test) =>                0 [unknown] ([unknown])
   tsc_msrs_test 18436 [007] 10897.962088248:      branches:   vmexit                                0 [unknown] ([unknown]) => ffffffffc13b2fa0 vmx_vmexit+0x0 (vmlinux)
   tsc_msrs_test 18436 [007] 10897.962088248:      branches:   jmp                    ffffffffc13b2fa0 vmx_vmexit+0x0 (vmlinux) => ffffffffc13b2fd2 vmx_vmexit+0x32 (vmlinux)
   tsc_msrs_test 18436 [007] 10897.962088256:      branches:   return                 ffffffffc13b2fd2 vmx_vmexit+0x32 (vmlinux) => ffffffffc13b3040 __vmx_vcpu_run+0x60 (vmlinux)
   tsc_msrs_test 18436 [007] 10897.962088270:      branches:   return                 ffffffffc13b30b6 __vmx_vcpu_run+0xd6 (vmlinux) => ffffffffc13b2f2e vmx_vcpu_enter_exit+0x4e (vmlinux)
 [SNIP]
   tsc_msrs_test 18436 [007] 10897.962089321:      branches:   call                   ffffffffc13b2ff5 __vmx_vcpu_run+0x15 (vmlinux) => ffffffffc13b2f50 vmx_update_host_rsp+0x0 (vmlinux)
   tsc_msrs_test 18436 [007] 10897.962089321:      branches:   return                 ffffffffc13b2f5d vmx_update_host_rsp+0xd (vmlinux) => ffffffffc13b2ffa __vmx_vcpu_run+0x1a (vmlinux)
   tsc_msrs_test 18436 [007] 10897.962089321:      branches:   call                   ffffffffc13b303b __vmx_vcpu_run+0x5b (vmlinux) => ffffffffc13b2f80 vmx_vmenter+0x0 (vmlinux)
   tsc_msrs_test 18436 [007] 10897.962089424:      branches:   vmentry                ffffffffc13b2f82 vmx_vmenter+0x2 (vmlinux) =>                0 [unknown] ([unknown])
   [guest/18436] 18436 [007] 10897.962089424:      branches:   vmentry                               0 [unknown] ([unknown]) =>           40dba0 ucall+0x0 (/home/user/git/work/tools/testing/selftests/kselftest_install/kvm/tsc_msrs_test)
   [guest/18436] 18436 [007] 10897.962089701:      branches:   jmp                              40dc1b ucall+0x7b (/home/user/git/work/tools/testing/selftests/kselftest_install/kvm/tsc_msrs_test) =>           40dc39 ucall+0x99 (/home/user/git/work/tools/testing/selftests/kselftest_install/kvm/tsc_msrs_test)
   [guest/18436] 18436 [007] 10897.962089701:      branches:   jcc                              40dc3c ucall+0x9c (/home/user/git/work/tools/testing/selftests/kselftest_install/kvm/tsc_msrs_test) =>           40dc20 ucall+0x80 (/home/user/git/work/tools/testing/selftests/kselftest_install/kvm/tsc_msrs_test)
   [guest/18436] 18436 [007] 10897.962089701:      branches:   jcc                              40dc3c ucall+0x9c (/home/user/git/work/tools/testing/selftests/kselftest_install/kvm/tsc_msrs_test) =>           40dc20 ucall+0x80 (/home/user/git/work/tools/testing/selftests/kselftest_install/kvm/tsc_msrs_test)
   [guest/18436] 18436 [007] 10897.962089701:      branches:   jcc                              40dc37 ucall+0x97 (/home/user/git/work/tools/testing/selftests/kselftest_install/kvm/tsc_msrs_test) =>           40dc50 ucall+0xb0 (/home/user/git/work/tools/testing/selftests/kselftest_install/kvm/tsc_msrs_test)
   [guest/18436] 18436 [007] 10897.962089878:      branches:   vmexit                           40dc55 ucall+0xb5 (/home/user/git/work/tools/testing/selftests/kselftest_install/kvm/tsc_msrs_test) =>                0 [unknown] ([unknown])
   tsc_msrs_test 18436 [007] 10897.962089878:      branches:   vmexit                                0 [unknown] ([unknown]) => ffffffffc13b2fa0 vmx_vmexit+0x0 (vmlinux)
   tsc_msrs_test 18436 [007] 10897.962089878:      branches:   jmp                    ffffffffc13b2fa0 vmx_vmexit+0x0 (vmlinux) => ffffffffc13b2fd2 vmx_vmexit+0x32 (vmlinux)
   tsc_msrs_test 18436 [007] 10897.962089887:      branches:   return                 ffffffffc13b2fd2 vmx_vmexit+0x32 (vmlinux) => ffffffffc13b3040 __vmx_vcpu_run+0x60 (vmlinux)
   tsc_msrs_test 18436 [007] 10897.962089901:      branches:   return                 ffffffffc13b30b6 __vmx_vcpu_run+0xd6 (vmlinux) => ffffffffc13b2f2e vmx_vcpu_enter_exit+0x4e (vmlinux)
 [SNIP]

 # perf kvm --guest-code --guest --host report -i perf.data --stdio | head -20

 # To display the perf.data header info, please use --header/--header-only options.
 #
 #
 # Total Lost Samples: 0
 #
 # Samples: 12  of event 'instructions'
 # Event count (approx.): 2274583
 #
 # Children      Self  Command        Shared Object         Symbol
 # ........  ........  .............  ....................  ...........................................
 #
    54.70%     0.00%  tsc_msrs_test  [kernel.vmlinux]      [k] entry_SYSCALL_64_after_hwframe
            |
            ---entry_SYSCALL_64_after_hwframe
               do_syscall_64
               |
               |--29.44%--syscall_exit_to_user_mode
               |          exit_to_user_mode_prepare
               |          task_work_run
               |          __fput


Event Trace
-----------

Event Trace records information about asynchronous events, for example interrupts,
faults, VM exits and entries.  The information is recorded in CFE and EVD packets,
and also the Interrupt Flag is recorded on the MODE.Exec packet.  The CFE packet
contains a type field to identify one of the following:

	 1	INTR		interrupt, fault, exception, NMI
	 2	IRET		interrupt return
	 3	SMI		system management interrupt
	 4	RSM		resume from system management mode
	 5	SIPI		startup interprocessor interrupt
	 6	INIT		INIT signal
	 7	VMENTRY		VM-Entry
	 8	VMEXIT		VM-Entry
	 9	VMEXIT_INTR	VM-Exit due to interrupt
	10	SHUTDOWN	Shutdown

For more details, refer to the Intel 64 and IA-32 Architectures Software
Developer Manuals (version 076 or later).

The capability to do Event Trace is indicated by the
/sys/bus/event_source/devices/intel_pt/caps/event_trace file.

Event trace is selected for recording using the "event" config term. e.g.

	perf record -e intel_pt/event/u uname

Event trace events are output using the --itrace I option. e.g.

	perf script --itrace=Ie

perf script displays events containing CFE type, vector and event data,
in the form:

	  evt:   hw int            (t)  cfe: INTR IP: 1 vector: 3 PFA: 0x8877665544332211

The IP flag indicates if the event binds to an IP, which includes any case where
flow control packet generation is enabled, as well as when CFE packet IP bit is
set.

perf script displays events containing changes to the Interrupt Flag in the form:

	iflag:   t                      IFLAG: 1->0 via branch

where "via branch" indicates a branch (interrupt or return from interrupt) and
"non branch" indicates an instruction such as CFI, STI or POPF).

In addition, the current state of the interrupt flag is indicated by the presence
or absence of the "D" (interrupt disabled) perf script flag.  If the interrupt
flag is changed, then the "t" flag is also included i.e.

		no flag, interrupts enabled IF=1
	t	interrupts become disabled IF=1 -> IF=0
	D	interrupts are disabled IF=0
	Dt	interrupts become enabled  IF=0 -> IF=1

The intel-pt-events.py script illustrates how to access Event Trace information
using a Python script.


TNT Disable
-----------

TNT packets are disabled using the "notnt" config term. e.g.

	perf record -e intel_pt/notnt/u uname

In that case the --itrace q option is forced because walking executable code
to reconstruct the control flow is not possible.


Emulated PTWRITE
----------------

Later perf tools support a method to emulate the ptwrite instruction, which
can be useful if hardware does not support the ptwrite instruction.

Instead of using the ptwrite instruction, a function is used which produces
a trace that encodes the payload data into TNT packets.  Here is an example
of the function:

 #include <stdint.h>

 void perf_emulate_ptwrite(uint64_t x)
 __attribute__((externally_visible, noipa, no_instrument_function, naked));

 #define PERF_EMULATE_PTWRITE_8_BITS \
                 "1: shl %rax\n"     \
                 "   jc 1f\n"        \
                 "1: shl %rax\n"     \
                 "   jc 1f\n"        \
                 "1: shl %rax\n"     \
                 "   jc 1f\n"        \
                 "1: shl %rax\n"     \
                 "   jc 1f\n"        \
                 "1: shl %rax\n"     \
                 "   jc 1f\n"        \
                 "1: shl %rax\n"     \
                 "   jc 1f\n"        \
                 "1: shl %rax\n"     \
                 "   jc 1f\n"        \
                 "1: shl %rax\n"     \
                 "   jc 1f\n"

 /* Undefined instruction */
 #define PERF_EMULATE_PTWRITE_UD2        ".byte 0x0f, 0x0b\n"

 #define PERF_EMULATE_PTWRITE_MAGIC        PERF_EMULATE_PTWRITE_UD2 ".ascii \"perf,ptwrite  \"\n"

 void perf_emulate_ptwrite(uint64_t x __attribute__ ((__unused__)))
 {
          /* Assumes SysV ABI : x passed in rdi */
         __asm__ volatile (
                 "jmp 1f\n"
                 PERF_EMULATE_PTWRITE_MAGIC
                 "1: mov %rdi, %rax\n"
                 PERF_EMULATE_PTWRITE_8_BITS
                 PERF_EMULATE_PTWRITE_8_BITS
                 PERF_EMULATE_PTWRITE_8_BITS
                 PERF_EMULATE_PTWRITE_8_BITS
                 PERF_EMULATE_PTWRITE_8_BITS
                 PERF_EMULATE_PTWRITE_8_BITS
                 PERF_EMULATE_PTWRITE_8_BITS
                 PERF_EMULATE_PTWRITE_8_BITS
                 "1: ret\n"
         );
 }

For example, a test program with the function above:

 #include <stdio.h>
 #include <stdint.h>
 #include <stdlib.h>

 #include "perf_emulate_ptwrite.h"

 int main(int argc, char *argv[])
 {
         uint64_t x = 0;

         if (argc > 1)
                 x = strtoull(argv[1], NULL, 0);
         perf_emulate_ptwrite(x);
         return 0;
 }

Can be compiled and traced:

 $ gcc -Wall -Wextra -O3 -g -o eg_ptw eg_ptw.c
 $ perf record -e intel_pt//u ./eg_ptw 0x1234567890abcdef
 [ perf record: Woken up 1 times to write data ]
 [ perf record: Captured and wrote 0.017 MB perf.data ]
 $ perf script --itrace=ew
           eg_ptw 19875 [007]  8061.235912:     ptwrite:  IP: 0 payload: 0x1234567890abcdef      55701249a196 perf_emulate_ptwrite+0x16 (/home/user/eg_ptw)
 $


Pipe mode
---------
Pipe mode is a problem for Intel PT and possibly other auxtrace users.
It's not recommended to use a pipe as data output with Intel PT because
of the following reason.

Essentially the auxtrace buffers do not behave like the regular perf
event buffers.  That is because the head and tail are updated by
software, but in the auxtrace case the data is written by hardware.
So the head and tail do not get updated as data is written.

In the Intel PT case, the head and tail are updated only when the trace
is disabled by software, for example:
    - full-trace, system wide : when buffer passes watermark
    - full-trace, not system-wide : when buffer passes watermark or
                                    context switches
    - snapshot mode : as above but also when a snapshot is made
    - sample mode : as above but also when a sample is made

That means finished-round ordering doesn't work.  An auxtrace buffer
can turn up that has data that extends back in time, possibly to the
very beginning of tracing.

For a perf.data file, that problem is solved by going through the trace
and queuing up the auxtrace buffers in advance.

For pipe mode, the order of events and timestamps can presumably
be messed up.


Pause or Resume Tracing
-----------------------

With newer Kernels, it is possible to use other selected events to pause
or resume Intel PT tracing.  This is configured by using the "aux-action"
config term:

"aux-action=pause" is used with events that are to pause Intel PT tracing.

"aux-action=resume" is used with events that are to resume Intel PT tracing.

"aux-action=start-paused" is used with the Intel PT event to start in a
paused state.

For example, to trace only the uname system call (sys_newuname) when running the
command line utility uname:

 $ perf record --kcore -e intel_pt/aux-action=start-paused/k,syscalls:sys_enter_newuname/aux-action=resume/,syscalls:sys_exit_newuname/aux-action=pause/ uname
 Linux
 [ perf record: Woken up 1 times to write data ]
 [ perf record: Captured and wrote 0.043 MB perf.data ]
 $ perf script --call-trace
 uname   30805 [000] 24001.058782799: name: 0x7ffc9c1865b0
 uname   30805 [000] 24001.058784424:  psb offs: 0
 uname   30805 [000] 24001.058784424:  cbr: 39 freq: 3904 MHz (139%)
 uname   30805 [000] 24001.058784629: ([kernel.kallsyms])        debug_smp_processor_id
 uname   30805 [000] 24001.058784629: ([kernel.kallsyms])        __x64_sys_newuname
 uname   30805 [000] 24001.058784629: ([kernel.kallsyms])            down_read
 uname   30805 [000] 24001.058784629: ([kernel.kallsyms])                __cond_resched
 uname   30805 [000] 24001.058784629: ([kernel.kallsyms])                preempt_count_add
 uname   30805 [000] 24001.058784629: ([kernel.kallsyms])                    in_lock_functions
 uname   30805 [000] 24001.058784629: ([kernel.kallsyms])                preempt_count_sub
 uname   30805 [000] 24001.058784629: ([kernel.kallsyms])            up_read
 uname   30805 [000] 24001.058784629: ([kernel.kallsyms])                preempt_count_add
 uname   30805 [000] 24001.058784838: ([kernel.kallsyms])                    in_lock_functions
 uname   30805 [000] 24001.058784838: ([kernel.kallsyms])                preempt_count_sub
 uname   30805 [000] 24001.058784838: ([kernel.kallsyms])            _copy_to_user
 uname   30805 [000] 24001.058784838: ([kernel.kallsyms])        syscall_exit_to_user_mode
 uname   30805 [000] 24001.058784838: ([kernel.kallsyms])            syscall_exit_work
 uname   30805 [000] 24001.058784838: ([kernel.kallsyms])                perf_syscall_exit
 uname   30805 [000] 24001.058784838: ([kernel.kallsyms])                    debug_smp_processor_id
 uname   30805 [000] 24001.058785046: ([kernel.kallsyms])                    perf_trace_buf_alloc
 uname   30805 [000] 24001.058785046: ([kernel.kallsyms])                        perf_swevent_get_recursion_context
 uname   30805 [000] 24001.058785046: ([kernel.kallsyms])                            debug_smp_processor_id
 uname   30805 [000] 24001.058785046: ([kernel.kallsyms])                        debug_smp_processor_id
 uname   30805 [000] 24001.058785046: ([kernel.kallsyms])                    perf_tp_event
 uname   30805 [000] 24001.058785046: ([kernel.kallsyms])                        perf_trace_buf_update
 uname   30805 [000] 24001.058785046: ([kernel.kallsyms])                            tracing_gen_ctx_irq_test
 uname   30805 [000] 24001.058785046: ([kernel.kallsyms])                        perf_swevent_event
 uname   30805 [000] 24001.058785046: ([kernel.kallsyms])                            __perf_event_account_interrupt
 uname   30805 [000] 24001.058785046: ([kernel.kallsyms])                                __this_cpu_preempt_check
 uname   30805 [000] 24001.058785046: ([kernel.kallsyms])                            perf_event_output_forward
 uname   30805 [000] 24001.058785046: ([kernel.kallsyms])                                perf_event_aux_pause
 uname   30805 [000] 24001.058785046: ([kernel.kallsyms])                                    ring_buffer_get
 uname   30805 [000] 24001.058785046: ([kernel.kallsyms])                                        __rcu_read_lock
 uname   30805 [000] 24001.058785046: ([kernel.kallsyms])                                        __rcu_read_unlock
 uname   30805 [000] 24001.058785254: ([kernel.kallsyms])                                    pt_event_stop
 uname   30805 [000] 24001.058785254: ([kernel.kallsyms])                                        debug_smp_processor_id
 uname   30805 [000] 24001.058785254: ([kernel.kallsyms])                                        debug_smp_processor_id
 uname   30805 [000] 24001.058785254: ([kernel.kallsyms])                                        native_write_msr
 uname   30805 [000] 24001.058785463: ([kernel.kallsyms])                                        native_write_msr
 uname   30805 [000] 24001.058785639: 0x0

The example above uses tracepoints, but any kind of sampled event can be used.

For example:

 Tracing between arch_cpu_idle_enter() and arch_cpu_idle_exit() using breakpoint events:

 $ sudo cat /proc/kallsyms | sort | grep ' arch_cpu_idle_enter\| arch_cpu_idle_exit'
 ffffffffb605bf60 T arch_cpu_idle_enter
 ffffffffb614d8a0 W arch_cpu_idle_exit
 $ sudo perf record --kcore -a -e intel_pt/aux-action=start-paused/k -e mem:0xffffffffb605bf60:x/aux-action=resume/ -e mem:0xffffffffb614d8a0:x/aux-action=pause/ -- sleep 1
 [ perf record: Woken up 1 times to write data ]
 [ perf record: Captured and wrote 1.387 MB perf.data ]

 Tracing __alloc_pages() using kprobes:

 $ sudo perf probe --add '__alloc_pages order'
 Added new event:  probe:__alloc_pages  (on __alloc_pages with order)
 $ sudo perf probe --add __alloc_pages%return
 Added new event:  probe:__alloc_pages__return (on __alloc_pages%return)
 $ sudo perf record --kcore -aR -e intel_pt/aux-action=start-paused/k -e probe:__alloc_pages/aux-action=resume/ -e probe:__alloc_pages__return/aux-action=pause/ -- sleep 1
 [ perf record: Woken up 1 times to write data ]
 [ perf record: Captured and wrote 1.490 MB perf.data ]

 Tracing starting at main() using a uprobe event:

 $ sudo perf probe -x /usr/bin/uname main
 Added new event:  probe_uname:main     (on main in /usr/bin/uname)
 $ sudo perf record -e intel_pt/-aux-action=start-paused/u -e probe_uname:main/aux-action=resume/ -- uname
 Linux
 [ perf record: Woken up 1 times to write data ]
 [ perf record: Captured and wrote 0.031 MB perf.data ]

 Tracing occasionally using cycles events with different periods:

 $ perf record --kcore -a -m,64M -e intel_pt/aux-action=start-paused/k -e cycles/aux-action=pause,period=1000000/Pk -e cycles/aux-action=resume,period=10500000/Pk -- firefox
 [ perf record: Woken up 19 times to write data ]
 [ perf record: Captured and wrote 16.561 MB perf.data ]


EXAMPLE
-------

Examples can be found on perf wiki page "Perf tools support for Intel® Processor Trace":

https://perf.wiki.kernel.org/index.php/Perf_tools_support_for_Intel%C2%AE_Processor_Trace


SEE ALSO
--------

linkperf:perf-record[1], linkperf:perf-script[1], linkperf:perf-report[1],
linkperf:perf-inject[1]

```

## 20. perf-kmem.txt - Kernel Memory

```
perf-kmem(1)
============

NAME
----
perf-kmem - Tool to trace/measure kernel memory properties

SYNOPSIS
--------
[verse]
'perf kmem' [<options>] {record|stat}

DESCRIPTION
-----------
There are two variants of perf kmem:

  'perf kmem [<options>] record [<perf-record-options>] <command>' to
  record the kmem events of an arbitrary workload. Additional 'perf
  record' options may be specified after record, such as '-o' to
  change the output file name.

  'perf kmem [<options>] stat' to report kernel memory statistics.

OPTIONS
-------
-i <file>::
--input=<file>::
	For stat, select the input file (default: perf.data unless stdin is a
	fifo)

-f::
--force::
	Don't do ownership validation

-v::
--verbose::
        Be more verbose. (show symbol address, etc)

--caller::
	Show per-callsite statistics

--alloc::
	Show per-allocation statistics

-s <key[,key2...]>::
--sort=<key[,key2...]>::
	Sort the output (default: 'frag,hit,bytes' for slab and 'bytes,hit'
	for page).  Available sort keys are 'ptr, callsite, bytes, hit,
	pingpong, frag' for slab and 'page, callsite, bytes, hit, order,
	migtype, gfp' for page.  This option should be preceded by one of the
	mode selection options - i.e. --slab, --page, --alloc and/or --caller.

-l <num>::
--line=<num>::
	Print n lines only

--raw-ip::
	Print raw ip instead of symbol

--slab::
	Analyze SLAB allocator events.

--page::
	Analyze page allocator events

--live::
	Show live page stat.  The perf kmem shows total allocation stat by
	default, but this option shows live (currently allocated) pages
	instead.  (This option works with --page option only)

--time=<start>,<stop>::
	Only analyze samples within given time window: <start>,<stop>. Times
	have the format seconds.microseconds. If start is not given (i.e., time
	string is ',x.y') then analysis starts at the beginning of the file. If
	stop time is not given (i.e, time string is 'x.y,') then analysis goes
	to end of file.

SEE ALSO
--------
linkperf:perf-record[1]

```

## 21. perf-kwork.txt - Kernel Work

```
perf-kwork(1)
=============

NAME
----
perf-kwork - Tool to trace/measure kernel work properties (latencies)

SYNOPSIS
--------
[verse]
'perf kwork' {record|report|latency|timehist|top}

DESCRIPTION
-----------
There are several variants of 'perf kwork':

  'perf kwork record <command>' to record the kernel work
  of an arbitrary workload.

  'perf kwork report' to report the per kwork runtime.

  'perf kwork latency' to report the per kwork latencies.

  'perf kwork timehist' provides an analysis of kernel work events.

  'perf kwork top' to report the task cpu usage.

    Example usage:
        perf kwork record -- sleep 1
        perf kwork report
        perf kwork report -b
        perf kwork latency
        perf kwork latency -b
        perf kwork timehist
        perf kwork top
        perf kwork top -b

   By default it shows the individual work events such as irq, workqueue,
   including the run time and delay (time between raise and actually entry):

      Runtime start      Runtime end        Cpu     Kwork name                 Runtime     Delaytime
                                                    (TYPE)NAME:NUM             (msec)      (msec)
   -----------------  -----------------  ------  -------------------------  ----------  ----------
      1811186.976062     1811186.976327  [0000]  (s)RCU:9                        0.266       0.114
      1811186.978452     1811186.978547  [0000]  (s)SCHED:7                      0.095       0.171
      1811186.980327     1811186.980490  [0000]  (s)SCHED:7                      0.162       0.083
      1811186.981221     1811186.981271  [0000]  (s)SCHED:7                      0.050       0.077
      1811186.984267     1811186.984318  [0000]  (s)SCHED:7                      0.051       0.075
      1811186.987252     1811186.987315  [0000]  (s)SCHED:7                      0.063       0.081
      1811186.987785     1811186.987843  [0006]  (s)RCU:9                        0.058       0.645
      1811186.988319     1811186.988383  [0000]  (s)SCHED:7                      0.064       0.143
      1811186.989404     1811186.989607  [0002]  (s)TIMER:1                      0.203       0.111
      1811186.989660     1811186.989732  [0002]  (s)SCHED:7                      0.072       0.310
      1811186.991295     1811186.991407  [0002]  eth0:10                         0.112
      1811186.991639     1811186.991734  [0002]  (s)NET_RX:3                     0.095       0.277
      1811186.989860     1811186.991826  [0002]  (w)vmstat_shepherd              1.966       0.345
    ...

   Times are in msec.usec.

OPTIONS
-------
-D::
--dump-raw-trace=::
	Display verbose dump of the sched data.

-f::
--force::
	Don't complain, do it.

-k::
--kwork::
	List of kwork to profile (irq, softirq, workqueue, sched, etc)

-v::
--verbose::
	Be more verbose. (show symbol address, etc)

OPTIONS for 'perf kwork report'
----------------------------

-b::
--use-bpf::
	Use BPF to measure kwork runtime

-C::
--cpu::
	Only show events for the given CPU(s) (comma separated list).

-i::
--input::
	Input file name. (default: perf.data unless stdin is a fifo)

-n::
--name::
	Only show events for the given name.

-s::
--sort::
	Sort by key(s): runtime, max, count

-S::
--with-summary::
	Show summary with statistics

--time::
	Only analyze samples within given time window: <start>,<stop>. Times
	have the format seconds.microseconds. If start is not given (i.e., time
	string is ',x.y') then analysis starts at the beginning of the file. If
	stop time is not given (i.e, time string is 'x.y,') then analysis goes
	to end of file.

OPTIONS for 'perf kwork latency'
----------------------------

-b::
--use-bpf::
	Use BPF to measure kwork latency

-C::
--cpu::
	Only show events for the given CPU(s) (comma separated list).

-i::
--input::
	Input file name. (default: perf.data unless stdin is a fifo)

-n::
--name::
	Only show events for the given name.

-s::
--sort::
	Sort by key(s): avg, max, count

--time::
	Only analyze samples within given time window: <start>,<stop>. Times
	have the format seconds.microseconds. If start is not given (i.e., time
	string is ',x.y') then analysis starts at the beginning of the file. If
	stop time is not given (i.e, time string is 'x.y,') then analysis goes
	to end of file.

OPTIONS for 'perf kwork timehist'
---------------------------------

-C::
--cpu::
	Only show events for the given CPU(s) (comma separated list).

-g::
--call-graph::
	Display call chains if present (default off).

-i::
--input::
	Input file name. (default: perf.data unless stdin is a fifo)

-k::
--vmlinux=<file>::
	Vmlinux pathname

-n::
--name::
	Only show events for the given name.

--kallsyms=<file>::
	Kallsyms pathname

--max-stack::
	Maximum number of functions to display in backtrace, default 5.

--symfs=<directory>::
    Look for files with symbols relative to this directory.

--time::
	Only analyze samples within given time window: <start>,<stop>. Times
	have the format seconds.microseconds. If start is not given (i.e., time
	string is ',x.y') then analysis starts at the beginning of the file. If
	stop time is not given (i.e, time string is 'x.y,') then analysis goes
	to end of file.

OPTIONS for 'perf kwork top'
---------------------------------

-b::
--use-bpf::
	Use BPF to measure task cpu usage.

-C::
--cpu::
	Only show events for the given CPU(s) (comma separated list).

-i::
--input::
	Input file name. (default: perf.data unless stdin is a fifo)

-n::
--name::
	Only show events for the given name.

-s::
--sort::
	Sort by key(s): rate, runtime, tid

--time::
	Only analyze samples within given time window: <start>,<stop>. Times
	have the format seconds.microseconds. If start is not given (i.e., time
	string is ',x.y') then analysis starts at the beginning of the file. If
	stop time is not given (i.e, time string is 'x.y,') then analysis goes
	to end of file.

SEE ALSO
--------
linkperf:perf-record[1]

```

## 22. perf-diff.txt - Diff Profiles

```
perf-diff(1)
============

NAME
----
perf-diff - Read perf.data files and display the differential profile

SYNOPSIS
--------
[verse]
'perf diff' [baseline file] [data file1] [[data file2] ... ]

DESCRIPTION
-----------
This command displays the performance difference amongst two or more perf.data
files captured via perf record.

If no parameters are passed it will assume perf.data.old and perf.data.

The differential profile is displayed only for events matching both
specified perf.data files.

If no parameters are passed the samples will be sorted by dso and symbol.
As the perf.data files could come from different binaries, the symbols addresses
could vary. So perf diff is based on the comparison of the files and
symbols name.

OPTIONS
-------
-D::
--dump-raw-trace::
        Dump raw trace in ASCII.

--kallsyms=<file>::
        kallsyms pathname

-m::
--modules::
        Load module symbols. WARNING: use only with -k and LIVE kernel

-d::
--dsos=::
	Only consider symbols in these dsos. CSV that understands
	file://filename entries.  This option will affect the percentage
	of the Baseline/Delta column.  See --percentage for more info.

-C::
--comms=::
	Only consider symbols in these comms. CSV that understands
	file://filename entries.  This option will affect the percentage
	of the Baseline/Delta column.  See --percentage for more info.

-S::
--symbols=::
	Only consider these symbols. CSV that understands
	file://filename entries.  This option will affect the percentage
	of the Baseline/Delta column.  See --percentage for more info.

-s::
--sort=::
	Sort by key(s): pid, comm, dso, symbol, cpu, parent, srcline.
	Please see description of --sort in the perf-report man page.

-t::
--field-separator=::

	Use a special separator character and don't pad with spaces, replacing
	all occurrences of this separator in symbol names (and other output)
	with a '.' character, that thus it's the only non valid separator.

-v::
--verbose::
	Be verbose, for instance, show the raw counts in addition to the
	diff.

-q::
--quiet::
	Do not show any warnings or messages.  (Suppress -v)

-f::
--force::
        Don't do ownership validation.

--symfs=<directory>::
        Look for files with symbols relative to this directory.

-b::
--baseline-only::
        Show only items with match in baseline.

-c::
--compute::
        Differential computation selection - delta, ratio, wdiff, cycles,
        delta-abs (default is delta-abs).  Default can be changed using
        diff.compute config option.  See COMPARISON METHODS section for
        more info.

--cycles-hist::
	Report a histogram and the standard deviation for cycles data.
	It can help us to judge if the reported cycles data is noisy or
	not. This option should be used with '-c cycles'.

-p::
--period::
        Show period values for both compared hist entries.

-F::
--formula::
        Show formula for given computation.

-o::
--order::
       Specify compute sorting column number.  0 means sorting by baseline
       overhead and 1 (default) means sorting by computed value of column 1
       (data from the first file other base baseline).  Values more than 1
       can be used only if enough data files are provided.
       The default value can be set using the diff.order config option.

--percentage::
	Determine how to display the overhead percentage of filtered entries.
	Filters can be applied by --comms, --dsos and/or --symbols options.

	"relative" means it's relative to filtered entries only so that the
	sum of shown entries will be always 100%.  "absolute" means it retains
	the original value before and after the filter is applied.

--time::
	Analyze samples within given time window. It supports time
	percent with multiple time ranges. Time string is 'a%/n,b%/m,...'
	or 'a%-b%,c%-%d,...'.

	For example:

	Select the second 10% time slice to diff:

	  perf diff --time 10%/2

	Select from 0% to 10% time slice to diff:

	  perf diff --time 0%-10%

	Select the first and the second 10% time slices to diff:

	  perf diff --time 10%/1,10%/2

	Select from 0% to 10% and 30% to 40% slices to diff:

	  perf diff --time 0%-10%,30%-40%

	It also supports analyzing samples within a given time window
	<start>,<stop>. Times have the format seconds.nanoseconds. If 'start'
	is not given (i.e. time string is ',x.y') then analysis starts at
	the beginning of the file. If stop time is not given (i.e. time
	string is 'x.y,') then analysis goes to the end of the file.
	Multiple ranges can be separated by spaces, which requires the argument
	to be quoted e.g. --time "1234.567,1234.789 1235,"
	Time string is'a1.b1,c1.d1:a2.b2,c2.d2'. Use ':' to separate timestamps
	for different perf.data files.

	For example, we get the timestamp information from 'perf script'.

	  perf script -i perf.data.old
	    mgen 13940 [000]  3946.361400: ...

	  perf script -i perf.data
	    mgen 13940 [000]  3971.150589 ...

	  perf diff --time 3946.361400,:3971.150589,

	It analyzes the perf.data.old from the timestamp 3946.361400 to
	the end of perf.data.old and analyzes the perf.data from the
	timestamp 3971.150589 to the end of perf.data.

--cpu:: Only diff samples for the list of CPUs provided. Multiple CPUs can
	be provided as a comma-separated list with no space: 0,1. Ranges of
	CPUs are specified with -: 0-2. Default is to report samples on all
	CPUs.

--pid=::
	Only diff samples for given process ID (comma separated list).

--tid=::
	Only diff samples for given thread ID (comma separated list).

--stream::
	Enable hot streams comparison. Stream can be a callchain which is
	aggregated by the branch records from samples.

COMPARISON
----------
The comparison is governed by the baseline file. The baseline perf.data
file is iterated for samples. All other perf.data files specified on
the command line are searched for the baseline sample pair. If the pair
is found, specified computation is made and result is displayed.

All samples from non-baseline perf.data files, that do not match any
baseline entry, are displayed with empty space within baseline column
and possible computation results (delta) in their related column.

Example files samples:
- file A with samples f1, f2, f3, f4,    f6
- file B with samples     f2,     f4, f5
- file C with samples f1, f2,         f5

Example output:
  x - computation takes place for pair
  b - baseline sample percentage

- perf diff A B C

  baseline/A compute/B compute/C  samples
  ---------------------------------------
  b                    x          f1
  b          x         x          f2
  b                               f3
  b          x                    f4
  b                               f6
             x         x          f5

- perf diff B A C

  baseline/B compute/A compute/C  samples
  ---------------------------------------
  b          x         x          f2
  b          x                    f4
  b                    x          f5
             x         x          f1
             x                    f3
             x                    f6

- perf diff C B A

  baseline/C compute/B compute/A  samples
  ---------------------------------------
  b                    x          f1
  b          x         x          f2
  b          x                    f5
                       x          f3
             x         x          f4
                       x          f6

COMPARISON METHODS
------------------
delta
~~~~~
If specified the 'Delta' column is displayed with value 'd' computed as:

  d = A->period_percent - B->period_percent

with:
  - A/B being matching hist entry from data/baseline file specified
    (or perf.data/perf.data.old) respectively.

  - period_percent being the % of the hist entry period value within
    single data file

  - with filtering by -C, -d and/or -S, period_percent might be changed
    relative to how entries are filtered.  Use --percentage=absolute to
    prevent such fluctuation.

delta-abs
~~~~~~~~~
Same as 'delta` method, but sort the result with the absolute values.

ratio
~~~~~
If specified the 'Ratio' column is displayed with value 'r' computed as:

  r = A->period / B->period

with:
  - A/B being matching hist entry from data/baseline file specified
    (or perf.data/perf.data.old) respectively.

  - period being the hist entry period value

wdiff:WEIGHT-B,WEIGHT-A
~~~~~~~~~~~~~~~~~~~~~~~
If specified the 'Weighted diff' column is displayed with value 'd' computed as:

   d = B->period * WEIGHT-A - A->period * WEIGHT-B

  - A/B being matching hist entry from data/baseline file specified
    (or perf.data/perf.data.old) respectively.

  - period being the hist entry period value

  - WEIGHT-A/WEIGHT-B being user supplied weights in the '-c' option
    behind ':' separator like '-c wdiff:1,2'.
    - WEIGHT-A being the weight of the data file
    - WEIGHT-B being the weight of the baseline data file

cycles
~~~~~~
If specified the '[Program Block Range] Cycles Diff' column is displayed.
It displays the cycles difference of same program basic block amongst
two perf.data. The program basic block is the code between two branches.

'[Program Block Range]' indicates the range of a program basic block.
Source line is reported if it can be found otherwise uses symbol+offset
instead.

SEE ALSO
--------
linkperf:perf-record[1], linkperf:perf-report[1]

```

## 23. design.txt - Performance Counters Design

```

Performance Counters for Linux
------------------------------

Performance counters are special hardware registers available on most modern
CPUs. These registers count the number of certain types of hw events: such
as instructions executed, cachemisses suffered, or branches mis-predicted -
without slowing down the kernel or applications. These registers can also
trigger interrupts when a threshold number of events have passed - and can
thus be used to profile the code that runs on that CPU.

The Linux Performance Counter subsystem provides an abstraction of these
hardware capabilities. It provides per task and per CPU counters, counter
groups, and it provides event capabilities on top of those.  It
provides "virtual" 64-bit counters, regardless of the width of the
underlying hardware counters.

Performance counters are accessed via special file descriptors.
There's one file descriptor per virtual counter used.

The special file descriptor is opened via the sys_perf_event_open()
system call:

   int sys_perf_event_open(struct perf_event_attr *hw_event_uptr,
			     pid_t pid, int cpu, int group_fd,
			     unsigned long flags);

The syscall returns the new fd. The fd can be used via the normal
VFS system calls: read() can be used to read the counter, fcntl()
can be used to set the blocking mode, etc.

Multiple counters can be kept open at a time, and the counters
can be poll()ed.

When creating a new counter fd, 'perf_event_attr' is:

struct perf_event_attr {
        /*
         * The MSB of the config word signifies if the rest contains cpu
         * specific (raw) counter configuration data, if unset, the next
         * 7 bits are an event type and the rest of the bits are the event
         * identifier.
         */
        __u64                   config;

        __u64                   irq_period;
        __u32                   record_type;
        __u32                   read_format;

        __u64                   disabled       :  1, /* off by default        */
                                inherit        :  1, /* children inherit it   */
                                pinned         :  1, /* must always be on PMU */
                                exclusive      :  1, /* only group on PMU     */
                                exclude_user   :  1, /* don't count user      */
                                exclude_kernel :  1, /* ditto kernel          */
                                exclude_hv     :  1, /* ditto hypervisor      */
                                exclude_idle   :  1, /* don't count when idle */
                                mmap           :  1, /* include mmap data     */
                                munmap         :  1, /* include munmap data   */
                                comm           :  1, /* include comm data     */

                                __reserved_1   : 52;

        __u32                   extra_config_len;
        __u32                   wakeup_events;  /* wakeup every n events */

        __u64                   __reserved_2;
        __u64                   __reserved_3;
};

The 'config' field specifies what the counter should count.  It
is divided into 3 bit-fields:

raw_type: 1 bit   (most significant bit)	0x8000_0000_0000_0000
type:	  7 bits  (next most significant)	0x7f00_0000_0000_0000
event_id: 56 bits (least significant)		0x00ff_ffff_ffff_ffff

If 'raw_type' is 1, then the counter will count a hardware event
specified by the remaining 63 bits of event_config.  The encoding is
machine-specific.

If 'raw_type' is 0, then the 'type' field says what kind of counter
this is, with the following encoding:

enum perf_type_id {
	PERF_TYPE_HARDWARE		= 0,
	PERF_TYPE_SOFTWARE		= 1,
	PERF_TYPE_TRACEPOINT		= 2,
};

A counter of PERF_TYPE_HARDWARE will count the hardware event
specified by 'event_id':

/*
 * Generalized performance counter event types, used by the hw_event.event_id
 * parameter of the sys_perf_event_open() syscall:
 */
enum perf_hw_id {
	/*
	 * Common hardware events, generalized by the kernel:
	 */
	PERF_COUNT_HW_CPU_CYCLES		= 0,
	PERF_COUNT_HW_INSTRUCTIONS		= 1,
	PERF_COUNT_HW_CACHE_REFERENCES		= 2,
	PERF_COUNT_HW_CACHE_MISSES		= 3,
	PERF_COUNT_HW_BRANCH_INSTRUCTIONS	= 4,
	PERF_COUNT_HW_BRANCH_MISSES		= 5,
	PERF_COUNT_HW_BUS_CYCLES		= 6,
	PERF_COUNT_HW_STALLED_CYCLES_FRONTEND	= 7,
	PERF_COUNT_HW_STALLED_CYCLES_BACKEND	= 8,
	PERF_COUNT_HW_REF_CPU_CYCLES		= 9,
};

These are standardized types of events that work relatively uniformly
on all CPUs that implement Performance Counters support under Linux,
although there may be variations (e.g., different CPUs might count
cache references and misses at different levels of the cache hierarchy).
If a CPU is not able to count the selected event, then the system call
will return -EINVAL.

More hw_event_types are supported as well, but they are CPU-specific
and accessed as raw events.  For example, to count "External bus
cycles while bus lock signal asserted" events on Intel Core CPUs, pass
in a 0x4064 event_id value and set hw_event.raw_type to 1.

A counter of type PERF_TYPE_SOFTWARE will count one of the available
software events, selected by 'event_id':

/*
 * Special "software" counters provided by the kernel, even if the hardware
 * does not support performance counters. These counters measure various
 * physical and sw events of the kernel (and allow the profiling of them as
 * well):
 */
enum perf_sw_ids {
	PERF_COUNT_SW_CPU_CLOCK		= 0,
	PERF_COUNT_SW_TASK_CLOCK	= 1,
	PERF_COUNT_SW_PAGE_FAULTS	= 2,
	PERF_COUNT_SW_CONTEXT_SWITCHES	= 3,
	PERF_COUNT_SW_CPU_MIGRATIONS	= 4,
	PERF_COUNT_SW_PAGE_FAULTS_MIN	= 5,
	PERF_COUNT_SW_PAGE_FAULTS_MAJ	= 6,
	PERF_COUNT_SW_ALIGNMENT_FAULTS	= 7,
	PERF_COUNT_SW_EMULATION_FAULTS	= 8,
};

Counters of the type PERF_TYPE_TRACEPOINT are available when the ftrace event
tracer is available, and event_id values can be obtained from
/debug/tracing/events/*/*/id


Counters come in two flavours: counting counters and sampling
counters.  A "counting" counter is one that is used for counting the
number of events that occur, and is characterised by having
irq_period = 0.


A read() on a counter returns the current value of the counter and possible
additional values as specified by 'read_format', each value is a u64 (8 bytes)
in size.

/*
 * Bits that can be set in hw_event.read_format to request that
 * reads on the counter should return the indicated quantities,
 * in increasing order of bit value, after the counter value.
 */
enum perf_event_read_format {
        PERF_FORMAT_TOTAL_TIME_ENABLED  =  1,
        PERF_FORMAT_TOTAL_TIME_RUNNING  =  2,
};

Using these additional values one can establish the overcommit ratio for a
particular counter allowing one to take the round-robin scheduling effect
into account.


A "sampling" counter is one that is set up to generate an interrupt
every N events, where N is given by 'irq_period'.  A sampling counter
has irq_period > 0. The record_type controls what data is recorded on each
interrupt:

/*
 * Bits that can be set in hw_event.record_type to request information
 * in the overflow packets.
 */
enum perf_event_record_format {
        PERF_RECORD_IP          = 1U << 0,
        PERF_RECORD_TID         = 1U << 1,
        PERF_RECORD_TIME        = 1U << 2,
        PERF_RECORD_ADDR        = 1U << 3,
        PERF_RECORD_GROUP       = 1U << 4,
        PERF_RECORD_CALLCHAIN   = 1U << 5,
};

Such (and other) events will be recorded in a ring-buffer, which is
available to user-space using mmap() (see below).

The 'disabled' bit specifies whether the counter starts out disabled
or enabled.  If it is initially disabled, it can be enabled by ioctl
or prctl (see below).

The 'inherit' bit, if set, specifies that this counter should count
events on descendant tasks as well as the task specified.  This only
applies to new descendents, not to any existing descendents at the
time the counter is created (nor to any new descendents of existing
descendents).

The 'pinned' bit, if set, specifies that the counter should always be
on the CPU if at all possible.  It only applies to hardware counters
and only to group leaders.  If a pinned counter cannot be put onto the
CPU (e.g. because there are not enough hardware counters or because of
a conflict with some other event), then the counter goes into an
'error' state, where reads return end-of-file (i.e. read() returns 0)
until the counter is subsequently enabled or disabled.

The 'exclusive' bit, if set, specifies that when this counter's group
is on the CPU, it should be the only group using the CPU's counters.
In future, this will allow sophisticated monitoring programs to supply
extra configuration information via 'extra_config_len' to exploit
advanced features of the CPU's Performance Monitor Unit (PMU) that are
not otherwise accessible and that might disrupt other hardware
counters.

The 'exclude_user', 'exclude_kernel' and 'exclude_hv' bits provide a
way to request that counting of events be restricted to times when the
CPU is in user, kernel and/or hypervisor mode.

Furthermore the 'exclude_host' and 'exclude_guest' bits provide a way
to request counting of events restricted to guest and host contexts when
using Linux as the hypervisor.

The 'mmap' and 'munmap' bits allow recording of PROT_EXEC mmap/munmap
operations, these can be used to relate userspace IP addresses to actual
code, even after the mapping (or even the whole process) is gone,
these events are recorded in the ring-buffer (see below).

The 'comm' bit allows tracking of process comm data on process creation.
This too is recorded in the ring-buffer (see below).

The 'pid' parameter to the sys_perf_event_open() system call allows the
counter to be specific to a task:

 pid == 0: if the pid parameter is zero, the counter is attached to the
 current task.

 pid > 0: the counter is attached to a specific task (if the current task
 has sufficient privilege to do so)

 pid < 0: all tasks are counted (per cpu counters)

The 'cpu' parameter allows a counter to be made specific to a CPU:

 cpu >= 0: the counter is restricted to a specific CPU
 cpu == -1: the counter counts on all CPUs

(Note: the combination of 'pid == -1' and 'cpu == -1' is not valid.)

A 'pid > 0' and 'cpu == -1' counter is a per task counter that counts
events of that task and 'follows' that task to whatever CPU the task
gets schedule to. Per task counters can be created by any user, for
their own tasks.

A 'pid == -1' and 'cpu == x' counter is a per CPU counter that counts
all events on CPU-x. Per CPU counters need CAP_PERFMON or CAP_SYS_ADMIN
privilege.

The 'flags' parameter is currently unused and must be zero.

The 'group_fd' parameter allows counter "groups" to be set up.  A
counter group has one counter which is the group "leader".  The leader
is created first, with group_fd = -1 in the sys_perf_event_open call
that creates it.  The rest of the group members are created
subsequently, with group_fd giving the fd of the group leader.
(A single counter on its own is created with group_fd = -1 and is
considered to be a group with only 1 member.)

A counter group is scheduled onto the CPU as a unit, that is, it will
only be put onto the CPU if all of the counters in the group can be
put onto the CPU.  This means that the values of the member counters
can be meaningfully compared, added, divided (to get ratios), etc.,
with each other, since they have counted events for the same set of
executed instructions.


Like stated, asynchronous events, like counter overflow or PROT_EXEC mmap
tracking are logged into a ring-buffer. This ring-buffer is created and
accessed through mmap().

The mmap size should be 1+2^n pages, where the first page is a meta-data page
(struct perf_event_mmap_page) that contains various bits of information such
as where the ring-buffer head is.

/*
 * Structure of the page that can be mapped via mmap
 */
struct perf_event_mmap_page {
        __u32   version;                /* version number of this structure */
        __u32   compat_version;         /* lowest version this is compat with */

        /*
         * Bits needed to read the hw counters in user-space.
         *
         *   u32 seq;
         *   s64 count;
         *
         *   do {
         *     seq = pc->lock;
         *
         *     barrier()
         *     if (pc->index) {
         *       count = pmc_read(pc->index - 1);
         *       count += pc->offset;
         *     } else
         *       goto regular_read;
         *
         *     barrier();
         *   } while (pc->lock != seq);
         *
         * NOTE: for obvious reason this only works on self-monitoring
         *       processes.
         */
        __u32   lock;                   /* seqlock for synchronization */
        __u32   index;                  /* hardware counter identifier */
        __s64   offset;                 /* add to hardware counter value */

        /*
         * Control data for the mmap() data buffer.
         *
         * User-space reading this value should issue an rmb(), on SMP capable
         * platforms, after reading this value -- see perf_event_wakeup().
         */
        __u32   data_head;              /* head in the data section */
};

NOTE: the hw-counter userspace bits are arch specific and are currently only
      implemented on powerpc.

The following 2^n pages are the ring-buffer which contains events of the form:

#define PERF_RECORD_MISC_KERNEL          (1 << 0)
#define PERF_RECORD_MISC_USER            (1 << 1)
#define PERF_RECORD_MISC_OVERFLOW        (1 << 2)

struct perf_event_header {
        __u32   type;
        __u16   misc;
        __u16   size;
};

enum perf_event_type {

        /*
         * The MMAP events record the PROT_EXEC mappings so that we can
         * correlate userspace IPs to code. They have the following structure:
         *
         * struct {
         *      struct perf_event_header        header;
         *
         *      u32                             pid, tid;
         *      u64                             addr;
         *      u64                             len;
         *      u64                             pgoff;
         *      char                            filename[];
         * };
         */
        PERF_RECORD_MMAP                 = 1,
        PERF_RECORD_MUNMAP               = 2,

        /*
         * struct {
         *      struct perf_event_header        header;
         *
         *      u32                             pid, tid;
         *      char                            comm[];
         * };
         */
        PERF_RECORD_COMM                 = 3,

        /*
         * When header.misc & PERF_RECORD_MISC_OVERFLOW the event_type field
         * will be PERF_RECORD_*
         *
         * struct {
         *      struct perf_event_header        header;
         *
         *      { u64                   ip;       } && PERF_RECORD_IP
         *      { u32                   pid, tid; } && PERF_RECORD_TID
         *      { u64                   time;     } && PERF_RECORD_TIME
         *      { u64                   addr;     } && PERF_RECORD_ADDR
         *
         *      { u64                   nr;
         *        { u64 event, val; }   cnt[nr];  } && PERF_RECORD_GROUP
         *
         *      { u16                   nr,
         *                              hv,
         *                              kernel,
         *                              user;
         *        u64                   ips[nr];  } && PERF_RECORD_CALLCHAIN
         * };
         */
};

NOTE: PERF_RECORD_CALLCHAIN is arch specific and currently only implemented
      on x86.

Notification of new events is possible through poll()/select()/epoll() and
fcntl() managing signals.

Normally a notification is generated for every page filled, however one can
additionally set perf_event_attr.wakeup_events to generate one every
so many counter overflow events.

Future work will include a splice() interface to the ring-buffer.


Counters can be enabled and disabled in two ways: via ioctl and via
prctl.  When a counter is disabled, it doesn't count or generate
events but does continue to exist and maintain its count value.

An individual counter can be enabled with

	ioctl(fd, PERF_EVENT_IOC_ENABLE, 0);

or disabled with

	ioctl(fd, PERF_EVENT_IOC_DISABLE, 0);

For a counter group, pass PERF_IOC_FLAG_GROUP as the third argument.
Enabling or disabling the leader of a group enables or disables the
whole group; that is, while the group leader is disabled, none of the
counters in the group will count.  Enabling or disabling a member of a
group other than the leader only affects that counter - disabling an
non-leader stops that counter from counting but doesn't affect any
other counter.

Additionally, non-inherited overflow counters can use

	ioctl(fd, PERF_EVENT_IOC_REFRESH, nr);

to enable a counter for 'nr' events, after which it gets disabled again.

A process can enable or disable all the counter groups that are
attached to it, using prctl:

	prctl(PR_TASK_PERF_EVENTS_ENABLE);

	prctl(PR_TASK_PERF_EVENTS_DISABLE);

This applies to all counters on the current process, whether created
by this process or by another, and doesn't affect any counters that
this process has created on other processes.  It only enables or
disables the group leaders, not any other members in the groups.


Arch requirements
-----------------

If your architecture does not have hardware performance metrics, you can
still use the generic software counters based on hrtimers for sampling.

So to start with, in order to add HAVE_PERF_EVENTS to your Kconfig, you
will need at least this:
	- asm/perf_event.h - a basic stub will suffice at first
	- support for atomic64 types (and associated helper functions)

If your architecture does have hardware capabilities, you can override the
weak stub hw_perf_event_init() to register hardware counters.

Architectures that have d-cache aliassing issues, such as Sparc and ARM,
should select PERF_USE_VMALLOC in order to avoid these for perf mmap().

```


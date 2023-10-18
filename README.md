# Minimal Cylc Subworkflow Example

A subworkflow is a workflow executed by a task in another (main) workflow. 

Cylc does not have built-in support for subworkflows as such, but a Cylc task
can run anything, including another workflow.

The subworkflow source directory can be stored with the main workflow source.

```
main/
├── flow.cylc
├── bin/
├── apps/
├── ...
└── sub/
    ├── flow.cylc
    ├── bin/
    ├── apps/
    └── ...
```

At run time, the subworkflow definition instaled to the main run directory
should be used to create subworkflow instances, not the original source (just
as installed task definitions are used to create task instances at run time).

In a cycling main workflow, subworkflow instances must have unique names to
avoid a run directory clash, because they have to run as distinct workflows.

A good naming convention, unique across main workflow cycles and runs is:
```
<main-name>-<main-run>-<main-cycle>-<sub-name>
```
E.g., three cycles of a main workflow "nwp" running a subworkflow "sub" would
create the following run directories:
```
~/cylc-run/
└── nwp/
├── nwp-run1-1-sub/
├── nwp-run1-2-sub/
└── nwp-run1-3-sub/
```

## How to Run the Example

```console
# create the run directories as above:
~cylc-src/subworkflow $ cylc vip --workflow-name=nwp

# or hide them all under a "top" directory:
~cylc-src/subworkflow $ cylc vip --workflow-name=top/nwp
```

## Notes and Caveats

Subworkflows run as separate workflows so they have to be monitored and
controlled separately, and each instance generates a new run directory.

If your sub-workflow structure does not need to be dynamically configured
it is probably better to avoid these complications and just inline the
subworkflow graph into the main workflow.

This example runs subworkflows with `--no-detach` so that:
- subworkflow success and failure is registered automatically
- killing the main workflow task automatically kills its subworkflow

However, this means that `cylc play` can't launch the subworkflow scheduler
on a separate scheduler run host.

Detaching sub-workflows, on the other hand, need to be wrapped in a script
that polls them to detect completion.

If it is possible, because of optional graph branching, for the subworkflow
to successfully exit without running to completion, you may need a wrapper that
converts this kind of "success" to failure.

Reinstalling the main workflow will automatically reinstall the subworkflow
definition too (it if is stored with the main worklow), and new subworkflow
instances will automatically pick that up. If you need to update a running
subworkflow instance, that will require an additional reinstall command
targetting the instance.

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
E.g., 3 cycles of a main workflow "nwp" with subworkflow "sub" results in:
```
~/cylc-run/
└── nwp/
├── nwp-run1-1-sub/
├── nwp-run1-2-sub/
└── nwp-run1-3-sub/
```

## How to Run the Example

```console
# this creates the run directory structure as above:
~cylc-src/subworkflow $ cylc vip --workflow-name=nwp

# this hides them all under a "top" directory:
~cylc-src/subworkflow $ cylc vip --workflow-name=top/nwp
```

## Notes and Caveats

Subworkflows run as separate workflows so they have to be monitored and
controlled separately, and each instance generates a new run directory.

If your subworkflow structure is not dynamically determined then you
can avoid these complications and just inline it to the main workflow.

This example runs subworkflows with `--no-detach` so that:
- subworkflow success and failure is registered automatically
- killing the main workflow task automatically kills its subworkflow

However, this means that `cylc play` can't launch the subworkflow scheduler
on a separate scheduler run host.

Detaching sub-workflows, on the other hand, need to be wrapped in a script
that polls them to detect completion.

If optional graph branching makes it possible for the subworkflow to
successfully exit without running to completion, you may need a wrapper that
converts this kind of "success" into failure.

Reinstalling the main workflow will automatically reinstall the subworkflow
definition (it if is stored with the main worklow), and new subworkflow
instances will automatically pick that up. If you need to update a running
subworkflow instance, that will require an additional reinstall command
targetting the instance.

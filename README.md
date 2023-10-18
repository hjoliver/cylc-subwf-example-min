# Minimal Cylc Subworkflow Example

A subworkflow is a workflow executed by a task in another (main) workflow. 
Cylc does not have built-in support for this, but tasks can run anything,
including other workflows.

Subworkflow source directories can be stored with the main workflow:

```
~/cylc-src/main/
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

Subworkflow instances should be created (installed and played) on the fly at
run time from the installed subworkflow source in the main run directory
(just as installed task definitions are used to create task instances at run time).

Subworkflow instances at different main cycle points and runs must have unique
names to avoid run directory clashes, because they run as distinct workflows.
A good naming convention for subworkflows is:
```bash
<main-name>-<main-run>-<main-cycle>-<sub-name>
```
For three cycles of a main workflow "nwp" with subworkflow "sub" we get:
```
~/cylc-run/
└── nwp/run1/
├── nwp-run1-1-sub/
├── nwp-run1-2-sub/
└── nwp-run1-3-sub/
```

## How to Run the Example

```console
# this creates the run directory structure as above:
(in main src dir) $ cylc vip --workflow-name=nwp

# this hides them all under a "top" directory:
(in main src dir) $ cylc vip --workflow-name=top/nwp
```

## Notes and Caveats

Managing a system with subworkflows is somewhat more complicated, so
don't use subworkflows unless you really have to. If your subworkflow
structure does not need to be determined on the fly, it may be better
to integrate it into the main workflow. 

Subworkflows run as distinct workflows, and to the main workflow they are just
another task.
- each subworkflow instance generates a new run directory
- subworkflows have to be monitored and controlled separately
- in the UI, you can't descend directly from main to subworkflow (however the
  naming convention above at least groups them together in UI) 

This example runs subworkflows with `cylc play --no-detach` so that completion
is detected automatically and the subworkflow will be killed if the launcher
task gets killed. However, this means that `cylc play` can't launch the
subworkflow scheduler on a separate run host.

Detaching sub-workflows, on the other hand, need a wrapper to poll for
completion and kill them in response to a launcher task kill.

If optional graph branching makes it possible for a subworkflow to exit
successfully without actually running to completion, you may need a wrapper
that converts this kind of "success" into failure.

Reinstalling the main workflow automatically reinstalls the subworkflow
definition (it if is stored with the main worklow), and new subworkflow
instances will automatically pick up any changes. To update a running
subworkflow instance, do an additional reinstall that targets the instance.

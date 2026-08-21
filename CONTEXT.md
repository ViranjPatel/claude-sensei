# Lean Construction Harness

The domain this harness operates in: Last Planner System production planning and control, with VisiLean as the system of record. This glossary fixes the words; it is not a spec.

## Language

### Impediments

**Constraint**:
Anything that must be resolved before planned work can proceed. The only impediment type in this domain — there is no separate defect, non-conformance, or snag object.
_Avoid_: blocker, impediment, obstacle, NCR, snag, defect

**Constraint Issue**:
A Constraint that is actively impeding work already under way, rather than one threatening work not yet started. A flag on a Constraint, never a separate kind of thing.
_Avoid_: issue (unqualified)

**Owner**:
The actor accountable for resolving a Constraint.
_Avoid_: assignee, responsible party

**Author**:
The actor who raised a Constraint. Fixed at creation; distinct from Owner.
_Avoid_: reporter, creator, raiser

**On-time resolution**:
Whether a Constraint was closed by its due date. Recorded at the moment of closure and not recomputed afterwards.

### Planning

**Task**:
A unit of planned work. VisiLean names the same thing an *activity* when a Constraint refers to it; Task is the term used here.
_Avoid_: activity, job, work item, card

**Lookahead**:
The forward window, typically three to six weeks, over which Constraints are surfaced and removed.
_Avoid_: forecast, horizon, planning window

**Make-ready**:
The work of removing a Task's Constraints so it can be committed.
_Avoid_: preparation, grooming, readying

**Ready**:
A Task with no unresolved Constraints, eligible to be committed.

**Overridden Ready**:
A Task forced to Ready while Constraints remain outstanding. A deliberate, attributable human override — never something the harness does.

**Commitment**:
A Last Planner's promise that a Ready Task will be completed in the coming period. Only a human commits.
_Avoid_: assignment, booking, pledge

**PPC**:
Percent Plan Complete — the share of Commitments met in a period. The headline measure of planning reliability, and the outcome make-ready exists to protect.

### Place and responsibility

**Location**:
A named place in the project's spatial hierarchy, such as "Building B – Level 3".
_Avoid_: area, place, site

**Zone**:
A subdivision of a Location.
_Avoid_: sector, region, bay

**Trade**:
The discipline or subcontractor accountable for a Task or Constraint.
_Avoid_: crew, gang, discipline, subcontractor

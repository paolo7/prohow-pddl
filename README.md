# PDDL Translation of the PROHOW Data Model

The [PROHOW](https://w3id.org/prohow/) vocabulary and data model has been converted into the Planning Domain Definition Language (PDDL).

More information on this project can be found at this [homepage](http://homepages.inf.ed.ac.uk/s1054760/prohow/index.htm) or from this [publication](http://dx.doi.org/10.1007/978-3-319-13704-9_30) or 

## PDDL File Description

The `prohow.pddl` file contains a formalisation of this model as a planning domain definition and the file `prohow.problem` contains a toy example that can be used in conjunction with the planning domain.

## Planner for the the PROHOW-PDDL domain

These PDDL files have been used in conjunction with the [Fast-Downward](http://www.fast-downward.org) planner running the 'LAMA 2011 configuration' as folloiws:

```
./fast-downward.py --alias seq-sat-lama-2011 prohow.pddl prohow-problem.pddl
```

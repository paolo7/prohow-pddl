(define (domain prohow)

  (:requirements :strips :existential-preconditions :typing :equality)

  (:types task execution environment success failure finished primitive value)

  (:predicates 
  ; unary predicates
  (task ?x) (execution ?x) (environment ?x) (success ?x) (failure ?x) (finished ?x) (primitive ?x) (active ?x)
  ; binary predicates
  (requires ?x ?y) (requires_one ?y ?x) (has_step ?y ?x) (has_method ?y ?x) (has_task ?y ?x) (has_goal ?y ?x) (binds ?y ?x) (has_constant ?y ?x) (has_value ?y ?x)  (has_env ?y ?x) (sub_env ?y ?x) (complete ?y ?x)  (failed ?y ?x)  (ready ?y ?x)  (related ?y ?x) (infer_active ?x)
  ; ternary predicates
  (value ?y ?x ?z) 
  )

  (:action accomplish_task
    :parameters (?t - task ?e - environment ?i - execution)
    :precondition (and 
        (primitive ?t)
        (ready ?t ?e)
        (not
          (exists (?x)
            (has_task ?i ?x)
          )
        )
        (not
          (exists (?x)
            (has_env ?i ?x)
          )
        )
      )
    :effect (and
      (success ?i)
      (has_env ?i ?e)
      (has_task ?i ?t)
    )
  )
  
  (:action instantiate_sub_env
    :parameters (?e - environment ?a - environment ?t - task ?m - task)
    :precondition(and
      (has_method ?t ?m)
      (not (= ?e ?a))
      (not
        (exists (?x)
          (sub_env ?e ?x)
        )
      )
      (not
        (exists (?x)
          (has_goal ?e ?x)
        )
      )
    )
    :effect (and
        (sub_env ?e ?a)
        (has_goal ?e ?t)
      )
  )
  
  (:action infer_active
    :parameters (?e - environment)
    :precondition (and 
      (exists (?g) (has_goal ?e ?g))
      (or (not (exists (?a) (sub_env ?e ?a)))
        (exists (?a ?x) 
          (and 
            (sub_env ?e ?a)
            (has_goal ?e ?x)
            (ready ?x ?a)
            (active ?a)
          )
        )
      )
    )
    :effect (active ?e)
  )  
  
  (:action infer_complete
    :parameters (?y - task ?e - environment)
    :precondition (exists (?i)
      (and
        (has_env ?i ?e)
        (has_task ?i ?y)
        (success ?i)
      )
    )
    :effect (complete ?y ?e)
  )
  
  (:action infer_failed
    :parameters (?y - task ?e - environment)
    :precondition (exists (?i)
      (and
        (has_env ?i ?e)
        (has_task ?i ?y)
        (failure ?i)
      )
    )
    :effect (failed ?y ?e)
  )
  
  (:action infer_finished
    :parameters (?e - environment)
    :precondition (exists (?g)
      (and
        (has_goal ?e ?g)
        (complete ?g ?e)
      )
    )
    :effect (finished ?e)
  )
  
  
  (:action infer_complete_by_steps
    :parameters (?y - task ?e - environment)
    :precondition 
    (and
      (exists (?x)
        (has_step ?y ?x)
      )
      (not
        (exists (?x)
          (and 
            (has_step ?y ?x)
            (not 
                (complete ?x ?e)
            )
          )
        )
      )
    )
    :effect (complete ?y ?e)
  )  
  
  (:action infer_ready
    :parameters (?y - task ?e - environment)
    :precondition (and
      (active ?e)
      (or 
        (not
          (exists (?x)
            (has_step ?x ?y)
          )
        )
        (exists (?x)
          (and 
            (has_step ?x ?y)
            (ready ?x ?e)
          )
        )
      )
      (or
        (not 
          (exists (?x)
            (or
              (requires ?y ?x)
              (requires_one ?y ?x)
            )
          )
        )
        (and
          (exists (?x) (requires ?y ?x))
          (not 
            (exists (?x)
              (and
                (requires ?y ?x)
                (not (complete ?x ?e))
              )
            )
          )
        )
        (exists (?x)
            (and
              (requires_one ?y ?x)
              (complete ?x ?e)
            )
        )
      )
    )
    :effect (ready ?y ?e)
  )
  
  (:action infer_complete_by_method
    :parameters (?y - task ?e - environment)
    :precondition (exists (?x)
      (and
        (has_goal ?e ?y)
        (has_method ?y ?x)
        (complete ?x ?e)
      )
    )
    :effect (complete ?y ?e)
  )  
  
  (:action infer_complete_by_sub_env
    :parameters (?y - task ?e - environment)
    :precondition (and
      (ready ?y ?e)
      (exists (?a)
        (and
          (complete ?y ?a)
          (sub_env ?a ?e)
          (has_goal ?a ?y)
        )
      )
    )
    :effect (complete ?y ?e)
  )  
  
  (:action infer_related
    :parameters (?a - environment ?e - environment)
    :precondition (or
      (= ?a ?e)
      (sub_env ?a ?e)
      (sub_env ?e ?a)
      (exists (?x)
        (and
          (related ?a ?x)
          (related ?x ?e)
        )
      )
    )
    :effect (related ?a ?e)
  )
  
  (:action infer_value
    :parameters (?z - value ?y - task ?e - environment)
    :precondition (exists (?i)
      (and
        (has_env ?i ?e)
        (has_task ?i ?y)
        (success ?i)
        (has_value ?i ?z)
      )
    )
    :effect (value ?z ?y ?e)
  )
  
  (:action infer_complete_by_binding
    :parameters (?x - task ?e - environment)
    :precondition (and
      (ready ?x ?e)
      (exists (?y ?a)
        (and
          (binds ?x ?y)
          (complete ?y ?a)
          (related ?a ?e)
        )
      )
    )
    :effect (complete ?x ?e)
  )
  
  (:action infer_value_from_binding
    :parameters (?z - value ?x - task ?e - environment)
    :precondition (and
      (ready ?x ?e)
      (exists (?y ?a)
        (and
          (binds ?x ?y)
          (value ?z ?y ?a)
          (related ?a ?e)
        )
      )
    )
    :effect (value ?z ?x ?e)
  )
  
  (:action infer_complete_from_constant
    :parameters (?x - task ?e - environment)
    :precondition (exists (?i ?y)
      (and
        (has_env ?i ?e)
        (has_task ?i ?y)
        (has_constant ?y ?x)
      )
    )
    :effect (and 
      (complete ?x ?e)
      (value ?x ?x ?e)
    )
  )
)



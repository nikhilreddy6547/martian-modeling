extensions[csv]
globals
[
  data
  file
  prev-income-mean
  income-mean
  depreciation
  mu-constant
  income-d
  income-var
  earth
  mars
  inflation-amp
  inflation-period
  inflation-amp-2
  inflation-period-2
  inflation-constant
  prob-4-job
  prob-6-job
  prob-8-job
  available-jobs
  labor-force
  census
  income-file
  population
  total-inflation
  government-debt
  bracket-1
  bracket-2
  bracket-3
  bracket-4
  bracket-5
  tax-rate-1
  tax-rate-2
  tax-rate-3
  tax-rate-4
  tax-rate-5
]
turtles-own
[
  age
  job
  working?
  education
  student?
  sex
  on-leave
  income
  lifestage; 0 if infant, 1 if student, 2 if college, 3 if adult, 4 if retired, sendng primarly 3's, age limit for initial populations
  time-in-job
  growth-rate
  percentile
  underemployed?
  baby-cooldown
  num-babies
  innovator
  experience
  death
  gross-income
]
patches-own[; TO DO Set num-babies per women to 2.4
            ; TO DO Set taxes and taxation to nice values
            ; TO DO SET minimum wage, welfare, social security


]
;breed[mouse mice]
to toggle
  if (mouse-down?)[

  ]
end

to read
  file-close-all
  file-open "datas.csv"
  set data []
  let data-row []
  while [not file-at-end?] [
    set data-row csv:from-row file-read-line
    set data lput data-row data
  ]
  file-close-all
  file-open readfile
  set population []
  set data-row []
  while [not file-at-end?] [
    set data-row csv:from-row file-read-line
    set population lput data-row population
  ]
  file-close-all
  file-open "earth.csv"
  set earth []
  set data-row []
  while [not file-at-end?][
    set data-row csv:from-row file-read-line
    set earth lput data-row earth
  ]
  process
end
to process
  set file
  n-values 22 [
    [arg] ->
    (list (item 0 (item arg data)) (item 1 (item arg data)) (item 2 (item arg data)) (item 3 (item arg data)) (item 4 (item arg data)) (item 5 (item arg data)) (item 6 (item arg data)) (item 8 (item arg data)) (item 7 (item arg data)) (item 10 (item arg data)) (item 12 (item arg data)) 0 arg (item 13 item arg data))
  ];        NAME                          A_MEAN                 A_10                    A_25                        A_50                  A_75                     A_90                          A_rate                 8  work force              9   work force rate         10 education       laborers id    INNOVATOR V. PRODUCER
  set population bf population
  set population map [[pop]->(list read-sex item 1 pop ((item 2 pop) + random-float 1) item 3 pop) ] population
  ;                                M/F                 AGE                                JOB
  set earth map [[a]->(list round (item 0 a * item 1 a) item 1 a)] earth
end
to setup
  clear-all
  reset-ticks
  import-drawing "mars.png"
  read
  set bracket-1 minimum-wage
  set bracket-2 round ((minimum-wage + income-mean) / 2)
  set bracket-3 income-mean
  set bracket-4 555000
  set bracket-5 775000
  set tax-rate-1 tax-rate / 6
  set tax-rate-2 tax-rate / 5
  set tax-rate-3 tax-rate / 4
  set tax-rate-4 tax-rate / 3
  set tax-rate-5 tax-rate / 2
  set total-inflation 1
  set mu-constant 1
  set income-d 0.55
  set inflation-period 20
  set inflation-constant 0.008
  set inflation-amp 0.0025
  set inflation-amp-2 0.0005
  set inflation-period-2 1
  set-default-shape turtles "person"
  set available-jobs [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]
  set mars n-values 22 [
    [arg]->
    [0 0]
  ]
  set prob-4-job 0.49106860 + 0.197240345 + 0.03564114 + 0.038122
  set prob-6-job 0.197240345 + 0.03564114 + 0.038122
  set prob-8-job 0.03564114 + 0.038122
  set-census
  let rr length filter [[arg]->(not (item 2 arg = -1)) and item 1 arg < 70 and item 1 arg >= 18] population
  set available-jobs map [[arg]-> arg * rr] census
  foreach population [
    [arg]->
    crt 1 [
      setxy random-xcor random-ycor
      set size 0.35
      set color green + 1
      set age item 1 arg
      set sex item 0 arg
      set student? false
      set underemployed? false
      set death abs (200 - random-gamma 1000 10)
      set on-leave 0
      set baby-cooldown 0
      set num-babies 0
      ifelse((not (item 2 arg = -1)) and item 1 arg < 70 and item 1 arg >= 18)[
        set lifestage 3
        set education item 10 item item 2 arg file
        ifelse(item item 2 arg available-jobs > 0)[
          set available-jobs replace-item item 2 arg available-jobs ((item item 2 arg available-jobs) - 1)
          set job item 2 arg
          set working? true
          set innovator item 13 item job file;TODO give innovator when jobs are assigned, check for other 63's
          set time-in-job 0
          set percentile 10
          set growth-rate random-normal (4.65) .4
          let ar item job file
          set file replace-item item 12 ar file replace-item 11 ar ((item 11 ar) + 1)
          set labor-force labor-force + 1
          ifelse(sex = "female")[
            set mars replace-item job mars (list ((item 0 item job mars) + 1) ((item 1 item job mars) + 1))
          ][
            set mars replace-item job mars (list (item 0 item job mars) ((item 1 item job mars) + 1))
          ]
        ]
        [
          set working? false
        ]
      ][
        set working? false
        if(item 1 arg >= 70)[
          set lifestage 4
        ]
        if(item 1 arg < 5)[
          set lifestage 0
        ]
        if(item 1 arg < 18 and item 1 arg >= 5)[
          set lifestage 1
        ]
        if(item 1 arg >= 18 and item 1 arg < 70)[
          set lifestage 2
          set student? true
        ]
      ]
    ]
  ]
  set labor-force count turtles with [working?]
  set-census
  set-available-jobs
  set-income-file
  ask turtles[
    set percentile (min (list 90 (5 + random 11 + (max (list 0 (age - 20))) * growth-rate))) - growth-rate / ticks-per-year
    grow-income
  ]
  set income-mean (sum [income] of (turtles with [working? and on-leave <= 0])) / (count turtles with [lifestage = 3])
  set prev-income-mean 1
  set income-var (standard-deviation [income] of turtles) / income-mean
end
to set-census
  let s sum map [[arg] -> item 8 arg * (item 9 arg) ^ (80 + ticks / ticks-per-year)] file
  set census map [[arg] -> item 8 arg * (item 9 arg) ^ (80 + ticks / ticks-per-year) / s] file
end
to set-available-jobs
  set available-jobs map [[arg]-> round ((count turtles with [lifestage = 3] + (count turtles with [student?] / 2 / ticks-per-year)) * item (item 12 arg) census - item 11 arg)] file
end
to go
  if(ticks >= stop-time)[
    stop
  ]
  set-census
  if(abs (ticks / ticks-per-year - round ticks / ticks-per-year) < 0.0001)[
    set-income-file
  ]
  ;if(abs ( 4 * ticks / ticks-per-year - round 4 * ticks / ticks-per-year) < 0.0001)[
    set-available-jobs
  ;]
  set-inflation
  ask turtles[
    if(working?)[;10 @ 25, 25 @ 35, 50 @ 45, 75 @ 55, 90 @ 65
      set time-in-job time-in-job + 1 / ticks-per-year
      set experience experience + 1 / ticks-per-year
      lose-job
      ;Add welfare + minimum-wagw
    ]
    set-education
    set-age
    grow-income
    adjust-income
    create-babies
    if (age >= death)[
      if(working?)[
        retire
      ]
      die
    ]
  ]
  set prev-income-mean income-mean
  set income-mean (sum [income] of (turtles with [working? and on-leave <= 0])) / (count turtles with [lifestage = 3])
  set income-var (standard-deviation [income] of turtles with [working?]) / income-mean
  set-government-debt
  tick
end
to lose-job
  if(random-float 1 < 1 - (1 - 0.02) ^ (1 / ticks-per-year))[
    set working? false
    set underemployed? false
    set income 0
    set file replace-item job file replace-item 11 item job file ((item 11 item job file) - 1)
    set labor-force labor-force - 1
    set available-jobs replace-item job available-jobs ((item job available-jobs) + 1)
    ifelse(sex = "female")[
      set mars replace-item job mars (list ((item 0 item job mars) - 1) ((item 1 item job mars) - 1))
    ][
      set mars replace-item job mars (list (item 0 item job mars) ((item 1 item job mars) - 1))
    ]
    set job 0
  ]
end
to-report baby-constant
  report baby-constant-final * min (list 20 ((ticks) / ticks-per-year)) / 20
end
to-report baby-prob [b n]
  let a floor b
  report baby-constant * (a / 6 - 3) / ((a / 6 - 4) ^ 2 + 1) / (n + 1)
end; TODO
to-report read-sex [hi]
  if(hi = 1)[
    report "male"
  ]
  report "female"
end
to create-babies
  ifelse(sex = "male" and on-leave > 0)[
    set on-leave on-leave - 12
  ][
    set on-leave 0
  ]
  if (sex = "female" and age >= 18 and age < 50)[
    ifelse(baby-cooldown > 0)[
      set baby-cooldown baby-cooldown - 1
      if((baby-cooldown + 1) * 4 > 5 * ticks-per-year and baby-cooldown * 4 <= 5 * ticks-per-year)[
        hatch 1 [
          set student? false
          set age random-float (1 / ticks-per-year)
          set baby-cooldown 0
          set working? false
          set sex read-sex random 2
          set lifestage 0
          set underemployed? false
          set num-babies 0
          setxy random-xcor random-ycor
          set death abs (200 - random-gamma 1000 10)
          set income 0
          set baby-cooldown 0
          set experience 0
          set on-leave 0
          set job 0
          set education 0
          set time-in-job 0
          set growth-rate 0
          set percentile 10
          set innovator ifelse-value (random-float 1 < 0.1)
          [1][0]
        ]
        set num-babies num-babies + 1
      ]
      ifelse(on-leave > 0)[
        set on-leave on-leave - 12
      ][
        set on-leave 0
      ]
      if((baby-cooldown + 1) * 12 > ticks-per-year * 17 and baby-cooldown * 12 <= ticks-per-year * 17)[
        set on-leave ((maternity-leave) * ticks-per-year) - 1
      ]
      if(on-leave < 0 and sex = "female")[
        set on-leave 0
        ask one-of turtles with [sex = "male" and abs (age - [age] of myself) <= 5 and on-leave <= 0][
          set on-leave (ticks-per-year * paternity-leave) - 1
        ]
      ]
    ][
      if(random-float 1 < 1 - (1 - (baby-prob age num-babies))^(1 / ticks-per-year))[
        set baby-cooldown 2 * ticks-per-year
      ]
    ]
  ]
end
to set-income-file
  set income-file n-values 22 [
    [arg] ->
    (list (item 0 (item arg file)) ((item 1 (item arg file))* (item 7 item arg file) ^ (85 + ticks / ticks-per-year)) ((item 2 item arg file) * (item 7 item arg file) ^ (85 + ticks / ticks-per-year)) ((item 3 item arg file) * (item 7 item arg file) ^ (80 + ticks / ticks-per-year)) ((item 4 item arg file) * (item 7 item arg file) ^ (85 + ticks / ticks-per-year)) ((item 5 item arg file) * (item 7 item arg file) ^ (80 + ticks / ticks-per-year)) ((item 6 item arg file) * (item 7 item arg file) ^ (85 + ticks / ticks-per-year)))
  ]
end
to set-education
  if(age < 18 - 0.0001 and age + 1 / ticks-per-year >= 18 - 0.0001 and not student?)[
    set student? true
    set education 0
  ]
  if(student?)[
    if(education < 2 - 0.0001 and education + 1 / ticks-per-year >= 2 - 0.0001)[
      set education education + 1 / ticks-per-year
      check-job
      stop
    ]
    if(education < 4 - 0.0001 and education + 1 / ticks-per-year >= 4 - 0.0001)[
      set education education + 1 / ticks-per-year
      check-job
      stop
    ]
    if(education < 6 - 0.0001 and education + 1 / ticks-per-year >= 6 - 0.0001)[
      set education education + 1 / ticks-per-year
      check-job
      stop
    ]
    if(education < 8 - 0.0001 and education + 1 / ticks-per-year >= 8 - 0.0001)[
      set education education + 1 / ticks-per-year
      check-job
      stop
    ]
    set education education + 1 / ticks-per-year
  ]
  if(((not working?) or underemployed?) and lifestage = 3 and age + 1 / ticks-per-year < 70; and abs (2 * ticks / ticks-per-year - round 2 * ticks / ticks-per-year) < 0.0001
    )[
    check-job
  ]
end
to check-job
  let grow random-normal (4.65) .4
  if(round education = 2)[
    foreach file [
      [arg]->
      if( item 10 arg = 2 and item item 12 arg available-jobs > 0 and ((not underemployed?) or item 10 item job file < 2))[
        ifelse(sex = "female" and random-float 1 < 0.25) or (sex = "male" and random-float 1 < 0.07)[
          if(working?)[
            set labor-force labor-force - 1
            set file replace-item job file replace-item 11 item job file ((item 11 item job file) - 1)
            set available-jobs replace-item job available-jobs ((item job available-jobs) - 1)
            ifelse(sex = "female")[
              set mars replace-item job mars (list ((item 0 item job mars) - 1) ((item 1 item job mars) - 1))
            ][
              set mars replace-item job mars (list (item 0 item job mars) ((item 1 item job mars) - 1))
            ]
          ]
          set working? false
          set student? false
          set underemployed? false
          set lifestage 4
          stop
        ][
          if(working?)[
            set labor-force labor-force - 1
            set file replace-item job file replace-item 11 item job file ((item 11 item job file) - 1)
            set available-jobs replace-item job available-jobs ((item job available-jobs) - 1)
            ifelse(sex = "female")[
              set mars replace-item job mars (list ((item 0 item job mars) - 1) ((item 1 item job mars) - 1))
            ][
              set mars replace-item job mars (list (item 0 item job mars) ((item 1 item job mars) - 1))
            ]
          ]
          set job item 12 arg
          set working? true
          set student? false
          set file replace-item item 12 arg file replace-item 11 arg (item 11 arg + 1)
          set labor-force labor-force + 1
          set available-jobs replace-item (item 12 arg) available-jobs ((item (item 12 arg) available-jobs) - 1)
          set time-in-job 0
          set underemployed? false
          set growth-rate grow
          set percentile 10 + random (skew * 2 - 20)
          set innovator item 13 item job file
          ifelse(sex = "female")[
            set mars replace-item job mars (list ((item 0 item job mars) + 1) ((item 1 item job mars) + 1))
          ][
            set mars replace-item job mars (list (item 0 item job mars) ((item 1 item job mars) + 1))
          ]
          stop
        ]
      ]
    ]
    if(random-float 1 > prob-4-job and not underemployed?)[
      if(working?)[
        set labor-force labor-force - 1
        set file replace-item job file replace-item 11 item job file ((item 11 item job file) - 1)
        set available-jobs replace-item job available-jobs ((item job available-jobs) - 1)
        ifelse(sex = "female")[
          set mars replace-item job mars (list ((item 0 item job mars) - 1) ((item 1 item job mars) - 1))
        ][
          set mars replace-item job mars (list (item 0 item job mars) ((item 1 item job mars) - 1))
        ]
      ]
      set working? false
      set student? false
      set underemployed? false
    ]
    ; TO DO:  FAMILIES
  ]
  if(round education = 4)[
    foreach file [
      [arg]->
      if( item 10 arg = 4 and item item 12 arg available-jobs > 0 and ((not underemployed?) or item 10 item job file < 4))[
        ifelse(sex = "female" and random-float 1 < 0.19) or (sex = "male" and random-float 1 < 0.03)[
          if(working?)[
            set labor-force labor-force - 1
            set file replace-item job file replace-item 11 item job file ((item 11 item job file) - 1)
            set available-jobs replace-item job available-jobs ((item job available-jobs) - 1)
            ifelse(sex = "female")[
              set mars replace-item job mars (list ((item 0 item job mars) - 1) ((item 1 item job mars) - 1))
            ][
              set mars replace-item job mars (list (item 0 item job mars) ((item 1 item job mars) - 1))
            ]
          ]
          set working? false
          set student? false
          set underemployed? false
          set lifestage 4
          stop
        ][
          if(working?)[
            set labor-force labor-force - 1
            set file replace-item job file replace-item 11 item job file ((item 11 item job file) - 1)
            set available-jobs replace-item job available-jobs ((item job available-jobs) - 1)
            ifelse(sex = "female")[
              set mars replace-item job mars (list ((item 0 item job mars) - 1) ((item 1 item job mars) - 1))
            ][
              set mars replace-item job mars (list (item 0 item job mars) ((item 1 item job mars) - 1))
            ]
          ]
          set job item 12 arg
          set working? true
          set student? false
          set file replace-item item 12 arg file replace-item 11 arg (item 11 arg + 1)
          set labor-force labor-force + 1
          set available-jobs replace-item item 12 arg available-jobs (item item 12 arg available-jobs - 1)
          set time-in-job 0
          set underemployed? false
          set growth-rate grow
          set percentile 10 + random (skew * 2 - 20)
          set innovator item 13 item job file
          ifelse(sex = "female")[
            set mars replace-item job mars (list ((item 0 item job mars) + 1) ((item 1 item job mars) + 1))
          ][
            set mars replace-item job mars (list (item 0 item job mars) ((item 1 item job mars) + 1))
          ]
          stop
        ]
      ]
    ]
    if(not working?)[
      foreach file [
        [arg]->
        if( item 10 arg = 2 and item item 12 arg available-jobs > 0 and ((not underemployed?) or item 10 item job file < 2))[
          ifelse(sex = "female" and random-float 1 < 0.19) or (sex = "male" and random-float 1 < 0.03)[
            if(working?)[
              set labor-force labor-force - 1
              set file replace-item job file replace-item 11 item job file ((item 11 item job file) - 1)
              set available-jobs replace-item job available-jobs ((item job available-jobs) - 1)
              ifelse(sex = "female")[
                set mars replace-item job mars (list ((item 0 item job mars) - 1) ((item 1 item job mars) - 1))
              ][
                set mars replace-item job mars (list (item 0 item job mars) ((item 1 item job mars) - 1))
              ]
            ]
            set working? false
            set student? false
            set underemployed? false
            set lifestage 4
            stop
          ][
            if(working?)[
              set labor-force labor-force - 1
              set file replace-item job file replace-item 11 item job file ((item 11 item job file) - 1)
              set available-jobs replace-item job available-jobs ((item job available-jobs) - 1)
              ifelse(sex = "female")[
                set mars replace-item job mars (list ((item 0 item job mars) - 1) ((item 1 item job mars) - 1))
              ][
                set mars replace-item job mars (list (item 0 item job mars) ((item 1 item job mars) - 1))
              ]
            ]
            set job item 12 arg
            set working? true
            set student? false
            set file replace-item item 12 arg file replace-item 11 arg (item 11 arg + 1)
            set labor-force labor-force + 1
            set available-jobs replace-item item 12 arg available-jobs (item item 12 arg available-jobs - 1)
            set time-in-job 0
            set underemployed? true
            set growth-rate grow + 0.1
            set percentile 10 + random (skew * 2 - 20)
            set innovator item 13 item job file
            ifelse(sex = "female")[
              set mars replace-item job mars (list ((item 0 item job mars) + 1) ((item 1 item job mars) + 1))
            ][
              set mars replace-item job mars (list (item 0 item job mars) ((item 1 item job mars) + 1))
            ]
            stop
          ]
        ]
      ]
    ]
    if(random-float prob-4-job > prob-6-job and not underemployed?)[
      if(working?)[
        set labor-force labor-force - 1
        set file replace-item job file replace-item 11 item job file ((item 11 item job file) - 1)
        set available-jobs replace-item job available-jobs ((item job available-jobs) - 1)
        ifelse(sex = "female")[
          set mars replace-item job mars (list ((item 0 item job mars) - 1) ((item 1 item job mars) - 1))
        ][
          set mars replace-item job mars (list (item 0 item job mars) ((item 1 item job mars) - 1))
        ]
      ]
      set working? false
      set student? false
      set underemployed? false
    ]
  ]
  if(round education = 6)[
    foreach file [
      [arg]->
      if( item 10 arg = 6 and item item 12 arg available-jobs > 0 and ((not underemployed?) or item 10 item job file < 6))[
        ifelse(sex = "female" and random-float 1 < .09) or (sex = "male" and random-float 1 < 0.02)[
          if(working?)[
            set labor-force labor-force - 1
            set file replace-item job file replace-item 11 item job file ((item 11 item job file) - 1)
            set available-jobs replace-item job available-jobs ((item job available-jobs) - 1)
            ifelse(sex = "female")[
              set mars replace-item job mars (list ((item 0 item job mars) - 1) ((item 1 item job mars) - 1))
            ][
              set mars replace-item job mars (list (item 0 item job mars) ((item 1 item job mars) - 1))
            ]
          ]
          set working? false
          set student? false
          set underemployed? false
          set lifestage 4
          stop
        ][
          if(working?)[
            set labor-force labor-force - 1
            set file replace-item job file replace-item 11 item job file ((item 11 item job file) - 1)
            set available-jobs replace-item job available-jobs ((item job available-jobs) - 1)
            ifelse(sex = "female")[
              set mars replace-item job mars (list ((item 0 item job mars) - 1) ((item 1 item job mars) - 1))
            ][
              set mars replace-item job mars (list (item 0 item job mars) ((item 1 item job mars) - 1))
            ]
          ]
          set job item 12 arg
          set working? true
          set student? false
          set file replace-item item 12 arg file replace-item 11 arg (item 11 arg + 1)
          set labor-force labor-force + 1
          set available-jobs replace-item item 12 arg available-jobs (item item 12 arg available-jobs - 1)
          set time-in-job 0
          set underemployed? false
          set growth-rate grow
          set percentile 10 + random (skew * 2 - 20)
          set innovator item 13 item job file
          ifelse(sex = "female")[
            set mars replace-item job mars (list ((item 0 item job mars) + 1) ((item 1 item job mars) + 1))
          ][
            set mars replace-item job mars (list (item 0 item job mars) ((item 1 item job mars) + 1))
          ]
          stop
        ]
      ]
    ]
    if(not working?)[
      foreach file [
        [arg]->
        if( item 10 arg = 4 and item item 12 arg available-jobs > 0  and ((not underemployed?) or item 10 item job file < 4))[
          ifelse(sex = "female" and random-float 1 < .09) or (sex = "male" and random-float 1 < 0.02)[
            if(working?)[
              set labor-force labor-force - 1
              set file replace-item job file replace-item 11 item job file ((item 11 item job file) - 1)
              set available-jobs replace-item job available-jobs ((item job available-jobs) - 1)
              ifelse(sex = "female")[
                set mars replace-item job mars (list ((item 0 item job mars) - 1) ((item 1 item job mars) - 1))
              ][
                set mars replace-item job mars (list (item 0 item job mars) ((item 1 item job mars) - 1))
              ]
            ]
            set working? false
            set student? false
            set underemployed? false
            set lifestage 4
            stop
          ][
            if(working?)[
              set labor-force labor-force - 1
              set file replace-item job file replace-item 11 item job file ((item 11 item job file) - 1)
              set available-jobs replace-item job available-jobs ((item job available-jobs) - 1)
              ifelse(sex = "female")[
                set mars replace-item job mars (list ((item 0 item job mars) - 1) ((item 1 item job mars) - 1))
              ][
                set mars replace-item job mars (list (item 0 item job mars) ((item 1 item job mars) - 1))
              ]
            ]
            set job item 12 arg
            set working? true
            set student? false
            set file replace-item item 12 arg file replace-item 11 arg (item 11 arg + 1)
            set labor-force labor-force + 1
            set available-jobs replace-item item 12 arg available-jobs (item item 12 arg available-jobs - 1)
            set time-in-job 0
            set underemployed? true
            set growth-rate grow + 0.1
            set percentile 10 + random (skew * 2 - 20)
            set innovator item 13 item job file
            ifelse(sex = "female")[
              set mars replace-item job mars (list ((item 0 item job mars) + 1) ((item 1 item job mars) + 1))
            ][
              set mars replace-item job mars (list (item 0 item job mars) ((item 1 item job mars) + 1))
            ]
            stop
          ]
        ]
      ]
    ]
    if(not working?)[
      foreach file [
        [arg]->
        if( item 10 arg = 2 and item item 12 arg available-jobs > 0  and ((not underemployed?) or item 10 item job file < 2))[
          ifelse(sex = "female" and random-float 1 < .09) or (sex = "male" and random-float 1 < 0.02)[
            if(working?)[
              set labor-force labor-force - 1
              set file replace-item job file replace-item 11 item job file ((item 11 item job file) - 1)
              set available-jobs replace-item job available-jobs ((item job available-jobs) - 1)
              ifelse(sex = "female")[
                set mars replace-item job mars (list ((item 0 item job mars) - 1) ((item 1 item job mars) - 1))
              ][
                set mars replace-item job mars (list (item 0 item job mars) ((item 1 item job mars) - 1))
              ]
            ]
            set working? false
            set student? false
            set underemployed? false
            set lifestage 4
            stop
          ][
            if(working?)[
              set labor-force labor-force - 1
              set file replace-item job file replace-item 11 item job file ((item 11 item job file) - 1)
              set available-jobs replace-item job available-jobs ((item job available-jobs) - 1)
              ifelse(sex = "female")[
                set mars replace-item job mars (list ((item 0 item job mars) - 1) ((item 1 item job mars) - 1))
              ][
                set mars replace-item job mars (list (item 0 item job mars) ((item 1 item job mars) - 1))
              ]
            ]
            set job item 12 arg
            set working? true
            set student? false
            set file replace-item item 12 arg file replace-item 11 arg (item 11 arg + 1)
            set labor-force labor-force + 1
            set available-jobs replace-item item 12 arg available-jobs (item item 12 arg available-jobs - 1)
            set time-in-job 0
            set underemployed? true
            set growth-rate grow + 0.2
            set percentile 10 + random (skew * 2 - 20)
            set innovator item 13 item job file
            ifelse(sex = "female")[
              set mars replace-item job mars (list ((item 0 item job mars) + 1) ((item 1 item job mars) + 1))
            ][
              set mars replace-item job mars (list (item 0 item job mars) ((item 1 item job mars) + 1))
            ]
            stop
          ]
        ]
      ]
    ]
    if(random-float prob-6-job > prob-8-job and not underemployed?)[
      if(working?)[
        set labor-force labor-force - 1
        set file replace-item job file replace-item 11 item job file ((item 11 item job file) - 1)
        set available-jobs replace-item job available-jobs ((item job available-jobs) - 1)
        ifelse(sex = "female")[
          set mars replace-item job mars (list ((item 0 item job mars) - 1) ((item 1 item job mars) - 1))
        ][
          set mars replace-item job mars (list (item 0 item job mars) ((item 1 item job mars) - 1))
        ]
      ]
      set working? false
      set student? false
      set underemployed? false
    ]
  ]
  if(round education = 8)[
    foreach file [
      [arg]->
      if( item 10 arg = 8 and item item 12 arg available-jobs > 0 and ((not underemployed?) or item 10 item job file < 8))[
        ifelse(sex = "female" and random-float 1 < .06) or (sex = "male" and random-float 1 < 0.01)[
          if(working?)[
            set labor-force labor-force - 1
            set file replace-item job file replace-item 11 item job file ((item 11 item job file) - 1)
            set available-jobs replace-item job available-jobs ((item job available-jobs) - 1)
            ifelse(sex = "female")[
              set mars replace-item job mars (list ((item 0 item job mars) - 1) ((item 1 item job mars) - 1))
            ][
              set mars replace-item job mars (list (item 0 item job mars) ((item 1 item job mars) - 1))
            ]
          ]
          set working? false
          set student? false
          set underemployed? false
          set lifestage 4
          stop
        ][
          if(working?)[
            set labor-force labor-force - 1
            set file replace-item job file replace-item 11 item job file ((item 11 item job file) - 1)
            set available-jobs replace-item job available-jobs ((item job available-jobs) - 1)
            ifelse(sex = "female")[
              set mars replace-item job mars (list ((item 0 item job mars) - 1) ((item 1 item job mars) - 1))
            ][
              set mars replace-item job mars (list (item 0 item job mars) ((item 1 item job mars) - 1))
            ]
          ]
          set job item 12 arg
          set working? true
          set student? false
          set file replace-item item 12 arg file replace-item 11 arg (item 11 arg + 1)
          set labor-force labor-force + 1
          set available-jobs replace-item item 12 arg available-jobs (item item 12 arg available-jobs - 1)
          set time-in-job 0
          set underemployed? false
          set growth-rate grow
          set percentile 10 + random (skew * 2 - 20)
          set innovator item 13 item job file
          ifelse(sex = "female")[
            set mars replace-item job mars (list ((item 0 item job mars) + 1) ((item 1 item job mars) + 1))
          ][
            set mars replace-item job mars (list (item 0 item job mars) ((item 1 item job mars) + 1))
          ]
          stop
        ]
      ]
    ]
    if(not working?)[
      foreach file [
        [arg]->
        if( item 10 arg = 6 and item item 12 arg available-jobs > 0 and ((not underemployed?) or item 10 item job file < 6))[
          ifelse(sex = "female" and random-float 1 < .06) or (sex = "male" and random-float 1 < 0.01)[
            if(working?)[
              set labor-force labor-force - 1
              set file replace-item job file replace-item 11 item job file ((item 11 item job file) - 1)
              set available-jobs replace-item job available-jobs ((item job available-jobs) - 1)
              ifelse(sex = "female")[
                set mars replace-item job mars (list ((item 0 item job mars) - 1) ((item 1 item job mars) - 1))
              ][
                set mars replace-item job mars (list (item 0 item job mars) ((item 1 item job mars) - 1))
              ]
            ]
            set working? false
            set student? false
            set underemployed? false
            set lifestage 4
            stop
          ][
            if(working?)[
              set labor-force labor-force - 1
              set file replace-item job file replace-item 11 item job file ((item 11 item job file) - 1)
              set available-jobs replace-item job available-jobs ((item job available-jobs) - 1)
              ifelse(sex = "female")[
                set mars replace-item job mars (list ((item 0 item job mars) - 1) ((item 1 item job mars) - 1))
              ][
                set mars replace-item job mars (list (item 0 item job mars) ((item 1 item job mars) - 1))
              ]
            ]
            set job item 12 arg
            set working? true
            set student? false
            set file replace-item item 12 arg file replace-item 11 arg (item 11 arg + 1)
            set labor-force labor-force + 1
            set available-jobs replace-item item 12 arg available-jobs (item item 12 arg available-jobs - 1)
            set time-in-job 0
            set underemployed? true
            set growth-rate grow + 0.1
            set percentile 10 + random (skew * 2 - 20)
            set innovator item 13 item job file
            ifelse(sex = "female")[
              set mars replace-item job mars (list ((item 0 item job mars) + 1) ((item 1 item job mars) + 1))
            ][
              set mars replace-item job mars (list (item 0 item job mars) ((item 1 item job mars) + 1))
            ]
            stop
          ]
        ]
      ]
    ]
    if(not working?)[
      foreach file [
        [arg]->
        if( item 10 arg = 4 and item item 12 arg available-jobs > 0  and ((not underemployed?) or item 10 item job file < 4))[
          ifelse(sex = "female" and random-float 1 < .06) or (sex = "male" and random-float 1 < 0.01)[
            if(working?)[
              set labor-force labor-force - 1
              set file replace-item job file replace-item 11 item job file ((item 11 item job file) - 1)
              set available-jobs replace-item job available-jobs ((item job available-jobs) - 1)
              ifelse(sex = "female")[
                set mars replace-item job mars (list ((item 0 item job mars) - 1) ((item 1 item job mars) - 1))
              ][
                set mars replace-item job mars (list (item 0 item job mars) ((item 1 item job mars) - 1))
              ]
            ]
            set working? false
            set student? false
            set underemployed? false
            set lifestage 4
            stop
          ][
            if(working?)[
              set labor-force labor-force - 1
              set file replace-item job file replace-item 11 item job file ((item 11 item job file) - 1)
              set available-jobs replace-item job available-jobs ((item job available-jobs) - 1)
              ifelse(sex = "female")[
                set mars replace-item job mars (list ((item 0 item job mars) - 1) ((item 1 item job mars) - 1))
              ][
                set mars replace-item job mars (list (item 0 item job mars) ((item 1 item job mars) - 1))
              ]
            ]
            set job item 12 arg
            set working? true
            set student? false
            set file replace-item item 12 arg file replace-item 11 arg (item 11 arg + 1)
            set labor-force labor-force + 1
            set available-jobs replace-item item 12 arg available-jobs (item item 12 arg available-jobs - 1)
            set time-in-job 0
            set underemployed? true
            set growth-rate grow + 0.2
            set percentile 10 + random (skew * 2 - 20)
            set innovator item 13 item job file
            ifelse(sex = "female")[
              set mars replace-item job mars (list ((item 0 item job mars) + 1) ((item 1 item job mars) + 1))
            ][
              set mars replace-item job mars (list (item 0 item job mars) ((item 1 item job mars) + 1))
            ]
            stop
          ]
        ]
      ]
    ]
    if(not working?)[
      foreach file [
        [arg]->
        if( item 10 arg = 2 and item item 12 arg available-jobs > 0 and ((not underemployed?) or item 10 item job file < 2))[
          ifelse(sex = "female" and random-float 1 < .06) or (sex = "male" and random-float 1 < 0.01)[
            if(working?)[
              set labor-force labor-force - 1
              set file replace-item job file replace-item 11 item job file ((item 11 item job file) - 1)
              set available-jobs replace-item job available-jobs ((item job available-jobs) - 1)
              ifelse(sex = "female")[
                set mars replace-item job mars (list ((item 0 item job mars) - 1) ((item 1 item job mars) - 1))
              ][
                set mars replace-item job mars (list (item 0 item job mars) ((item 1 item job mars) - 1))
              ]
            ]
            set working? false
            set student? false
            set underemployed? false
            set lifestage 4
            stop
          ][
            if(working?)[
              set labor-force labor-force - 1
              set file replace-item job file replace-item 11 item job file ((item 11 item job file) - 1)
              set available-jobs replace-item job available-jobs ((item job available-jobs) - 1)
              ifelse(sex = "female")[
                set mars replace-item job mars (list ((item 0 item job mars) - 1) ((item 1 item job mars) - 1))
              ][
                set mars replace-item job mars (list (item 0 item job mars) ((item 1 item job mars) - 1))
              ]
            ]
            set job item 12 arg
            set working? true
            set student? false
            set file replace-item item 12 arg file replace-item 11 arg (item 11 arg + 1)
            set labor-force labor-force + 1
            set available-jobs replace-item item 12 arg available-jobs (item item 12 arg available-jobs - 1)
            set time-in-job 0
            set underemployed? true
            set growth-rate grow + 0.3
            set percentile 10 + random (skew * 2 - 20)
            set innovator item 13 item job file
            ifelse(sex = "female")[
              set mars replace-item job mars (list ((item 0 item job mars) + 1) ((item 1 item job mars) + 1))
            ][
              set mars replace-item job mars (list (item 0 item job mars) ((item 1 item job mars) + 1))
            ]
            stop
          ]
        ]
      ]
    ]
    if(not underemployed?)[
      if(working?)[
        set labor-force labor-force - 1
        set file replace-item job file replace-item 11 item job file ((item 11 item job file) - 1)
        set available-jobs replace-item job available-jobs ((item job available-jobs) - 1)
        ifelse(sex = "female")[
          set mars replace-item job mars (list ((item 0 item job mars) - 1) ((item 1 item job mars) - 1))
        ][
          set mars replace-item job mars (list (item 0 item job mars) ((item 1 item job mars) - 1))
        ]
      ]
      set student? false
      set working? false
      set underemployed? false
    ]
  ]
  set education round education
end
to retire
  if(working?)[
    set available-jobs replace-item job available-jobs (item job available-jobs + 1)
    set labor-force labor-force - 1
    set underemployed? false
    set file replace-item job file replace-item 11 item job file ((item 11 item job file) - 1)
    ifelse(sex = "female")[
      set mars replace-item job mars (list ((item 0 item job mars) - 1) ((item 1 item job mars) - 1))
    ][
      set mars replace-item job mars (list (item 0 item job mars) ((item 1 item job mars) - 1))
    ]
  ]
  set working? false
end
to-report unemployment-rate
  if(count turtles with [lifestage = 3] = 0)[
    report 0
  ]
  report 1 - ((labor-force) / (count turtles with [lifestage = 3]))
end
to grow-income
  if(working?)[
    set percentile percentile + growth-rate / ticks-per-year
    if(percentile < 10)[
      set income minimum-wage
      stop
    ]
    if(percentile < 25)[
      set income ((item 2 (item job income-file)) * (25 - percentile) + (item 3 (item job income-file)) * (percentile - 10)) / 15 / total-inflation
      stop
    ]
    if(percentile < 50)[
      set income ((item 3 (item job income-file)) * (50 - percentile) + (item 4 (item job income-file)) * (percentile - 25)) / 25 / total-inflation
      stop
    ]
    if(percentile < 75)[
      set income ((item 4 (item job income-file)) * (75 - percentile) + (item 5 (item job income-file)) * (percentile - 50)) / 25 / total-inflation
      stop
    ]
    if(percentile < 90)[
      set income ((item 5 (item job income-file)) * (90 - percentile) + (item 6 (item job income-file)) * (percentile - 75)) / 15 / total-inflation
      stop
    ]
    set income item 6 (item job income-file) / total-inflation
  ]
  if(lifestage = 3 and (not working?))[
    set income welfare
  ]
end
to adjust-income
  set gross-income income
  set income income - taxation income
  if(income < minimum-wage and working?)[
      set income minimum-wage
  ]
  if(not working?)[
    set income 0
  ]
  if(investment > 0 and working?)[
    set income income + interest-rate * investment
  ]
end
to set-age
  set age age + 1 / ticks-per-year
  if(age < 5)[
    set lifestage 0
    stop
  ]
  if(age < 18)[
    set lifestage 1
    stop
  ]
  if(age >= 70 or lifestage = 4)[
    if(not (lifestage = 4))[
      retire
    ]
    set lifestage 4
    stop
  ]
  if(student?)[
    set lifestage 2
    stop
  ]
  set lifestage 3
end
to-report investment
  report (1 / (1 + inflation)) * (income - welfare / (1 - MPC)) * (1 - MPC) * ifelse-value (innovator = 1) [1.5][1]
end
to-report gdp
  report (sum [income] of turtles with [working?]) * MPC + welfare * count turtles with [lifestage >= 3] + government-spending + sum [investment] of turtles with [working?]
end
;to-report mean-metric
;  let dmu (abs (income-mean - prev-income-mean)) / (income-mean + prev-income-mean) * 2 * ticks-per-year
;  report dmu / (dmu + mu-constant * income-mean); TO DO set mu-constant
;end
to-report variance-metric
  report (income-var) / ((income-var) ^ 2 + income-d)
end
to-report income-metric
  report income-mean * variance-metric
end
to-report equal [a b]
  if(item 1 b = 0)[
    report 0
  ]
  report ((item 0 a ) / (item 1 a) - (item 0 b) / (item 1 b)) ^ 2
end
to-report equality-c
  let x (map equal earth mars)
  report map [[arg]-> arg / sum x ] x
end
to-report equality
  let women n-values 22 [
    [arg]->
    count turtles with [sex = "female" and job = arg]
  ]
  report sum (map [[a b] -> a * b] equality-c women) / labor-force
end
to-report inflation
  report sinoid (ticks / ticks-per-year)
end
to-report sinoid [hi]
  report inflation-amp * sin (hi * 360  / inflation-period) + inflation-constant - inflation-amp-2 * cos (hi * 360 / inflation-period-2)
end
to set-inflation
  set total-inflation total-inflation * (1 + inflation) ^ (1 / ticks-per-year)
end
to-report education-metric
  let t sum ([education] of turtles with [job = 7]) + sum ([experience] of turtles with [job = 7])
  if(t = 0)[
    set t (1 / 2)
  ]
  report 100 * unemployment-rate * count turtles with [student?] / t
end
to-report government-spending
  report count turtles with [student?] * 42155 + ((168281905 +   158625722 ) * count turtles / 10000) + count turtles with [lifestage = 3 and (not working?)] * welfare + count turtles with [age >= 70] * social-security
;                                                  insurance   everything else  defense +    79312861
end
to set-government-debt
  set government-debt government-debt + (government-spending - sum [taxation income] of turtles with [lifestage = 3]) / ticks-per-year
end
to-report taxation [n]
  let tax 0
  if (n > bracket-5) [
    set tax (tax + (tax-rate-5 * (n - bracket-5)))
    set n (bracket-5)
  ]
  if (n > bracket-4) [
    set tax (tax + (tax-rate-4 * (n - bracket-4)))
    set n (bracket-4)
  ]
  if (n > bracket-3) [
    set tax (tax + (tax-rate-3 * (n - bracket-3)))
    set n (bracket-3)
  ]
  if (n > bracket-2) [
    set tax (tax + (tax-rate-2 * (n - bracket-2)))
    set n (bracket-2)
  ]
  if (n > bracket-1) [
    set tax (tax + (tax-rate-1 * (n - bracket-1)))
    set n (bracket-1)
  ]
  report tax
end
@#$#@#$#@
GRAPHICS-WINDOW
234
10
822
369
-1
-1
10.0
1
10
1
1
1
0
1
1
1
0
57
0
34
1
1
1
ticks
30.0

BUTTON
49
59
112
92
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
118
59
181
92
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
49
97
221
130
num-people
num-people
0
100000
10000.0
10000
1
NIL
HORIZONTAL

SLIDER
50
136
222
169
ticks-per-year
ticks-per-year
0
10
6.0
1
1
NIL
HORIZONTAL

SLIDER
50
174
222
207
maternity-leave
maternity-leave
2
10
10.0
1
1
NIL
HORIZONTAL

SLIDER
49
213
221
246
paternity-leave
paternity-leave
0
10
3.0
1
1
NIL
HORIZONTAL

SLIDER
846
143
1018
176
minimum-wage
minimum-wage
0
1000000
75000.0
1000
1
NIL
HORIZONTAL

SLIDER
844
99
1016
132
baby-constant-final
baby-constant-final
0
1
0.265
0.005
1
NIL
HORIZONTAL

SLIDER
843
230
1015
263
welfare
welfare
0
100000
59000.0
1000
1
NIL
HORIZONTAL

SLIDER
841
54
1013
87
tax-rate
tax-rate
0
2
0.66
0.01
1
NIL
HORIZONTAL

SLIDER
845
271
1017
304
MPC
MPC
0
1
0.9
0.10
1
NIL
HORIZONTAL

SLIDER
844
185
1016
218
social-security
social-security
0
200000
45000.0
1000
1
NIL
HORIZONTAL

SLIDER
842
11
1014
44
interest-rate
interest-rate
0
1
0.0075
0.0005
1
NIL
HORIZONTAL

PLOT
1027
171
1337
321
Age
Age
Number
0.0
120.0
0.0
80.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [age] of turtles"

PLOT
1026
13
1338
163
GDP
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "if (ticks > 0)[plot gdp]"

PLOT
632
10
832
160
income
NIL
NIL
0.0
1000000.0
0.0
10.0
true
false
"" ""
PENS
"default" 40000.0 1 -16777216 true "" "histogram [gross-income] of turtles with [working?]"

PLOT
632
160
832
310
education
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "if (ticks > 0) [ plot education-metric * 100 ]"

PLOT
630
309
830
459
income-metric
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "if (ticks >= ticks-per-year) [ plot income-metric ]"

PLOT
434
310
634
460
Equality
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "if (ticks > 0) [ plot equality * 100 ]"

PLOT
234
309
434
459
Inflation
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "if (ticks > 0) [ plot inflation * 100 ]"

PLOT
433
158
633
312
Unemployment
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "if(ticks > 0)[plot unemployment-rate * 100]"

PLOT
235
160
435
310
Government Debt
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot government-debt"

PLOT
433
10
633
160
Education
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.999 1 -16777216 true "" "histogram [education] of turtles with [lifestage >= 2]"

MONITOR
848
355
1021
400
Population
count turtles
17
1
11

MONITOR
848
409
1025
454
Babies per Female
mean [num-babies] of turtles with [sex = \"female\" and age > 50 and age < 60]
2
1
11

SLIDER
847
313
1019
346
skew
skew
0
100
50.0
1
1
NIL
HORIZONTAL

CHOOSER
49
10
187
55
readfile
readfile
"pop.csv" "pop2.csv" "pop3.csv" "pop4.csv" "pop5.csv" "pop6.csv"
0

PLOT
234
10
434
160
population
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "if(ticks > 0)[plot count turtles]"
"pen-1" 1.0 0 -13791810 true "" "if(ticks > 0)[plot count turtles with [sex = \"male\"]]"
"pen-2" 1.0 0 -2064490 true "" "if(ticks > 0)[plot count turtles with [sex = \"female\"]]"

SLIDER
49
253
221
286
stop-time
stop-time
0
1200
60.0
10
1
NIL
HORIZONTAL

MONITOR
80
333
169
378
NIL
income-metric
0
1
11

@#$#@#$#@
## WHAT IS IT?

This is the model of the winning Problem F solution of the Mathematical Contest in Modeling. It attempts to model 22th century Martian Civilization. See the problem for more details.

## HOW IT WORKS

According to our paper,

"We developed an agent-based model that simulates a population of 10,000 agents on Mars using real world data given by the US Census' data on occupational income. In our model, each agent, or Martian citizen, progresses through their lifecycle by attending college, searching for jobs, and earning income. The government then protects these individual agents from economic harm using programs such as welfare and minimum wage. To maximize both social welfare and productivity, we chose to monitor the state of the economy and create metrics that would measure the effect of agent-based factors on the community's well-being. We measured multiple parameters of the community generated by these agents, which allowed us to evaluate the condition of the economy. From these parameters, we generated three metrics: the Income Metric I, the Education Metric E, and the Equality Metric Q. The income metric favors higher per capita income values on Mars and punishes a wage gap between the rich and the poor that is either too large or too small. The education metric measures the amount of unemployment as an economical factor and the student-to-faculty ratio as a social welfare factor so as to evaluate education through both the lens of productivity and well-being. Finally, the Equality Metric compares the proportion of women in occupations on Mars to their proportion in jobs on Earth to illustrate the dynamic social equality present in Population Zero. Additionally, our model includes several economic indicators and properties like the inflation rate, a progressive tax system, total investment, and government debt to add further to the dynamic equilibrium of the economy."

Our model initializes people using the data files and computes the metric at every tick.

## HOW TO USE IT

You can change the starting population with the 'readfile' slider and the simulation length with stop-time. The other sliders are economic indicators which you can mess around with.

## CREDITS AND REFERENCES

https://github.com/nikhilreddy6547/martian-modeling
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

stick
true
0
Circle -7500403 false true 101 41 67
Line -7500403 true 135 120 135 240
Line -7500403 true 90 135 135 180
Line -7500403 true 180 135 135 180
Line -7500403 true 135 240 105 270
Line -7500403 true 135 240 165 270

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@

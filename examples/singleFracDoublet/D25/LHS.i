[StochasticTools]
[]

[Distributions]
    [perm_exp]
        type = Uniform
        lower_bound = 11
        upper_bound = 13
    []
    [injection_rate]
        type = Uniform
        lower_bound = 1
        upper_bound = 10
    []
[]

[Samplers]
    [sample]
        type = LatinHypercube
        num_rows = 20 # Number of Monte Carlo samples
        distributions = 'perm_exp injection_rate'
        execute_on = 'PRE_MULTIAPP_SETUP'
        seed = 100
    []
[]

[MultiApps]
    [sub]
        type = SamplerFullSolveMultiApp
        input_files = matFrac_2fluid.i
        sampler = sample
        execute_on = 'TIMESTEP_BEGIN'
        mode = batch-reset
    []
[]

[Controls]
    [cmdline]
        type = MultiAppCommandLineControl
        multi_app = sub
        sampler = sample
        param_names = 'coordinates1 injection_rate'
    []
[]
  
[VectorPostprocessors]
    [data]
      type = SamplerData
      sampler = sample
      execute_on = 'initial timestep_end'
    []
  []
  
[Executioner]
    type = Steady
[]
  
[Outputs]
    csv = true
    exodus = false
    execute_on = 'TIMESTEP_END'
    print_linear_converged_reason = false
    print_nonlinear_converged_reason = false
    perf_graph = true
[]
  
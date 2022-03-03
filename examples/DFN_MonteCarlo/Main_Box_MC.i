[StochasticTools]
  auto_create_executioner = false
[]

[Distributions]
  [value]
    type = Normal
    mean = 0.01
    standard_deviation = 1e-8
  []
  [xcoord]
    type = Uniform
    lower_bound = -9
    upper_bound = 209
  []
  [ycoord]
    type = Uniform
    lower_bound = -9
    upper_bound = 159
  []
  [zcoord]
    type = Uniform
    lower_bound = -9
    upper_bound = 209
  []
[]

[Samplers]
  [sample]
    type = MonteCarlo
    num_rows = 1000
    distributions = 'value xcoord ycoord zcoord'
    execute_on = 'PRE_MULTIAPP_SETUP'
  []
[]

[MultiApps]
  [sub]
    type = SamplerFullSolveMultiApp
    input_files = matrix_app_amr.i
    sampler = sample
    mode = batch-reset
  []
[]

[Transfers]
  [Jout]
    type = SamplerReporterTransfer
    multi_app = sub
    sampler = sample
    stochastic_reporter = Jout_storage
    from_reporter = Jout_Constant/Jout_values
  []
[]

[Reporters]
  [Jout_storage]
    type = StochasticReporter
    execute_on = 'timestep_end'
    # parallel_type = ROOT
  []
[]

[VectorPostprocessors]
  [data]
    type = SamplerData
    sampler = sample
    # execute_on = 'initial timestep_end'
    # parallel_type = DISTRIBUTED
  []
[]

[Controls]
  [cmdline]
    type = MultiAppCommandLineControl
    multi_app = sub
    sampler = sample
    param_names = 'value x_req y_req z_req'
  []
[]

[Executioner]
  type = Steady
  # num_steps = 2
[]

[Outputs]
  csv = true
  json = true
  exodus = false
  execute_on = 'TIMESTEP_END'
  print_linear_converged_reason = false
  print_nonlinear_converged_reason = false
  perf_graph = true
[]

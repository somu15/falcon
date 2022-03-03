[StochasticTools]
  auto_create_executioner = false
[]

[Samplers]
  [sample]
    type = TestMC
    Radius = 36.0 # 50.0 #
    center_coords = '37.500000 26.516504 26.516504'
    unit_normal = '0.0 -0.707107 0.707107'
    execute_on = 'PRE_MULTIAPP_SETUP'
    # seed = 1012
  []
[]

[MultiApps]
  [sub]
    type = SamplerFullSolveMultiApp
    input_files = matrix_app_amr.i
    sampler = sample
    # mode = batch-reset
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
    parallel_type = DISTRIBUTED
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
  type = Transient
  num_steps = 2
[]

[Outputs]
  csv = true
  json = true
  exodus = false
  execute_on = 'TIMESTEP_END'
  print_linear_converged_reason = false
  print_nonlinear_converged_reason = false
[]

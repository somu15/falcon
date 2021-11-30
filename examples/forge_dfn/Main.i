[StochasticTools]
  auto_create_executioner = false
[]

[Samplers]
  [sample]
    type = TestMC
    Radius = 500.0 # 588.0 #
    center_coords = '-299.951707 -1.754680 -299.471563'
    unit_normal = '1.000000 -0.000026 0.000005'
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
  num_steps = 1
[]

[Outputs]
  csv = true
  json = true
  exodus = false
  execute_on = 'TIMESTEP_END'
  print_linear_converged_reason = false
  print_nonlinear_converged_reason = false
[]

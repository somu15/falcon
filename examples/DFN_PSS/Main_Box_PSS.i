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
    type = ParallelSubsetSimulation
    distributions = 'value xcoord ycoord zcoord'
    execute_on = 'PRE_MULTIAPP_SETUP'
    # use_absolute_value = true
    # seed = 1012
    num_samplessub = 100
    output_reporter = 'constant/reporter_transfer:Jout_Constant:Jout_values'
    inputs_reporter = 'adaptive_MC/inputs'
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
  [reporter_transfer]
    type = SamplerReporterTransfer
    multi_app = sub
    sampler = sample
    stochastic_reporter = 'constant'
    from_reporter = 'Jout_Constant/Jout_values'
  []
  [Node_x]
    type = SamplerReporterTransfer
    multi_app = sub
    sampler = sample
    stochastic_reporter = Node_x
    from_reporter = Constant1/x1
  []
  [Node_y]
    type = SamplerReporterTransfer
    multi_app = sub
    sampler = sample
    stochastic_reporter = Node_y
    from_reporter = Constant1/y1
  []
  [Node_z]
    type = SamplerReporterTransfer
    multi_app = sub
    sampler = sample
    stochastic_reporter = Node_z
    from_reporter = Constant1/z1
  []
[]

[Reporters]
  [constant]
    type = StochasticReporter
    execute_on = 'timestep_end'
  []
  [adaptive_MC]
    type = AdaptiveMonteCarloDecision
    output_value = 'constant/reporter_transfer:Jout_Constant:Jout_values'
    x_value = 'Node_x/Node_x:Constant1:x1'
    y_value = 'Node_y/Node_y:Constant1:y1'
    z_value = 'Node_z/Node_z:Constant1:z1'
    inputs = 'inputs'
    sampler = sample
  []
  [Node_x]
    type = StochasticReporter
    execute_on = 'timestep_end'
    # parallel_type = ROOT
  []
  [Node_y]
    type = StochasticReporter
    execute_on = 'timestep_end'
    # parallel_type = ROOT
  []
  [Node_z]
    type = StochasticReporter
    execute_on = 'timestep_end'
    # parallel_type = ROOT
  []
[]

# [VectorPostprocessors]
#   [data]
#     type = SamplerData
#     sampler = sample
#     # execute_on = 'initial timestep_end'
#     # parallel_type = DISTRIBUTED
#   []
# []

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
  num_steps = 20 # 50
[]

[Outputs]
  [out]
    type = JSON
    execute_system_information_on = NONE
  []
  csv = false
  # json = true
  exodus = false
  execute_on = 'TIMESTEP_END'
  print_linear_converged_reason = false
  print_nonlinear_converged_reason = false
  perf_graph = true
[]

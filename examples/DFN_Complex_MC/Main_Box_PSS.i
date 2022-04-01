[StochasticTools]
  auto_create_executioner = false
[]

[Distributions]
  # [value]
  #   type = Normal
  #   mean = 0.01
  #   standard_deviation = 1e-8
  # []
  [xcoord]
    type = Uniform
    lower_bound = -500
    upper_bound = -100
  []
  [ycoord]
    type = Uniform
    lower_bound = -200
    upper_bound = 200
  []
  [zcoord]
    type = Uniform
    lower_bound = -500
    upper_bound = -100
  []
[]

[Samplers]
  [sample]
    type = ParallelSubsetSimulation
    distributions = 'xcoord ycoord zcoord'
    output_reporter = 'Tracerout_storage/Tracerout:int_tracer:value'
    inputs_reporter = 'adaptive_MC/inputs'
    execute_on = 'PRE_MULTIAPP_SETUP'
    num_samplessub = 100
    use_absolute_value = false
    num_parallel_chains = 2
    seed = 1012
  []
[]

[MultiApps]
  [sub]
    type = SamplerFullSolveMultiApp
    input_files = rkp_fracture_simple.i
    sampler = sample
    # mode = batch-reset
  []
[]

[Transfers]
  [Tracerout]
    type = SamplerReporterTransfer
    multi_app = sub
    sampler = sample
    stochastic_reporter = Tracerout_storage
    from_reporter = int_tracer/value # tracer_out/tracer
  []
  [Node_x]
    type = SamplerReporterTransfer
    multi_app = sub
    sampler = sample
    stochastic_reporter = Node_x
    from_reporter = prod_node/node_x
  []
  [Node_y]
    type = SamplerReporterTransfer
    multi_app = sub
    sampler = sample
    stochastic_reporter = Node_y
    from_reporter = prod_node/node_y
  []
  [Node_z]
    type = SamplerReporterTransfer
    multi_app = sub
    sampler = sample
    stochastic_reporter = Node_z
    from_reporter = prod_node/node_z
  []
[]

[Reporters]
  [Tracerout_storage]
    type = StochasticReporter
    execute_on = 'timestep_end'
    # parallel_type = ROOT
  []
  # [constant]
  #   type = StochasticReporter
  #   execute_on = 'timestep_end'
  # []
  [adaptive_MC]
    type = AdaptiveMonteCarloDecision
    output_value = 'Tracerout_storage/Tracerout:int_tracer:value'
    # x_value = 'Node_x/Node_x:prod_node:node_x'
    # y_value = 'Node_y/Node_y:prod_node:node_y'
    # z_value = 'Node_z/Node_z:prod_node:node_z'
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
    param_names = 'x_out y_out z_out'
  []
[]

[Executioner]
  # type = Steady
  type = Transient
  num_steps = 100 # 1000
[]

[Outputs]
  csv = false
  json = true
  exodus = false
  execute_on = 'TIMESTEP_END'
  print_linear_converged_reason = false
  print_nonlinear_converged_reason = false
  perf_graph = true
[]

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
      lower_bound = 0.605445
      upper_bound = 188.064
    []
    [ycoord]
      type = Uniform
      lower_bound = 0.50384
      upper_bound = 157.49
    []
    [zcoord]
      type = Uniform
      lower_bound = 10.1281
      upper_bound = 198.514
    []
  []
  
  [Samplers]
    [sample]
      type = MonteCarlo
      distributions = 'xcoord ycoord zcoord'
      num_rows = 10
      execute_on = 'PRE_MULTIAPP_SETUP'
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
      type = SamplerReporterTransfer # SamplerPostprocessorTransfer #
      # multi_app = sub
      from_multi_app = sub
      sampler = sample
      stochastic_reporter = Tracerout_storage
      from_reporter = 'int_tracer/value' # tracer_out/tracer
      # from_postprocessor = int_tracer/value # tracer_out/tracer
    []
    [Node_x]
      type = SamplerReporterTransfer
      # multi_app = sub
      from_multi_app = sub
      sampler = sample
      stochastic_reporter = Node_x
      from_reporter = prod_node/node_x
    []
    [Node_y]
      type = SamplerReporterTransfer
      # multi_app = sub
      from_multi_app = sub
      sampler = sample
      stochastic_reporter = Node_y
      from_reporter = prod_node/node_y
    []
    [Node_z]
      type = SamplerReporterTransfer
      # multi_app = sub
      from_multi_app = sub
      sampler = sample
      stochastic_reporter = Node_z
      from_reporter = prod_node/node_z
    []
  []
  
  [Reporters]
    [Tracerout_storage]
      type = StochasticReporter
      execute_on = 'timestep_end'
    []
    [Node_x]
      type = StochasticReporter
      execute_on = 'timestep_end'
    []
    [Node_y]
      type = StochasticReporter
      execute_on = 'timestep_end'
    []
    [Node_z]
      type = StochasticReporter
      execute_on = 'timestep_end'
    []
  []
  
  [VectorPostprocessors]
    [data]
      type = SamplerData
      sampler = sample
    []
  []
  
  [Controls]
    [cmdline]
      type = MultiAppCommandLineControl
      multi_app = sub
      sampler = sample
      param_names = 'x_out y_out z_out'
    []
  []
  
  [Executioner]
    type = Steady
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
  
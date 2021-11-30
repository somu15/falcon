[StochasticTools]
[]

[Distributions]
  [value]
    type = FracturePlane
  []
  [x]
    type = FracturePlane
  []
  [y]
    type = FracturePlane
  []
  [z]
    type = FracturePlane
  []
[]

[Samplers]
  [sample]
    type = TestMC
    distributions = 'value x y z'
    execute_on = 'initial'
    Radius = 76.9
    center_coords = '109.434 82.635 77.409'
    unit_normal = '-0.308536 0.922122 -0.233444'
  []
[]

[VectorPostprocessors]
  [data]
    type = SamplerData
    sampler = sample
    execute_on = 'TIMESTEP_END'
  []
[]

[Executioner]
  type = Transient
  num_steps = 10 # 40000
[]

[Outputs]
  # execute_on = 'TIMESTEP_END'
  csv = true
  # json = true
[]

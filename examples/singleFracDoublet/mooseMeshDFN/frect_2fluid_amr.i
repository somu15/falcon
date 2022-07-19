# Cold water injection into one side of the fracture network, and production from the other side
permeability = 1e-12
injection_rate = 10 # kg/s
endTime = 1e8 #longer that main app of 6e5
injection_temp = 303

#injection coordinates
x_in = 0
y_in = 0
z_in = 0
#production coordinates
x_out = 0
y_out = 0
z_out = 150

[Mesh]
  uniform_refine = 0
  [generate]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 20
    xmin = -50
    xmax = 50
    ny = 40
    ymin = -20
    ymax = 180
  []
  [rotate]
    type = TransformGenerator
    input = generate
    transform = ROTATE
    vector_value = '0 90 90'
    # rotates ymax to zmax
  []
[]

[GlobalParams]
  PorousFlowDictator = dictator
  gravity = '0 0 -9.81E-6'
[]

[Variables]
  [frac_P]
    scale = 1e-6
  []
  [frac_T]
  []
  [tracer]
    initial_condition = 0.00001
  []
[]

[ICs]
  [frac_P]
    type = FunctionIC
    variable = frac_P
    function = insitu_pp
  []
  [frac_T]
    type = FunctionIC
    variable = frac_T
    function = insitu_T
  []
[]

[PorousFlowFullySaturated]
  coupling_type = ThermoHydro
  mass_fraction_vars = 'tracer'
  porepressure = frac_P
  temperature = frac_T
  fp = water
  pressure_unit = Pa
[]

[Kernels]
  [toMatrix]
    type = PorousFlowHeatMassTransfer
    variable = frac_T
    v = transferred_matrix_T
    transfer_coefficient = heat_transfer_coefficient
    save_in = joules_per_s
  []
[]

[AuxVariables]
  [transferred_matrix_T]
    initial_condition = 363
  []
  [heat_transfer_coefficient]
    family = MONOMIAL
    order = CONSTANT
    initial_condition = 0.0
  []
  [joules_per_s]
  []
  [density]
    family = MONOMIAL
    order = CONSTANT
  []
  [viscosity]
    family = MONOMIAL
    order = CONSTANT
  []
  [insitu_pp]
  []
  [normal_dirn_x]
    family = MONOMIAL
    order = CONSTANT
  []
  [normal_dirn_y]
    family = MONOMIAL
    order = CONSTANT
  []
  [normal_dirn_z]
    family = MONOMIAL
    order = CONSTANT
  []
  [enclosing_element_normal_length]
    family = MONOMIAL
    order = CONSTANT
  []
  [enclosing_element_normal_thermal_cond]
    family = MONOMIAL
    order = CONSTANT
  []
[]

[AuxKernels]
  [normal_dirn_x_auxk]
    type = PorousFlowElementNormal
    variable = normal_dirn_x
    component = x
  []
  [normal_dirn_y]
    type = PorousFlowElementNormal
    variable = normal_dirn_y
    component = y
  []
  [normal_dirn_z]
    type = PorousFlowElementNormal
    variable = normal_dirn_z
    component = z
  []
  [heat_transfer_coefficient_auxk]
    type = ParsedAux
    variable = heat_transfer_coefficient
    args = 'enclosing_element_normal_length enclosing_element_normal_thermal_cond'
    constant_names = h_s
    constant_expressions = 1E3 #This is the value being assigned to h_s.   Should be much bigger than thermal_conductivity / L ~ 1
    function = 'if(enclosing_element_normal_length = 0, 0, h_s * '
               'enclosing_element_normal_thermal_cond * 2 * enclosing_element_normal_length / (h_s * '
               'enclosing_element_normal_length * enclosing_element_normal_length + '
               'enclosing_element_normal_thermal_cond * 2 * enclosing_element_normal_length))'
  []
  [insitu_pp]
    type = FunctionAux
    execute_on = initial
    variable = insitu_pp
    function = insitu_pp
  []
  [density]
    type = PorousFlowPropertyAux
    variable = density
    property = density
    phase = 0
  []
  [viscosity]
    type = PorousFlowPropertyAux
    variable = viscosity
    property = viscosity
    phase = 0
  []
[]

[Reporters]
  [inject_pt]
    type = ConstantReporter
    real_vector_names = 'pt_x pt_y pt_z'
    real_vector_values = '${x_in}; ${y_in}; ${z_in}'
    outputs = none
  []
  [inject_node]
    type = ClosestNode
    point_x = inject_pt/pt_x
    point_y = inject_pt/pt_y
    point_z = inject_pt/pt_z
    projection_tolerance = 10
    execute_on = TIMESTEP_BEGIN
    outputs = none
  []
  [P_in]
    type = ClosestNodeData
    variable = frac_P
    point_x = inject_pt/pt_x
    point_y = inject_pt/pt_y
    point_z = inject_pt/pt_z
    projection_tolerance = 10
    execute_on = TIMESTEP_BEGIN
    outputs = none
  []
  [T_in]
    type = ClosestNodeData
    variable = frac_T
    point_x = inject_pt/pt_x
    point_y = inject_pt/pt_y
    point_z = inject_pt/pt_z
    projection_tolerance = 10
    execute_on = TIMESTEP_BEGIN
    outputs = none
  []
  [var_in]
    type = ReporterVectorComponents
    reporters = 'P_in/node_id P_in/node_x P_in/node_y P_in/node_z P_in/frac_P T_in/frac_T'
    indices = '0'
  []
  # [var_in]
  #   type = AccumulateReporter
  #   reporters = 'P_in/node_id P_in/node_x P_in/node_y P_in/node_z P_in/frac_P'
  #   outputs = var_in
  # []

  [prod_pt]
    type = ConstantReporter
    real_vector_names = 'pt_val pt_x pt_y pt_z'
    real_vector_values = '0.1; ${x_out}; ${y_out}; ${z_out}'
    outputs = none
    # 0.01 is the borehole radius
  []
  [prod_node]
    type = ClosestNodeProjector
    point_value = prod_pt/pt_val
    point_x = prod_pt/pt_x
    point_y = prod_pt/pt_y
    point_z = prod_pt/pt_z
    projection_tolerance = 10
    execute_on = TIMESTEP_BEGIN
    outputs = none
  []

  [P_out]
    type = ClosestNodeData
    variable = frac_P
    point_x = prod_pt/pt_x
    point_y = prod_pt/pt_y
    point_z = prod_pt/pt_z
    projection_tolerance = 10
    execute_on = TIMESTEP_BEGIN
    outputs = none
  []
  [T_out]
    type = ClosestNodeData
    variable = frac_T
    point_x = prod_pt/pt_x
    point_y = prod_pt/pt_y
    point_z = prod_pt/pt_z
    projection_tolerance = 10
    execute_on = TIMESTEP_END
    outputs = none
  []
  [tracer_out]
    type = ClosestNodeData
    variable = tracer
    point_x = prod_pt/pt_x
    point_y = prod_pt/pt_y
    point_z = prod_pt/pt_z
    projection_tolerance = 10
    execute_on = TIMESTEP_END
    outputs = none
  []

  [var_out]
    type = ReporterVectorComponents
    reporters = 'P_out/node_id P_out/node_x P_out/node_y P_out/node_z P_out/frac_P T_out/frac_T '
                'tracer_out/tracer'
    indices = '0'
  []
  # [var_out]
  #   type = AccumulateReporter
  #   reporters = 'P_out/node_id P_out/node_x P_out/node_y P_out/node_z P_out/frac_P massFracCold_out/massFracCold massFracHot_out/massFracHot'
  #   outputs = var_out
  # []
[]

[DiracKernels]
  [inject_fluid_mass]
    type = PorousFlowReporterPointSourcePP
    mass_flux = inject_mass_flux
    x_coord_reporter = 'inject_node/node_x'
    y_coord_reporter = 'inject_node/node_y'
    z_coord_reporter = 'inject_node/node_z'
    variable = tracer
  []
  [inject_fluid_h]
    type = PorousFlowReporterPointEnthalpySourcePP
    variable = frac_T
    mass_flux = inject_mass_flux
    x_coord_reporter = 'inject_node/node_x'
    y_coord_reporter = 'inject_node/node_y'
    z_coord_reporter = 'inject_node/node_z'
    T_in = 'inject_T'
    pressure = frac_P #? does this need to be tracer
    fp = water
  []

  [withdraw_fluid]
    type = PorousFlowPeacemanBorehole
    SumQuantityUO = kg_out_uo
    bottom_p_or_t = insitu_pp_borehole
    mass_fraction_component = 1
    character = 1
    line_length = 1
    x_coord_reporter = 'prod_node/node_x'
    y_coord_reporter = 'prod_node/node_y'
    z_coord_reporter = 'prod_node/node_z'
    weight_reporter = 'prod_node/node_value'
    unit_weight = '0 0 0'
    fluid_phase = 0
    use_mobility = true
    variable = frac_P
    block = fracture
  []
  [withdraw_tracer]
    type = PorousFlowPeacemanBorehole
    fluid_phase = 0
    mass_fraction_component = 0
    SumQuantityUO = tracer_kg_out_uo
    bottom_p_or_t = insitu_pp_borehole
    character = 1
    line_length = 1
    x_coord_reporter = 'prod_node/node_x'
    y_coord_reporter = 'prod_node/node_y'
    z_coord_reporter = 'prod_node/node_z'
    weight_reporter = 'prod_node/node_value'
    unit_weight = '0 0 0'
    use_mobility = true
    variable = tracer
    block = fracture
  []
  [withdraw_heat]
    type = PorousFlowPeacemanBorehole
    SumQuantityUO = J_out_uo
    bottom_p_or_t = insitu_pp_borehole
    character = 1
    line_length = 1
    x_coord_reporter = 'prod_node/node_x'
    y_coord_reporter = 'prod_node/node_y'
    z_coord_reporter = 'prod_node/node_z'
    weight_reporter = 'prod_node/node_value'
    unit_weight = '0 0 0'
    fluid_phase = 0
    use_mobility = true
    use_enthalpy = true
    variable = frac_T
    block = fracture
  []
[]

[UserObjects]
  [kg_out_uo]
    type = PorousFlowSumQuantity
  []
  [J_out_uo]
    type = PorousFlowSumQuantity
  []
  [tracer_kg_out_uo]
    type = PorousFlowSumQuantity
  []
[]

[Modules]
  [FluidProperties]
    [true_water]
      type = Water97FluidProperties
    []
    [water]
      type = TabulatedFluidProperties
      fp = true_water
      temperature_min = 275 # K
      temperature_max = 600
      interpolated_properties = 'density viscosity enthalpy internal_energy'
      fluid_property_file = water97_tabulated.csv
    []
  []
[]

[Materials]
  # [porosity]
  #   type = PorousFlowPorosityLinear
  #   porosity_ref = 1E-4
  #   P_ref = insitu_pp
  #   P_coeff = 3e-10
  #   porosity_min = 1E-5
  # []
  [porosity]
    type = PorousFlowPorosity
    porosity_zero = 0.1
  []
  [permeability]
    type = PorousFlowPermeabilityConst
    permeability = '${permeability} 0 0   0 ${permeability} 0   0 0 ${permeability}'
  []
  [internal_energy]
    type = PorousFlowMatrixInternalEnergy
    density = 2700
    specific_heat_capacity = 0
  []
  [aq_thermal_conductivity]
    type = PorousFlowThermalConductivityIdeal
    dry_thermal_conductivity = '0.6E-4 0 0  0 0.6E-4 0  0 0 0.6E-4'
  []
[]

[Functions]
  [kg_rate]
    type = ParsedFunction
    vals = 'dt kg_out'
    vars = 'dt kg_out'
    value = 'kg_out/dt'
  []
  [tracer_kg_rate]
    type = ParsedFunction
    vals = 'dt tracer_kg_out'
    vars = 'dt tracer_kg_out'
    value = 'tracer_kg_out/dt'
  []
  [insitu_pp]
    type = ParsedFunction
    value = '9.81*1000*(3000 - z)'
  []
  #FIXME LYNN SHOULD BE ABLE TO DELETE THIS SINCE APERTURE INDEPENDENT PERMEABILITY
  # approx insitu at production point, to prevent aperture closing due to low porepressures
  [insitu_pp_borehole]
    type = ParsedFunction
    value = '9810 * (3000 - z) + 1000' # Approximate hydrostatic in Pa + 1MPa
  []
  [insitu_T]
    type = ParsedFunction
    value = '363'
  []
[]

[Postprocessors]
  [inject_T]
    type = Receiver
    default = ${injection_temp}
  []
  [inject_mass_flux]
    type = Receiver
    default = ${injection_rate}
  []
  [nl_its]
    type = NumNonlinearIterations
  []
  [total_nl_its]
    type = CumulativeValuePostprocessor
    postprocessor = nl_its
  []
  [l_its]
    type = NumLinearIterations
  []
  [total_l_its]
    type = CumulativeValuePostprocessor
    postprocessor = l_its
  []
  [dt]
    type = TimestepSize
  []
  [active_time]
    type = PerfGraphData
    section_name = "Root"
    data_type = total
  []
  [kg_out]
    type = PorousFlowPlotQuantity
    uo = kg_out_uo
  []
  [kg_per_s]
    type = FunctionValuePostprocessor
    function = kg_rate
  []
  [J_out]
    type = PorousFlowPlotQuantity
    uo = J_out_uo
  []
  [tracer_kg_out]
    type = PorousFlowPlotQuantity
    uo = tracer_kg_out_uo
  []
  [tracer_kg_per_s]
    type = FunctionValuePostprocessor
    function = tracer_kg_rate
  []
[]

[VectorPostprocessors]
  [heat_transfer_rate]
    type = NodalValueSampler
    outputs = none
    sort_by = id
    variable = joules_per_s
  []
[]

[Preconditioning]
  active = superlu
  [superlu]
    type = SMP
    full = true
    petsc_options_iname = '-ksp_type -pc_type -pc_factor_mat_solver_package'
    petsc_options_value = 'gmres lu superlu_dist'
  []
  [preferred]
    type = SMP
    full = true
    petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
    petsc_options_value = ' lu       mumps'
  []
  [ilu_low_mem]
    type = SMP
    full = true
    petsc_options = '-ksp_diagonal_scale -ksp_diagonal_scale_fix'
    petsc_options_iname = '-ksp_type -pc_type -sub_pc_type -sub_pc_factor_shift_type'
    petsc_options_value = 'gmres asm ilu NONZERO'
  []
  [hypre]
    type = SMP
    full = true
    petsc_options_iname = '-pc_type -pc_hypre_type'
    petsc_options_value = 'hypre boomeramg'
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 1
    growth_factor = 1.1
    optimal_iterations = 6
    cutback_factor = 0.8
  []

  # fixme Rob told me to try this.
  # The system doesn't change much once it is pressurized so the residual can't change much either
  # steady_state_detection = true
  # steady_state_start_time = 7000  #this should start after the system has pressurized
  # steady_state_tolerance = 1e-5   #fixme should be smaller than nl_resid

  dtmin = 1e-4
  dtmax = 1000 #courant condition Peclet number (advection versus diffusion) limits dtmax
  end_time = ${endTime}
  line_search = 'none'
  automatic_scaling = false
  l_max_its = 20
  l_tol = 8e-3
  nl_forced_its = 1
  nl_max_its = 20
  nl_rel_tol = 5e-05
  nl_abs_tol = 1e-10
[]

[Outputs]
  print_linear_residuals = false
  csv = true
  # [fracExodus]
  #   type = Exodus
  #   sync_times = '100 200 300 400 500 600 700 800 900
  #                 1000 2000 3000 4000 5000 '
  #                '6000 7000 8000 9000
  #                 1000e1 2000e1 3000e1 4000e1 5000e1 6000e1 '
  #                '7000e1 8000e1 9000e1
  #                 1000e2 2000e2 3000e2 4000e2 5000e2 6000e2 '
  #                '7000e2 8000e2 9000e2
  #                 1000e3 2000e3 3000e3 4000e3 5000e3 6000e3 '
  #                '7000e3 8000e3 9000e3
  #                 1000e4 2000e4 3000e4 4000e4 5000e4 6000e4 '
  #                '7000e4 8000e4 9000e4
  #                 1000e5 2000e5 3000e5 4000e5 5000e5 6000e5 '
  #                '7000e5 8000e5 9000e5'
  #   sync_only = true
  # []
[]

# Units K,m,Pa,Kg,s
# Cold water injection into one side of the fracture network, and production from the other side
frac_permeability = 1e-12
injection_rate = 10 # kg/s
endTime = 40e5
# fixme Som.  I was using endTime=6e5 and
# as you saw in the figures I sent you, the temperature doesn't
# even come close to reaching the production point when it is 150m from the injection.
# NOTE that entTime=6e5 took 4.5 hours on my Mac with 6 procs
injection_temp = 300
depth = 3000

#injection coordinates
x_in = 0
y_in = 0
z_in = -75
#production   z-location of line
x_out = 0 # this should be zero because the fracture is on the yz plane
y_out = -0.317051 # For 2m elements, this should be within +-1
z_out = -55.0781 # this is 20m from the inlet.  Maybe do 20, 50, 100, 150

#FIXME Som!!!!!
# you will have to manually set these to node locations that are
# close to where the production well is intersecting the fracture block.
# The closest node search is not block restricted so it is possible for it to grab a matrix node and that would
# give you really bad results so you need to manually find a node that is close to x,y,z=(0,0,z_out)
# I am trying to fix this but to get Rob some results you will need to manually find the nodal coords in paraview
# and set them here.

[Mesh]
  [fmg]
    #FIXME Som, Rob said this mesh is good, maybe it could be coarser and then use AMR to refine it.
    type = FileMeshGenerator
    file = 'ellipseInMatrix.e'
  []
[]

[GlobalParams]
  PorousFlowDictator = dictator
  gravity = '0 0 -9.81'
[]

[Variables]
  [frac_P]
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

[AuxVariables]
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
[]

[AuxKernels]
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
    projection_tolerance = 2
    execute_on = TIMESTEP_BEGIN
    outputs = none
  []
  [P_in]
    type = ClosestNodeData
    variable = frac_P
    point_x = inject_pt/pt_x
    point_y = inject_pt/pt_y
    point_z = inject_pt/pt_z
    projection_tolerance = 2
    execute_on = TIMESTEP_BEGIN
    outputs = none
  []
  [T_in]
    type = ClosestNodeData
    variable = frac_T
    point_x = inject_pt/pt_x
    point_y = inject_pt/pt_y
    point_z = inject_pt/pt_z
    projection_tolerance = 2
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

  [prod_line]
    type = ConstantReporter
    real_vector_names = 'pt1_x pt1_y pt1_z pt2_x pt2_y pt2_z'
    real_vector_values = '-50; 0; ${z_out}; 50; 0; ${z_out}'
    outputs = none
  []
  [prod_elems]
    type = ClosestElemsToLineWithValues
    projection_tolerance = 5
    point_x1 = prod_line/pt1_x
    point_y1 = prod_line/pt1_y
    point_z1 = prod_line/pt1_z
    point_x2 = prod_line/pt2_x
    point_y2 = prod_line/pt2_y
    point_z2 = prod_line/pt2_z
    value = 0.1
    variable = viscosity
    block = fracture
    outputs = none
  []

  [prod_pt]
    type = ConstantReporter
    real_vector_names = 'pt_x pt_y pt_z'
    real_vector_values = '${x_out}; ${y_out}; ${z_out}'
    outputs = none
  []
  [T_out]
    type = ClosestNodeData
    variable = frac_T
    point_x = prod_pt/pt_x
    point_y = prod_pt/pt_y
    point_z = prod_pt/pt_z
    projection_tolerance = 2
    execute_on = TIMESTEP_BEGIN
    outputs = none
  []
  [P_out]
    type = ClosestNodeData
    variable = frac_P
    point_x = prod_pt/pt_x
    point_y = prod_pt/pt_y
    point_z = prod_pt/pt_z
    projection_tolerance = 2
    execute_on = TIMESTEP_BEGIN
    outputs = none
  []
  [tracer_out]
    type = ClosestNodeData
    variable = tracer
    point_x = prod_pt/pt_x
    point_y = prod_pt/pt_y
    point_z = prod_pt/pt_z
    projection_tolerance = 2
    execute_on = TIMESTEP_BEGIN
    outputs = none
  []
  [var_out]
    type = ReporterVectorComponents
    reporters = 'P_out/node_id P_out/node_x P_out/node_y P_out/node_z P_out/frac_P T_out/frac_T '
                'tracer_out/tracer'
    indices = '0'
  []

  #--------------------- THESE DO NOT WORK YET FOR OUTPUT -------------------
  # [T_out]
  #   type = ClosestElemsToLineWithValues
  #   projection_tolerance = 5
  #   point_x1 = prod_line/pt1_x
  #   point_y1 = prod_line/pt1_y
  #   point_z1 = prod_line/pt1_z
  #   point_x2 = prod_line/pt2_x
  #   point_y2 = prod_line/pt2_y
  #   point_z2 = prod_line/pt2_z
  #   variable = frac_T
  #   block = fracture
  #   outputs = none
  # []
  # [P_out]
  #   type = ClosestElemsToLineWithValues
  #   projection_tolerance = 5
  #   point_x1 = prod_line/pt1_x
  #   point_y1 = prod_line/pt1_y
  #   point_z1 = prod_line/pt1_z
  #   point_x2 = prod_line/pt2_x
  #   point_y2 = prod_line/pt2_y
  #   point_z2 = prod_line/pt2_z
  #   variable = frac_P
  #   block = fracture
  #   outputs = none
  # []
  # [tracer_out]
  #   type = ClosestElemsToLineWithValues
  #   projection_tolerance = 5
  #   point_x1 = prod_line/pt1_x
  #   point_y1 = prod_line/pt1_y
  #   point_z1 = prod_line/pt1_z
  #   point_x2 = prod_line/pt2_x
  #   point_y2 = prod_line/pt2_y
  #   point_z2 = prod_line/pt2_z
  #   variable = tracer
  #   block = fracture
  #   outputs = none
  # []
  # [var_out]
  #   type = ReporterVectorComponents
  #   reporters = 'P_out/elem_id P_out/point_x P_out/point_y P_out/point_z P_out/frac_P T_out/frac_T '
  #               'tracer_out/tracer'
  #   indices = '0'
  # []
  #--------------------- THESE DO NOT WORK YET FOR OUTPUT -------------------

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
    pressure = frac_P
    fp = water
  []

  [withdraw_fluid]
    type = PorousFlowPeacemanBorehole
    SumQuantityUO = kg_out_uo
    bottom_p_or_t = insitu_pp_borehole
    mass_fraction_component = 1
    character = 1
    line_length = 1
    x_coord_reporter = 'prod_elems/point_x'
    y_coord_reporter = 'prod_elems/point_y'
    z_coord_reporter = 'prod_elems/point_z'
    weight_reporter = 'prod_elems/value'
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
    x_coord_reporter = 'prod_elems/point_x'
    y_coord_reporter = 'prod_elems/point_y'
    z_coord_reporter = 'prod_elems/point_z'
    weight_reporter = 'prod_elems/value'
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
    x_coord_reporter = 'prod_elems/point_x'
    y_coord_reporter = 'prod_elems/point_y'
    z_coord_reporter = 'prod_elems/point_z'
    weight_reporter = 'prod_elems/value'
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
  [porosity_frac]
    #FIXME Som  Rob said to try this as a test, it should affect the fluid velocity, but he's not sure for a 2D block…..
    type = PorousFlowPorosity
    # porosity_zero = 0.1
    porosity_zero = 0.9
    block = fracture
  []
  [permeability_frac]
    type = PorousFlowPermeabilityConst
    permeability = '${frac_permeability} 0 0   0 ${frac_permeability} 0   0 0 ${frac_permeability}'
    block = fracture
  []
  [internal_energy_frac]
    type = PorousFlowMatrixInternalEnergy
    density = 2700
    specific_heat_capacity = 0
    block = fracture
  []
  [aq_thermal_conductivity_frac]
    type = PorousFlowThermalConductivityIdeal
    dry_thermal_conductivity = '0.6E-4 0 0  0 0.6E-4 0  0 0 0.6E-4'
    block = fracture
  []

  [porosity_matrix]
    type = PorousFlowPorosity
    # porosity_zero = 0.1  #FIXME Som  If the below doesn't work, I got it to run with this
    porosity_zero = 0.001
    block = matrix
  []
  [permeability_matrix]
    type = PorousFlowPermeabilityConst
    # permeability = '1e-16 0 0   0 1e-16 0   0 0 1e-16' #FIXME Som  If the below doesn't work, I got it to run with this
    permeability = '1e-18 0 0   0 1e-18 0   0 0 1e-18'
    block = matrix
  []
  [internal_energy_matrix]
    type = PorousFlowMatrixInternalEnergy
    # density = 2875  #FIXME Som  If the below doesn't work, I got it to run with this
    # specific_heat_capacity = 825
    density = 2750
    specific_heat_capacity = 790
    block = matrix
  []
  [aq_thermal_conductivity_matrix]
    type = PorousFlowThermalConductivityIdeal
    # dry_thermal_conductivity = '2.83 0 0  0 2.83 0  0 0 2.83'  #FIXME Som  If the below doesn't work, I got it to run with this
    dry_thermal_conductivity = '3.05 0 0  0 3.05 0  0 0 3.05'
    block = matrix
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
    value = '9.81*1000*(${depth} - z)'
  []
  #FIXME LYNN SHOULD BE ABLE TO DELETE THIS SINCE APERTURE INDEPENDENT PERMEABILITY
  # approx insitu at production point, to prevent aperture closing due to low porepressures
  [insitu_pp_borehole]
    type = ParsedFunction
    value = '9810 * (${depth} - z) + 1000' # Approximate hydrostatic in Pa + 1MPa
  []
  [insitu_T]
    type = ParsedFunction
    value = '473-75/1000*(z-${z_in})'
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

[Preconditioning]
  active = preferred
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
    dt = 200
    growth_factor = 1.1
    optimal_iterations = 6
    cutback_factor = 0.8
  []
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
  exodus = true
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

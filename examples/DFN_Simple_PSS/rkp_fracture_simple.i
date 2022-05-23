# Cold water injection into one side of the fracture network, and production from the other side
injection_rate = 10 # kg/s

# #injection coordinates (1/8th mesh)
# x_in = -241
# y_in = 262
# z_in = -50
# #production coordinates (1/8th mesh)
# x_out = -227 # (-150)
# y_out = 267 # (-200)
# z_out = -37 # (-150)

#injection coordinates (full mesh)
x_in = 108.34 # -300.0 # -521 #
y_in = 111.259 # 0.0 # 145 #
z_in = 28.1198 # -300.0 # -18 #
#production coordinates (full mesh)
x_out = 108.34
y_out = 111.259
z_out = 28.1198

[Mesh]
  uniform_refine = 0
  [cluster34]
    type = FileMeshGenerator
    file = 'Cluster_34.exo'
  []
[]

[GlobalParams]
  PorousFlowDictator = dictator
  gravity = '0 0 -9.81'
[]

[Variables]
  [frac_P]
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
[]

[PorousFlowFullySaturated]
  porepressure = frac_P
  mass_fraction_vars = 'tracer'
  coupling_type = Hydro
  fp = simple_fluid
  stabilization = Full
[]

[UserObjects]
  [kg_out_uo]
    type = PorousFlowSumQuantity
  []
  [tracer_kg_out_uo]
    type = PorousFlowSumQuantity
  []
[]

[Modules]
  [FluidProperties]
    [simple_fluid]
      type = SimpleFluidProperties
      viscosity = 0.0001
    []
  []
[]
# pressure, temperature, density, viscosity, enthalpy, internal_energy
# 1.10808e+06, 383.333, 951.275, 0.00025442, 462841, 461676


[AuxVariables]
  [aperture]
    family = MONOMIAL
    order = CONSTANT
  []
  [perm_times_app]
    family = MONOMIAL
    order = CONSTANT
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
  [frac_P_Pa]
    family = LAGRANGE
    order = FIRST
  []
[]

[AuxKernels]
  [aperture]
    type = PorousFlowPropertyAux
    variable = aperture
    property = porosity
  []
  [perm_times_app]
    type = PorousFlowPropertyAux
    variable = perm_times_app
    property = permeability
    row = 0
    column = 0
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
  [insitu_pp]
    type = FunctionAux
    execute_on = initial
    variable = insitu_pp
    function = insitu_pp
  []
[]

[Reporters]
  [inject_pt]
    type=ConstantReporter
    real_vector_names = 'pt_x pt_y pt_z'
    real_vector_values = '${x_in}; ${y_in}; ${z_in}'
    outputs = none
  []
  [inject_node]
    type=ClosestNode
    point_x = inject_pt/pt_x
    point_y = inject_pt/pt_y
    point_z = inject_pt/pt_z
    projection_tolerance = 100
    execute_on = TIMESTEP_BEGIN
    outputs = none
  []
  [P_in]
    type=ClosestNodeData
    variable=frac_P
    point_x = inject_pt/pt_x
    point_y = inject_pt/pt_y
    point_z = inject_pt/pt_z
    projection_tolerance = 100
    execute_on = TIMESTEP_BEGIN
    outputs = none
  []
  [var_in]
    type = ReporterVectorComponents
    reporters = 'P_in/node_x P_in/node_y P_in/node_z P_in/frac_P' # P_in/node_id
    indices='0'
  []
  # [var_in]
  #   type = AccumulateReporter
  #   reporters = 'P_in/node_id P_in/node_x P_in/node_y P_in/node_z P_in/frac_P'
  #   outputs = var_in
  # []

  [prod_pt]
    type=ConstantReporter
    real_vector_names = 'pt_val pt_x pt_y pt_z'
    real_vector_values = '0.01; ${x_out}; ${y_out}; ${z_out}'
    outputs = none
    # 0.01 is the borehole radius
  []
  [prod_node]
    type=ClosestNodeProjector
    point_value =  prod_pt/pt_val
    point_x = prod_pt/pt_x
    point_y = prod_pt/pt_y
    point_z = prod_pt/pt_z
    projection_tolerance = 100
    execute_on = TIMESTEP_BEGIN
    outputs = none
  []

  [P_out]
    type=ClosestNodeData
    variable=frac_P
    point_x = prod_pt/pt_x
    point_y = prod_pt/pt_y
    point_z = prod_pt/pt_z
    projection_tolerance = 100
    execute_on = TIMESTEP_BEGIN
    outputs = none
  []
  [tracer_out]
    type=ClosestNodeData
    variable=tracer
    point_x = prod_pt/pt_x
    point_y = prod_pt/pt_y
    point_z = prod_pt/pt_z
    projection_tolerance = 100
    execute_on = TIMESTEP_END
    outputs = none
  []

  # [test_pt]
  #   type=ConstantReporter
  #   real_vector_names = 'pt_x pt_y pt_z'
  #   real_vector_values = '-245.8; 254.4; -57.8'
  #   outputs = none
  # []
  # [tracer_test]
  #   type=ClosestNodeData
  #   variable=tracer
  #   point_x = test_pt/pt_x
  #   point_y = test_pt/pt_y
  #   point_z = test_pt/pt_z
  #   projection_tolerance = 100
  #   execute_on = TIMESTEP_BEGIN
  #   outputs = none
  # []
  [var_out]
    type = ReporterVectorComponents
    reporters = 'P_out/node_x P_out/node_y P_out/node_z P_out/frac_P
                 tracer_out/tracer' # P_out/node_id
    indices='0'
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
  [withdraw_fluid]
    type = PorousFlowPeacemanBorehole
    fluid_phase = 0
    mass_fraction_component = 1
    SumQuantityUO = kg_out_uo
    bottom_p_or_t = insitu_pp_borehole
    character = 1
    line_length = 1
    x_coord_reporter = 'prod_node/node_x'
    y_coord_reporter = 'prod_node/node_y'
    z_coord_reporter = 'prod_node/node_z'
    weight_reporter = 'prod_node/node_value'
    unit_weight = '0 0 0'
    use_mobility = true
    variable = frac_P
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
  []
[]

# #These are the DFN materials
# [Materials]
#   [porosity]
#     type = PorousFlowPorosityLinear
#     porosity_ref = 1E-4 # fracture porosity = 1.0, but must include fracture aperture of 1E-4 at P = insitu_pp
#     P_ref = insitu_pp
#     P_coeff = 1E-3 # this is in metres/MPa, ie for P_ref = 1/P_coeff, the aperture becomes 1 metre
#     porosity_min = 1E-5
#   []
#   [permeability]
#     type = PorousFlowPermeabilityKozenyCarman
#     k0 = 1E-15  # fracture perm = 1E-11 m^2, but must include fracture aperture of 1E-4
#     poroperm_function = kozeny_carman_phi0
#     m = 0
#     n = 3
#     phi0 = 1E-4
#   []
# []

#These are the properties from tutorial 1
[Materials]
  [porosity]
    type = PorousFlowPorosity
    porosity_zero = 0.1
  []
  [biot_modulus]
    type = PorousFlowConstantBiotModulus
    biot_coefficient = 0.8
    solid_bulk_compliance = 2E-7
    fluid_bulk_modulus = 1E7
  []
  #  From Rob:  cubic law perm formula is permeability = (aperture^2)/12
  #  so permeability of 1e-12 is aperture of about 1/10 of a mm
  [permeability_aquifer]
    type = PorousFlowPermeabilityConst
    permeability = '1E-12 0 0   0 1E-12 0   0 0 1E-12'
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
    value = '9810 * (2500 -z)'  # Approximate hydrostatic in Pa
  []
  # approx insitu at production point, to prevent aperture closing due to low porepressures
  [insitu_pp_borehole]
    type = ParsedFunction
     value = '9810 * (2500 - z) + 1000000' # Approximate hydrostatic in Pa + 1MPa
  []
[]

[Postprocessors]
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
  [tracer_kg_out]
    type = PorousFlowPlotQuantity
    uo = tracer_kg_out_uo
  []
  [tracer_kg_per_s]
    type = FunctionValuePostprocessor
    function = tracer_kg_rate
  []
  [int_tracer]
    type = TimeIntegratedReporterPP
    reporter = 'tracer_out/tracer'
    use_negative_value = true
    execute_on = TIMESTEP_END
  []
[]

[Preconditioning]
   active = preferred
   [./superlu]
     type = SMP
     full = true
     petsc_options_iname = '-ksp_type -pc_type -pc_factor_mat_solver_package'
     petsc_options_value = 'gmres lu superlu_dist'
   [../]
   [./preferred]
     type = SMP
     full = true
     petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
     petsc_options_value = ' lu       mumps'
   [../]
   [./ilu_low_mem]
     type = SMP
     full = true
     petsc_options = '-ksp_diagonal_scale -ksp_diagonal_scale_fix'
     petsc_options_iname = '-ksp_type -pc_type -sub_pc_type -sub_pc_factor_shift_type'
     petsc_options_value = 'gmres asm ilu NONZERO'
   [../]
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
    dt = 50
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
  end_time = 1e5 # 8.64e5 # 1.728e6 #
  # num_steps = 1
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
  csv=false
  exodus=false
  # sync_times = '1e3 2e3 3e3 4e3 5e3 6e3 7e3 8e3 9e3 1e4 2e4 3e4 4e4 5e4 6e4 7e4 8e4 9e4 1e5 2e5 3e5 4e5 5e5 6e5 7e5 8e5 9e5 10e5'
  # sync_only = true
  # [out]
  #   type = Exodus
  #   sync_times = '1 10 100 200 300 400 500 600 700 800 900
  #   1000 1100 1200 1300 1400 1500 1600 1700 1800 1900
  #   2000 2100 2200 2300 2400 2500 2600 2700 2800 2900
  #   3000 3100 3200 3300 3400 3500 3600 3700 3800 3900
  #   4000 4100 4200 4300 4400 4500 4600 4700 4800 4900
  #   5000 5100 5200 5300 5400 5500 5600 5700 5800 5900
  #   6000 6100 6200 6300 6400 6500 6600 6700 6800 6900
  #   7000 7100 7200 7300 7400 7500 7600 7700 7800 7900
  #   8000 8100 8200 8300 8400 8500 8600 8700 8800 8900
  #   9000 9100 9200 9300 9400 9500 9600 9700 9800 9900
  #   10000 11000 12000 13000 14000 15000 16000 17000 18000 19000
  #   20000 21000 22000 23000 24000 25000 26000 17000 28000 29000
  #   30000 31000 32000 33000 34000 35000 36000 37000 38000 39000
  #   40000 41000 42000 43000 44000 45000 46000 47000 48000 49000
  #   50000 51000 52000 53000 54000 55000 56000 57000 58000 59000
  #   60000 61000 62000 63000 64000 65000 66000 67000 68000 69000
  #   70000 71000 72000 73000 74000 75000 76000 77000 78000 79000
  #   80000 81000 82000 83000 84000 85000 96000 87000 88000 89000
  #   90000 91000 92000 93000 94000 95000 06000 97000 98000 99000
  #   100000 200000 300000 400000 500000 600000 700000 800000 900000
  #   1000000 1100000 1200000 1300000 1400000 1500000 1600000 1700000 1800000 1900000
  #   2e6 3e6 4e6 5e6 6e6 7e6 8e6 9e6
  #   1e7 2e7 3e7 4e7 5e7 6e7 7e7 8e7 9e7
  #   1e8'
  #   sync_only = true
  # []
  # [var_in]
  #   type = JSON
  #   execute_system_information_on = none
  #   execute_on = 'FINAL'
  #   #file_base = 'var_in'
  # []
  # [var_out]
  #   type = JSON
  #   execute_system_information_on = none
  #   execute_on = 'FINAL'
  #   #file_base = 'var_out'
  # []
[]

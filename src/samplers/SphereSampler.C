//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "SphereSampler.h"
#include "Distribution.h"
#include "Normal.h"
#include "Uniform.h"

registerMooseObject("FalconApp", SphereSampler);

InputParameters
SphereSampler::validParams()
{
  InputParameters params = Sampler::validParams();
  params.addClassDescription("Testing fracture plane sampler.");
  params.addRequiredParam<dof_id_type>("num_rows", "The number of rows per matrix to generate.");
  params.addRequiredRangeCheckedParam<Real>("Radius", "Radius > 0", "Radius of the circular fracture plane.");
  params.addRequiredParam<std::vector<Real>>("center_coords", "Coordinates of the circular fracture plane center.");
  return params;
}

SphereSampler::SphereSampler(const InputParameters & parameters)
  : Sampler(parameters),
    // _step(getCheckedPointerParam<FEProblemBase *>("_fe_problem_base")->timeStep()),
    _Radius(getParam<Real>("Radius")),
    _center_coords(getParam<std::vector<Real>>("center_coords"))
{

  setNumberOfRows(getParam<dof_id_type>("num_rows"));
  setNumberOfCols(3);

  // _check_step = 1000;

  _coords_req.resize(3);

  // setNumberOfRandomSeeds(100000);
}

Real
SphereSampler::computeSample(dof_id_type /*row_index*/, dof_id_type col_index)
{
  _phi = getRand() * 2 * 3.141592653;
  _costheta = -1 + 2 * getRand();
  _u = getRand();
  _theta = std::acos(_costheta);
  _r = _Radius * std::pow(_u, 1/3);

  _coords_req[0] = _r * std::sin(_theta) * std::cos(_phi) + _center_coords[0];
  _coords_req[1] = _r * std::sin(_theta) * std::sin(_phi) + _center_coords[1];
  _coords_req[2] = _r * std::cos(_theta) + _center_coords[2];
  return _coords_req[col_index];
}

//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "SphereSamplerSerial.h"
#include "Distribution.h"
#include "Normal.h"
#include "Uniform.h"

registerMooseObject("FalconApp", SphereSamplerSerial);

InputParameters
SphereSamplerSerial::validParams()
{
  InputParameters params = Sampler::validParams();
  params.addClassDescription("Testing fracture plane sampler.");
  // params.addRequiredParam<dof_id_type>("num_rows", "The number of rows per matrix to generate.");
  params.addRequiredRangeCheckedParam<Real>("Radius", "Radius > 0", "Radius of the circular fracture plane.");
  params.addRequiredParam<std::vector<Real>>("center_coords", "Coordinates of the circular fracture plane center.");
  return params;
}

SphereSamplerSerial::SphereSamplerSerial(const InputParameters & parameters)
  : Sampler(parameters),
    _step(getCheckedPointerParam<FEProblemBase *>("_fe_problem_base")->timeStep()),
    _Radius(getParam<Real>("Radius")),
    _center_coords(getParam<std::vector<Real>>("center_coords"))
{

  setNumberOfRows(1);
  setNumberOfCols(3);

  _check_step = 1000;

  _coords_req.resize(3);

  setNumberOfRandomSeeds(100000);
}

Real
SphereSamplerSerial::computeSample(dof_id_type /*row_index*/, dof_id_type col_index)
{
  const bool sample = col_index == 0 && _check_step != _step;
  if (sample)
  {
    _r = 1e8;
    while (_r > _Radius)
    {
      _x1 = 2 * _Radius * getRand(_step) - _Radius;
      _x2 = 2 * _Radius * getRand(_step) - _Radius;
      _x3 = 2 * _Radius * getRand(_step) - _Radius;
      _r = std::pow((_x1 * _x1 + _x2 * _x2 + _x3 * _x3), 0.5);
    }
    _coords_req[0] = _x1 + _center_coords[0];
    _coords_req[1] = _x2 + _center_coords[1];
    _coords_req[2] = _x3 + _center_coords[2];
  }
  _check_step = _step;
  return _coords_req[col_index];
}

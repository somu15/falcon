//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "BoxSamplerSerial.h"
#include "Distribution.h"
#include "Normal.h"
#include "Uniform.h"

registerMooseObject("FalconApp", BoxSamplerSerial);

InputParameters
BoxSamplerSerial::validParams()
{
  InputParameters params = Sampler::validParams();
  params.addClassDescription("Testing fracture plane sampler.");
  // params.addRequiredParam<dof_id_type>("num_rows", "The number of rows per matrix to generate.");
  params.addRequiredRangeCheckedParam<Real>("Radius", "Radius > 0", "Radius of the circular fracture plane.");
  params.addRequiredParam<std::vector<Real>>("center_coords", "Coordinates of the circular fracture plane center.");
  params.addRequiredParam<std::vector<Real>>("unit_normal", "Unit normal of the circular fracture plane center.");
  return params;
}

BoxSamplerSerial::BoxSamplerSerial(const InputParameters & parameters)
  : Sampler(parameters),
    _step(getCheckedPointerParam<FEProblemBase *>("_fe_problem_base")->timeStep()),
    _Radius(getParam<Real>("Radius")),
    _center_coords(getParam<std::vector<Real>>("center_coords")),
    _unit_normal(getParam<std::vector<Real>>("unit_normal"))
{

  setNumberOfRows(1); // getParam<dof_id_type>("num_rows")
  setNumberOfCols(4);

  _check_step = 1000;

  _plane_const = _center_coords[0] * _unit_normal[0] + _center_coords[1] * _unit_normal[1] + _center_coords[2] * _unit_normal[2];
  Real tmp1 = std::sqrt((std::pow(_unit_normal[0], 2) + std::pow(_unit_normal[1], 2)));
  _basis1.resize(3);
  _basis2.resize(3);
  _basis1[0] = -_unit_normal[1] / tmp1; _basis1[1] = _unit_normal[0] / tmp1; _basis1[2] = 0.0;
  _basis2[0] = -_unit_normal[2] * _unit_normal[0] / tmp1; _basis2[1] = -_unit_normal[2] * _unit_normal[1] / tmp1; _basis2[2] = std::pow(tmp1, 2) / tmp1;
  Real detM = _basis1[0] * (_basis2[1] * _unit_normal[2] - _basis2[2] * _unit_normal[1]) - _basis2[1] * (_basis1[0] * _unit_normal[2] - _basis1[2] * _unit_normal[0]) + _unit_normal[0] * (_basis1[1] * _basis2[2]);
  _invM.resize(9);
  _invM[0] = (_basis2[1] * _unit_normal[2] - _basis2[2] * _unit_normal[1]) / detM;
  _invM[1] = -(_basis1[1] * _unit_normal[2]) / detM;
  _invM[2] = (_basis1[1] * _basis2[2]) / detM;
  _invM[3] = -(_basis2[0] * _unit_normal[2] - _basis2[2] * _unit_normal[0]) / detM;
  _invM[4] = (_basis1[0] * _unit_normal[2]) / detM;
  _invM[5] = -(_basis1[0] * _basis2[2]) / detM;
  _invM[6] = (_basis2[0] * _unit_normal[1] - _basis2[1] * _unit_normal[0]) / detM;
  _invM[7] = -(_basis1[0] * _unit_normal[1] - _basis1[1] * _unit_normal[0]) / detM;
  _invM[8] = (_basis1[0] * _basis2[1] - _basis1[1] * _basis2[0]) / detM;

  _coords_req.resize(4);

  setNumberOfRandomSeeds(100000);
}

std::vector<Real>
BoxSamplerSerial::computeCoords(const Real & p, const Real & p2, const Real & Radius, const std::vector<Real> & center_coords, const std::vector<Real> & basis1, const std::vector<Real> & basis2, const std::vector<Real> & invM, const Real & plane_const)
{
  Real r = Radius * std::sqrt(p);
  Real th = p2 * 2 * 3.141592653;

  Real tmpx = r * std::cos(th);
  Real tmpy = r * std::sin(th);

  std::vector<Real> c1;
  c1.resize(3);
  c1[0] = tmpx + center_coords[0]*basis1[0] + center_coords[1]*basis1[1] + center_coords[2]*basis1[2];
  c1[1] = tmpy + center_coords[0]*basis2[0] + center_coords[1]*basis2[1] + center_coords[2]*basis2[2];
  c1[2] = plane_const;

  std::vector<Real> value_req;
  value_req.resize(3);

  value_req[0] = invM[0] * c1[0] + invM[1] * c1[1] + invM[2] * c1[2];
  value_req[1] = invM[3] * c1[0] + invM[4] * c1[1] + invM[5] * c1[2];
  value_req[2] = invM[6] * c1[0] + invM[7] * c1[1] + invM[8] * c1[2];

  return value_req;
}

Real
BoxSamplerSerial::computeSample(dof_id_type /*row_index*/, dof_id_type col_index)
{
  const bool sample = col_index == 0 && _check_step != _step;
  if (sample)
  {
    std::vector<Real> tmp = computeCoords(getRand(_step), getRand(_step*2), _Radius, _center_coords, _basis1, _basis2, _invM, _plane_const);
    _coords_req[0] = 0.01;
    _coords_req[1] = tmp[0];
    _coords_req[2] = tmp[1];
    _coords_req[3] = tmp[2];
    std::cout << "Sent coors ***** " << Moose::stringify(_coords_req) << std::endl;

    // _coords_req[0] = 0.01;
    // _coords_req[1] = 146.122;
    // _coords_req[2] = 105.908;
    // _coords_req[3] = 114.478;
  }

  _check_step = _step;
  return _coords_req[col_index];
}

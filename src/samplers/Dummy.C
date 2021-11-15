//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "Dummy.h"
#include "Distribution.h"

registerMooseObject("FalconApp", Dummy);

InputParameters
Dummy::validParams()
{
  InputParameters params = Sampler::validParams();
  params.addClassDescription("Testing fracture plane sampler.");
  params.addRequiredParam<std::vector<Real>>("coords", "Coordinates of the circular fracture plane center.");
  return params;
}

Dummy::Dummy(const InputParameters & parameters)
  : Sampler(parameters),
    _coords(getParam<std::vector<Real>>("coords"))
{
  setNumberOfRows(1);
  setNumberOfCols(4);
}

Real
Dummy::computeSample(dof_id_type /*row_index*/, dof_id_type col_index)
{
  return _coords[col_index];
}

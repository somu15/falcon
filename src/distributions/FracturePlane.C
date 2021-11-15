//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "FracturePlane.h"
#include "math.h"
#include "libmesh/utility.h"
// #include "DelimitedFileReader.h"
// #include "SystemBase.h"
// #include "Assembly.h"
// #include "Normal.h"
// #include "Uniform.h"

registerMooseObject("FalconApp", FracturePlane);

InputParameters
FracturePlane::validParams()
{
  InputParameters params = Distribution::validParams();
  params.addClassDescription("FracturePlane distribution");
  return params;
}

FracturePlane::FracturePlane(const InputParameters & parameters)
  : Distribution(parameters)
{
}

Real
FracturePlane::pdf(const Real & x)
{
  return x;
}

Real
FracturePlane::cdf(const Real & x)
{
  return x;
}

Real
FracturePlane::quantile(const Real & p)
{
  return p;
}

Real
FracturePlane::pdf(const Real & x) const
{
  return pdf(x);
}

Real
FracturePlane::cdf(const Real & x) const
{
  return cdf(x);
}

Real
FracturePlane::quantile(const Real & p) const
{
  return quantile(p);
}

//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "TimeIntegratedReporterPP.h"

registerMooseObject("MooseApp", TimeIntegratedReporterPP);
registerMooseObjectRenamed("MooseApp",
                           TotalVariableValue,
                           "04/01/2022 00:00",
                           TimeIntegratedReporterPP);

InputParameters
TimeIntegratedReporterPP::validParams()
{
  InputParameters params = GeneralPostprocessor::validParams();
  params.addClassDescription("Integrate a Postprocessor value over time using trapezoidal rule.");
  params.addRequiredParam<ReporterName>("reporter", "Reporter with the value.");
  params.addParam<bool>("use_negative_value", false, "Return negative value of the output.");
  return params;
}

TimeIntegratedReporterPP::TimeIntegratedReporterPP(const InputParameters & parameters)
  : GeneralPostprocessor(parameters),
    _value(0),
    _value_old(0),
    _pps_value(getReporterValue<std::vector<Real>>("reporter")),
    _pps_value_old(0),
    _use_negative_value(getParam<bool>("use_negative_value"))
{
}

void
TimeIntegratedReporterPP::initialize()
{
}

void
TimeIntegratedReporterPP::execute()
{
  _pps_value = getReporterValue<std::vector<Real>>("reporter");
  _value = _value_old + 0.5 * (_pps_value[0] + _pps_value_old) * _dt;
  _pps_value_old = _pps_value[0];
  _value_old = _value;
}

Real
TimeIntegratedReporterPP::getValue()
{
  return _use_negative_value ? (-_value) : _value;
}

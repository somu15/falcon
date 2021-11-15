//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "Sampler.h"

/**
 * A class used to perform Adaptive Importance Sampling using a Markov Chain Monte Carlo algorithm
 */
class TestMC : public Sampler
{
public:
  static InputParameters validParams();

  TestMC(const InputParameters & parameters);

protected:
  /// Return the sample for the given row and column
  virtual Real computeSample(dof_id_type row_index, dof_id_type col_index) override;

  const int & _step;

  /// Storage for distribution objects to be utilized
  std::vector<Distribution const *> _distributions;

  /// Distribution names
  // const std::vector<DistributionName> & _distribution_names;

  const Real & _Radius;

  const std::vector<Real> & _center_coords;

  const std::vector<Real> & _unit_normal;

  Real _plane_const;

  std::vector<Real> _basis1;

  std::vector<Real> _basis2;

  std::vector<Real> _invM;

private:

  std::vector<Real> computeCoords(const Real & p, const Real & p2, const Real & Radius, const std::vector<Real> & center_coords, const std::vector<Real> & basis1, const std::vector<Real> & basis2, const std::vector<Real> & invM, const Real & plane_const);

  int _check_step;

  std::vector<Real> _coords_req;

};

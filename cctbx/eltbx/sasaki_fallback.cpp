#include <cctbx/eltbx/sasaki.h>
#include <cctbx/eltbx/henke.h>

#include <stdexcept>

namespace cctbx { namespace eltbx { namespace sasaki {

table::table(std::string const&, bool, bool)
: info_(0)
{}

fp_fdp
table::at_ev(double) const
{
  throw std::runtime_error("Sasaki anomalous-scattering tables are not packaged");
}

table_iterator::table_iterator()
: current_()
{}

table
table_iterator::next()
{
  return current_;
}

}}} // namespace cctbx::eltbx::sasaki

namespace cctbx { namespace eltbx { namespace henke {

table::table(std::string const&, bool, bool)
: label_z_e_fp_fdp_(0)
{}

fp_fdp
table::at_ev(double) const
{
  throw std::runtime_error("Henke anomalous-scattering tables are not packaged");
}

table_iterator::table_iterator()
: current_()
{}

table
table_iterator::next()
{
  return current_;
}

}}} // namespace cctbx::eltbx::henke

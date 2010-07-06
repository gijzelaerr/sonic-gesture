
#include "stabilizer.h"
#include <gtest/gtest.h>

// Tests the default c'tor.
TEST(Stabilizer, DefaultConstructor) {
  const Stabilizer s(10);

  EXPECT_EQ(false, s.is_active());
}
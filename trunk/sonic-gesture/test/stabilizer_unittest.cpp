#include "stabilizer.h"
#include <gtest/gtest.h>


// Tests the default c'tor.
TEST(Stabilizer, DefaultConstructor) {
  Stabilizer s;

  EXPECT_STREQ(NULL, s.c_string());
  EXPECT_EQ(0u, s.Length());
}
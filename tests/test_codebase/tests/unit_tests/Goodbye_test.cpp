#include "third_party/doctest/doctest.h"

#include "someb/Goodbye.hpp"

TEST_CASE("a Goodbye test") {
  SUBCASE("empty string") {
    Goodbye* g = new Goodbye{};
    CHECK_NE(g, nullptr);
    delete g;
  }
}


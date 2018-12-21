#include "somea/Hello.hpp"
#include "someb/Goodbye.hpp"

int main () {

  Hello h{};
  h.say_hello();

  Goodbye g{};
  g.say_goodbye();

  return (0);
}


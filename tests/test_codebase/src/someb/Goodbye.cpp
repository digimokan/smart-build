#include <cstdio>

#include "somea/Hello.hpp"
#include "someb/Goodbye.hpp"

void Goodbye::say_goodbye () {
  printf("\nGoodbye!\n");
  Hello h{};
  printf("\nGoodbye Talking:   ");
  h.say_hello();
}


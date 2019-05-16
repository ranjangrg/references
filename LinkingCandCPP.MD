# Steps:

1.	Create CPP object (using: g++ -c code.cpp -o codeCpp.o)
2.	Create Wrapper object (using: g++ -c Wrapper.cc -o Wrapper.o)
3.	Create C object (using: gcc -c code.c -o codeC.o)
4.	Link C object with wrapper (using: g++ codeC.o Wrapper.o codeCpp.o -o main.out)

# Files:
## Animal.cc
```cpp
	#include "Animal.h"
	#include <iostream>

	Animal::Animal() {
		id = 15;
		atk = 63;
		def = 90;
		spd = 67;
	}

	void Animal::show() {
		std::cout << "ID\t" << id << std::endl;
		std::cout << "ATK\t" << atk << std::endl;
		std::cout << "DEF\t" << def << std::endl;
		std::cout << "SPEED\t" << spd << std::endl;
	}
```
## Animal.h
```cpp
	#ifndef __ANIMAL_H
		#define __ANIMAL_H
		class Animal {
			private:
				int id, atk, def, spd;
			public:
				Animal();
				void show();
		};
	#endif
```

## Wrapper.cc
```cpp
	#include "Animal.h"
	#include "Wrapper.h"

	extern "C" {
		Animal* newAnimal() {
			return new Animal();
		}

		void showAnimal(Animal* animal) {
			animal->show();
		}

		void deleteAnimal(Animal* animal) {
			delete animal;
		}

	}
```

## Wrapper.h
```cpp
	#ifndef __WRAPPER_H
		#define __WRAPPER_H

		#ifdef __cplusplus
			extern "C" {
		#endif

		typedef struct Animal Animal;

		Animal* newAnimal();

		void showAnimal(Animal* animal);

		void deleteAnimal(Animal* animal);

		#ifdef __cplusplus
			}
		#endif

	#endif
```

# mainCode.c
```c
	#include "Wrapper.h"
	#include <stdio.h>

	int main() {
		struct Animal* dog = newAnimal();
		showAnimal(dog);

		deleteAnimal(dog);

		return 1;
	}
```
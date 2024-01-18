//
//  main.cpp
//  SwiftConsumer
//
//  Created by Daniel Kennett (Cascable) on 2024-01-17.
//

#include <iostream>
#include "SwiftWrapper.hpp"

using namespace SwiftWrapper;

int main(int argc, const char * argv[]) {
    // insert code here...

/*
    APIEnum enumValue = APIEnum::caseOne();
    if (enumValue.isCaseOne()) {
        std::cout << "Case one!" << "\n";
    } else if (enumValue.isCaseTwo()) {
        std::cout << "Case two!" << "\n";
    }

    bool isOne = (enumValue == APIEnum::caseOne());
    if (isOne) {
        std::cout << "Case one (again)!" << "\n";
    }

    int rawValue = enumValue.getRawValue();
    std::cout << std::to_string(rawValue) << "\n";
    std::cout << std::to_string(APIEnum::caseTwo().getRawValue()) << "\n";

    APIStruct structValue = APIStruct(APIEnum::caseTwo());
    APIStruct returnedStructValue = instance.doWork(structValue);
    bool structsMatch = (structValue.getEnumValue() == returnedStructValue.getEnumValue());

    if (structsMatch) {
        std::cout << "Match!" << "\n";
    }
 */

    APIClass instance = APIClass();
    std::cout << instance.getText() << "\n";
    std::cout << instance.sayHello("Daniel") << "\n";


    return 0;
}

//
//  SwiftWrapper.hpp
//  SwiftConsumer
//
//  Created by Daniel Kennett (Cascable) on 2024-01-17.
//

#ifndef SwiftWrapper_hpp
#define SwiftWrapper_hpp

#include <stdio.h>
#include <string>

namespace UnmanagedSwiftWrapper {

class APIClass;
class APIStruct;
class APIEnum;

class APIClass {
public:
    class APIClass_Internal;
    std::shared_ptr<APIClass_Internal> internal;
    APIClass(std::shared_ptr<APIClass_Internal> wrapped);
    APIClass();
    ~APIClass();
    std::string getText();
    std::string sayHello(const std::string & name);
    APIStruct doWork(APIStruct structValue);
};

class APIStruct {
public:
    class APIStruct_Internal;
    APIStruct(std::shared_ptr<APIStruct_Internal> wrapped);
    std::shared_ptr<APIStruct_Internal> internal;
    APIStruct(APIEnum);
    ~APIStruct();

    APIEnum getEnumValue();
};

class APIEnum {
public:
    class APIEnum_Internal;
    APIEnum(std::shared_ptr<APIEnum_Internal> wrapped);
    std::shared_ptr<APIEnum_Internal> internal;
    ~APIEnum();

    bool operator==(const APIEnum &other) const;

    bool isCaseOne();
    bool isCaseTwo();

    int getRawValue();

    static APIEnum caseOne();
    static APIEnum caseTwo();
};

}

#endif /* SwiftWrapper_hpp */

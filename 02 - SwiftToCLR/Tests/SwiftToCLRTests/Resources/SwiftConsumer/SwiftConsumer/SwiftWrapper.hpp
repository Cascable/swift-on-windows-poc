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

namespace BasicTest {
class APIClass;
class APIStruct;
class APIEnum;
}

namespace UnmanagedSwiftWrapper {

class APIClass;
class APIStruct;
class APIEnum;

class APIClass {
public:
    std::shared_ptr<BasicTest::APIClass> internal;
    APIClass(std::shared_ptr<BasicTest::APIClass> wrapped);
    APIClass();
    ~APIClass();
    std::string getText();
    std::string sayHello(const std::string & name);
    APIStruct doWork(APIStruct structValue);
};

class APIStruct {
public:
    APIStruct(std::shared_ptr<BasicTest::APIStruct> wrapped);
    std::shared_ptr<BasicTest::APIStruct> internal;
    APIStruct(APIEnum);
    ~APIStruct();

    APIEnum getEnumValue();
};

class APIEnum {
public:
    APIEnum(std::shared_ptr<BasicTest::APIEnum> wrapped);
    std::shared_ptr<BasicTest::APIEnum> internal;
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

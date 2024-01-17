//
//  SwiftWrapper.cpp
//  SwiftConsumer
//
//  Created by Daniel Kennett (Cascable) on 2024-01-17.
//

#include "SwiftWrapper.hpp"
#include <BasicTest-Swift.h>

// NOTE: The internal classes need to go first.

class UnmanagedSwiftWrapper::APIStruct::APIStruct_Internal {
public:
    BasicTest::APIStruct swiftObj;
    APIStruct_Internal(BasicTest::APIStruct wrapped) : swiftObj(wrapped) {}
    ~APIStruct_Internal() {}
};

class UnmanagedSwiftWrapper::APIEnum::APIEnum_Internal {
public:
    BasicTest::APIEnum swiftObj;
    APIEnum_Internal(BasicTest::APIEnum wrapped) : swiftObj(wrapped) {}
    ~APIEnum_Internal() {}
};

class UnmanagedSwiftWrapper::APIClass::APIClass_Internal {
public:
    BasicTest::APIClass swiftObj;
    APIClass_Internal() : swiftObj(BasicTest::APIClass::init()) {}
    APIClass_Internal(BasicTest::APIClass wrapped) : swiftObj(wrapped) {}
    ~APIClass_Internal() {}
};

// UnmanagedSwiftWrapper::APIStruct Implementation

UnmanagedSwiftWrapper::APIStruct::APIStruct(UnmanagedSwiftWrapper::APIEnum enumValue) {
    BasicTest::APIEnum arg0 = enumValue.internal->swiftObj;
    BasicTest::APIStruct value = BasicTest::APIStruct::init(arg0);
    internal = std::make_shared<APIStruct_Internal>(value);
}

UnmanagedSwiftWrapper::APIStruct::APIStruct(std::shared_ptr<APIStruct_Internal> wrapped) {
    internal = wrapped;
}

UnmanagedSwiftWrapper::APIStruct::~APIStruct() {}

UnmanagedSwiftWrapper::APIEnum UnmanagedSwiftWrapper::APIStruct::getEnumValue() {
    BasicTest::APIEnum result = internal->swiftObj.getEnumValue();
    return APIEnum(std::make_shared<APIEnum::APIEnum_Internal>(result));
}

// UnmanagedSwiftWrapper::APIEnum Implementation

bool UnmanagedSwiftWrapper::APIEnum::isCaseOne() {
    return internal->swiftObj.isCaseOne();
}

bool UnmanagedSwiftWrapper::APIEnum::isCaseTwo() {
    return internal->swiftObj.isCaseTwo();
}

int UnmanagedSwiftWrapper::APIEnum::getRawValue() {
    swift::Int val = internal->swiftObj.getRawValue();
    return (int)val;
}

UnmanagedSwiftWrapper::APIEnum::APIEnum(std::shared_ptr<APIEnum_Internal> wrapped) {
    internal = wrapped;
}

UnmanagedSwiftWrapper::APIEnum::~APIEnum() {}

bool UnmanagedSwiftWrapper::APIEnum::operator==(const UnmanagedSwiftWrapper::APIEnum &other) const {
    return (internal->swiftObj == other.internal->swiftObj);
}

UnmanagedSwiftWrapper::APIEnum UnmanagedSwiftWrapper::APIEnum::caseOne() {
    BasicTest::APIEnum val = BasicTest::APIEnum::caseOne();
    return APIEnum(std::make_shared<APIEnum_Internal>(val));
}

UnmanagedSwiftWrapper::APIEnum UnmanagedSwiftWrapper::APIEnum::caseTwo() {
    BasicTest::APIEnum val = BasicTest::APIEnum::caseTwo();
    return APIEnum(std::make_shared<APIEnum_Internal>(val));
}

// UnmanagedSwiftWrapper::APIClass Implementation

UnmanagedSwiftWrapper::APIClass::APIClass() {
    internal = std::make_shared<APIClass_Internal>();
}

UnmanagedSwiftWrapper::APIClass::APIClass(std::shared_ptr<APIClass_Internal> wrapped) {
    internal = wrapped;
}

UnmanagedSwiftWrapper::APIClass::~APIClass() {}

std::string UnmanagedSwiftWrapper::APIClass::getText() {
    swift::String result = internal->swiftObj.getText();
    return (std::string)result;
}

std::string UnmanagedSwiftWrapper::APIClass::sayHello(const std::string & name) {
    swift::String arg0 = (swift::String)name;
    swift::String result = internal->swiftObj.sayHello(arg0);
    return (std::string)result;
}

UnmanagedSwiftWrapper::APIStruct UnmanagedSwiftWrapper::APIClass::doWork(APIStruct structValue) {
    // This seems to consume the original reference and crash us.
    BasicTest::APIStruct arg0 = structValue.internal->swiftObj;
    BasicTest::APIStruct result = internal->swiftObj.doWork(arg0);
    return APIStruct(std::make_shared<APIStruct::APIStruct_Internal>(result));
}


// This is an auto-generated file. Do not modify.

#include "SwiftWrapper.hpp"
#include <BasicTest-Swift.h>

// Implementation of SwiftWrapper::APIStruct

SwiftWrapper::APIStruct::APIStruct(std::shared_ptr<BasicTest::APIStruct> swiftObj) {
    this->swiftObj = swiftObj;
}

SwiftWrapper::APIStruct::APIStruct(const SwiftWrapper::APIEnum & enumValue) {
    const BasicTest::APIEnum & arg0 = *enumValue.swiftObj.get();
    BasicTest::APIStruct instance = BasicTest::APIStruct::init(arg0);
    swiftObj = std::make_shared<BasicTest::APIStruct>(instance);
}

SwiftWrapper::APIStruct::~APIStruct() {}

SwiftWrapper::APIEnum SwiftWrapper::APIStruct::getEnumValue() {
    BasicTest::APIEnum swiftResult = swiftObj->getEnumValue();
    return SwiftWrapper::APIEnum(std::make_shared<BasicTest::APIEnum>(swiftResult));
}

// Implementation of SwiftWrapper::APIClass

SwiftWrapper::APIClass::APIClass(std::shared_ptr<BasicTest::APIClass> swiftObj) {
    this->swiftObj = swiftObj;
}

SwiftWrapper::APIClass::APIClass() {
    BasicTest::APIClass instance = BasicTest::APIClass::init();
    swiftObj = std::make_shared<BasicTest::APIClass>(instance);
}

SwiftWrapper::APIClass::~APIClass() {}

std::string SwiftWrapper::APIClass::getText() {
    swift::String swiftResult = swiftObj->getText();
    return (std::string)swiftResult;
}

std::string SwiftWrapper::APIClass::sayHello(const std::string & name) {
    const swift::String & arg0 = (swift::String)name;
    swift::String swiftResult = swiftObj->sayHello(arg0);
    return (std::string)swiftResult;
}

SwiftWrapper::APIStruct SwiftWrapper::APIClass::doWork(const SwiftWrapper::APIStruct & structValue) {
    const BasicTest::APIStruct & arg0 = *structValue.swiftObj.get();
    BasicTest::APIStruct swiftResult = swiftObj->doWork(arg0);
    return SwiftWrapper::APIStruct(std::make_shared<BasicTest::APIStruct>(swiftResult));
}

// Implementation of SwiftWrapper::APIEnum

SwiftWrapper::APIEnum::APIEnum(std::shared_ptr<BasicTest::APIEnum> swiftObj) {
    this->swiftObj = swiftObj;
}

SwiftWrapper::APIEnum::~APIEnum() {}

SwiftWrapper::APIEnum SwiftWrapper::APIEnum::caseOne() {
    BasicTest::APIEnum value = BasicTest::APIEnum::caseOne();
    return SwiftWrapper::APIEnum(std::make_shared<BasicTest::APIEnum>(value));
}

SwiftWrapper::APIEnum SwiftWrapper::APIEnum::caseTwo() {
    BasicTest::APIEnum value = BasicTest::APIEnum::caseTwo();
    return SwiftWrapper::APIEnum(std::make_shared<BasicTest::APIEnum>(value));
}

bool SwiftWrapper::APIEnum::operator==(const SwiftWrapper::APIEnum &other) const {
    return (*swiftObj.get() == *other.swiftObj.get());
}

bool SwiftWrapper::APIEnum::isCaseOne() {
    bool swiftResult = swiftObj->isCaseOne();
    return swiftResult;
}

bool SwiftWrapper::APIEnum::isCaseTwo() {
    bool swiftResult = swiftObj->isCaseTwo();
    return swiftResult;
}

int SwiftWrapper::APIEnum::getRawValue() {
    swift::Int swiftResult = swiftObj->getRawValue();
    return (int)swiftResult;
}

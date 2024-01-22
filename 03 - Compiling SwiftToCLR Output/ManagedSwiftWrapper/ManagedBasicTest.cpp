// This is an auto-generated file. Do not modify.

#include "ManagedBasicTest.hpp"
#include <msclr/marshal_cppstd.h>

using namespace msclr::interop;

// Implementation of ManagedBasicTest::APIStruct

ManagedBasicTest::APIStruct::APIStruct(std::shared_ptr<UnmanagedBasicTest::APIStruct>* wrapped) {
    wrappedObj = wrapped;
}

ManagedBasicTest::APIStruct::APIStruct(ManagedBasicTest::APIEnum^ enumValue) {
    UnmanagedBasicTest::APIEnum arg0 = *enumValue->wrappedObj->get();
    UnmanagedBasicTest::APIStruct* newObject = new UnmanagedBasicTest::APIStruct(arg0);
    wrappedObj = new std::shared_ptr<UnmanagedBasicTest::APIStruct>(newObject);
}

ManagedBasicTest::APIStruct::~APIStruct() {
    delete wrappedObj;
}

ManagedBasicTest::APIEnum^ ManagedBasicTest::APIStruct::getEnumValue() {
    UnmanagedBasicTest::APIEnum unmanagedResult = wrappedObj->get()->getEnumValue();
    return gcnew ManagedBasicTest::APIEnum(new std::shared_ptr<UnmanagedBasicTest::APIEnum>(new UnmanagedBasicTest::APIEnum(unmanagedResult)));
}

// Implementation of ManagedBasicTest::APIClass

ManagedBasicTest::APIClass::APIClass(std::shared_ptr<UnmanagedBasicTest::APIClass>* wrapped) {
    wrappedObj = wrapped;
}

ManagedBasicTest::APIClass::APIClass() {
    UnmanagedBasicTest::APIClass* newObject = new UnmanagedBasicTest::APIClass();
    wrappedObj = new std::shared_ptr<UnmanagedBasicTest::APIClass>(newObject);
}

ManagedBasicTest::APIClass::~APIClass() {
    delete wrappedObj;
}

System::String^ ManagedBasicTest::APIClass::getText() {
    std::string unmanagedResult = wrappedObj->get()->getText();
    return marshal_as<System::String^>(unmanagedResult);
}

System::String^ ManagedBasicTest::APIClass::sayHello(System::String^ name) {
    const std::string& arg0 = marshal_as<std::string>(name);
    std::string unmanagedResult = wrappedObj->get()->sayHello(arg0);
    return marshal_as<System::String^>(unmanagedResult);
}

ManagedBasicTest::APIStruct^ ManagedBasicTest::APIClass::doWork(ManagedBasicTest::APIStruct^ structValue) {
    UnmanagedBasicTest::APIStruct arg0 = *structValue->wrappedObj->get();
    UnmanagedBasicTest::APIStruct unmanagedResult = wrappedObj->get()->doWork(arg0);
    return gcnew ManagedBasicTest::APIStruct(new std::shared_ptr<UnmanagedBasicTest::APIStruct>(new UnmanagedBasicTest::APIStruct(unmanagedResult)));
}

// Implementation of ManagedBasicTest::APIEnum

ManagedBasicTest::APIEnum::APIEnum(std::shared_ptr<UnmanagedBasicTest::APIEnum>* wrapped) {
    wrappedObj = wrapped;
}

ManagedBasicTest::APIEnum::~APIEnum() {
    delete wrappedObj;
}

ManagedBasicTest::APIEnum^ ManagedBasicTest::APIEnum::caseOne() {
    UnmanagedBasicTest::APIEnum unmanagedResult = UnmanagedBasicTest::APIEnum::caseOne();
    return gcnew ManagedBasicTest::APIEnum(new std::shared_ptr<UnmanagedBasicTest::APIEnum>(new UnmanagedBasicTest::APIEnum(unmanagedResult)));
}

ManagedBasicTest::APIEnum^ ManagedBasicTest::APIEnum::caseTwo() {
    UnmanagedBasicTest::APIEnum unmanagedResult = UnmanagedBasicTest::APIEnum::caseTwo();
    return gcnew ManagedBasicTest::APIEnum(new std::shared_ptr<UnmanagedBasicTest::APIEnum>(new UnmanagedBasicTest::APIEnum(unmanagedResult)));
}

bool ManagedBasicTest::APIEnum::operator==(ManagedBasicTest::APIEnum^ lhs, ManagedBasicTest::APIEnum^ rhs) {
    return (*lhs->wrappedObj->get() == *rhs->wrappedObj->get());
}

bool ManagedBasicTest::APIEnum::isCaseOne() {
    bool unmanagedResult = wrappedObj->get()->isCaseOne();
    return unmanagedResult;
}

bool ManagedBasicTest::APIEnum::isCaseTwo() {
    bool unmanagedResult = wrappedObj->get()->isCaseTwo();
    return unmanagedResult;
}

int ManagedBasicTest::APIEnum::getRawValue() {
    int unmanagedResult = wrappedObj->get()->getRawValue();
    return unmanagedResult;
}

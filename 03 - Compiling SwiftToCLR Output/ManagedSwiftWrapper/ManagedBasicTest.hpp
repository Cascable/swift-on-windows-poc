// This is an auto-generated file. Do not modify.

#pragma once
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <UnmanagedBasicTest.hpp>

namespace ManagedBasicTest {

    ref class APIStruct;
    ref class APIClass;
    ref class APIEnum;

    public ref class APIStruct {
    private:
    internal:
        std::shared_ptr<UnmanagedBasicTest::APIStruct>* wrappedObj;
        APIStruct(std::shared_ptr<UnmanagedBasicTest::APIStruct>* wrapped);
    public:
        APIStruct(ManagedBasicTest::APIEnum^ enumValue);
        ~APIStruct();
    
        ManagedBasicTest::APIEnum^ getEnumValue();
    };

    public ref class APIClass {
    private:
    internal:
        std::shared_ptr<UnmanagedBasicTest::APIClass>* wrappedObj;
        APIClass(std::shared_ptr<UnmanagedBasicTest::APIClass>* wrapped);
    public:
        APIClass();
        ~APIClass();
    
        System::String^ getText();
        System::String^ sayHello(System::String^ name);
        ManagedBasicTest::APIStruct^ doWork(ManagedBasicTest::APIStruct^ structValue);
    };

    public ref class APIEnum {
    private:
    internal:
        std::shared_ptr<UnmanagedBasicTest::APIEnum>* wrappedObj;
        APIEnum(std::shared_ptr<UnmanagedBasicTest::APIEnum> *wrapped);
    public:
        ~APIEnum();
    
        static ManagedBasicTest::APIEnum^ caseOne();
        static ManagedBasicTest::APIEnum^ caseTwo();

        static bool operator==(ManagedBasicTest::APIEnum^ lhs, ManagedBasicTest::APIEnum^ rhs);
        bool isCaseOne();
        bool isCaseTwo();
        int getRawValue();
    };
}

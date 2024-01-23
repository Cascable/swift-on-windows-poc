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
        UnmanagedBasicTest::APIStruct* wrappedObj;
        APIStruct(UnmanagedBasicTest::APIStruct* objectToTakeOwnershipOf);
    public:
        APIStruct(ManagedBasicTest::APIEnum^ enumValue);
        ~APIStruct();

        ManagedBasicTest::APIEnum^ getEnumValue();
    };

    public ref class APIClass {
    private:
    internal:
        UnmanagedBasicTest::APIClass* wrappedObj;
        APIClass(UnmanagedBasicTest::APIClass* objectToTakeOwnershipOf);
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
        UnmanagedBasicTest::APIEnum* wrappedObj;
        APIEnum(UnmanagedBasicTest::APIEnum* objectToTakeOwnershipOf);
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

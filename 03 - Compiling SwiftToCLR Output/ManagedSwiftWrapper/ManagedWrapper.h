// This is an auto-generated file. Do not modify.
#pragma once
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <UnmanagedSwiftWrapper.h>

namespace ManagedWrapper {

    ref class UnmanagedAPI;
    ref class CustomDataObject;

    public ref class UnmanagedAPI {
    private:
    public:
        UnmanagedSwiftWrapper::UnmanagedAPI* wrappedObj;
        UnmanagedAPI() : wrappedObj(new UnmanagedSwiftWrapper::UnmanagedAPI()) {}
        UnmanagedAPI(UnmanagedSwiftWrapper::UnmanagedAPI* wrapped) : wrappedObj(wrapped) {}
        ~UnmanagedAPI() { delete wrappedObj; }

        System::String^ Greet(System::String^ name);
        void SayHello(System::String^ name);
        void PerformMagic();
        ManagedWrapper::CustomDataObject^ ProcessDataObject(ManagedWrapper::CustomDataObject^ object);
    };

    public ref class CustomDataObject {
    private:
    public:
        UnmanagedSwiftWrapper::CustomDataObject* wrappedObj;
        CustomDataObject() : wrappedObj(new UnmanagedSwiftWrapper::CustomDataObject()) {}
        CustomDataObject(UnmanagedSwiftWrapper::CustomDataObject* wrapped) : wrappedObj(wrapped) {}
        ~CustomDataObject() { delete wrappedObj; }

        System::String^ MyCoolProperty();
    };
}

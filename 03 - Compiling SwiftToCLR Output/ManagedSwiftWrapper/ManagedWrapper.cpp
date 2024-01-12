// This is an auto-generated file. Do not modify.

#include "ManagedWrapper.h"
#include <msclr/marshal_cppstd.h>

using namespace msclr::interop;

// Implementation of ManagedWrapper::UnmanagedAPI

System::String^ ManagedWrapper::UnmanagedAPI::Greet(System::String^ name) {
    const std::string& arg0 = marshal_as<std::string>(name);
    std::string unmanagedResult = wrappedObj->Greet(arg0);
    return marshal_as<System::String^>(unmanagedResult);
}

void ManagedWrapper::UnmanagedAPI::SayHello(System::String^ name) {
    const std::string& arg0 = marshal_as<std::string>(name);
    wrappedObj->SayHello(arg0);
}

void ManagedWrapper::UnmanagedAPI::PerformMagic() {
    wrappedObj->PerformMagic();
}

ManagedWrapper::CustomDataObject^ ManagedWrapper::UnmanagedAPI::ProcessDataObject(ManagedWrapper::CustomDataObject^ object) {
    UnmanagedSwiftWrapper::CustomDataObject* arg0 = object->wrappedObj;
    UnmanagedSwiftWrapper::CustomDataObject* unmanagedResult = wrappedObj->ProcessDataObject(arg0);
    return gcnew ManagedWrapper::CustomDataObject(unmanagedResult);
}

// Implementation of ManagedWrapper::CustomDataObject

System::String^ ManagedWrapper::CustomDataObject::MyCoolProperty() {
    std::string unmanagedResult = wrappedObj->MyCoolProperty();
    return marshal_as<System::String^>(unmanagedResult);
}

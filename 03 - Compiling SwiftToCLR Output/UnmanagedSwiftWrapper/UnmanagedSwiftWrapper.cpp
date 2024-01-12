#include "pch.h"
#include "UnmanagedSwiftWrapper.h"

// Eventually we'll wrap the Module-Swift.h file that Swift outputs. For now, this is a dummy implementation
// so we can test the Unmanaged->Managed wrapper first.

class UnmanagedAPIInternal {
public:
	UnmanagedAPIInternal();
	~UnmanagedAPIInternal();
};

UnmanagedAPIInternal::UnmanagedAPIInternal() {}
UnmanagedAPIInternal::~UnmanagedAPIInternal() {}

void UnmanagedSwiftWrapper::UnmanagedAPI::SuperSecrets(void)
{
}

UnmanagedSwiftWrapper::UnmanagedAPI::UnmanagedAPI()
{
	internalData = new UnmanagedAPIInternal();
}

UnmanagedSwiftWrapper::UnmanagedAPI::~UnmanagedAPI()
{
	delete internalData;
}

std::string UnmanagedSwiftWrapper::UnmanagedAPI::Greet(const std::string& name)
{
	return "Hello " + name + "!";
}

void UnmanagedSwiftWrapper::UnmanagedAPI::SayHello(const std::string& name)
{
}

void UnmanagedSwiftWrapper::UnmanagedAPI::PerformMagic(void)
{
}

UnmanagedSwiftWrapper::CustomDataObject *UnmanagedSwiftWrapper::UnmanagedAPI::ProcessDataObject(UnmanagedSwiftWrapper::CustomDataObject *object)
{
	return object;
}

UnmanagedSwiftWrapper::CustomDataObject::CustomDataObject()
{
}

UnmanagedSwiftWrapper::CustomDataObject::~CustomDataObject()
{
}

std::string UnmanagedSwiftWrapper::CustomDataObject::MyCoolProperty(void)
{
	return "Cool Data";
}

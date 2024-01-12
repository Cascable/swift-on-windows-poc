#if defined(_WIN32) || defined(WIN32)
#define WIN32_LEAN_AND_MEAN             // Exclude rarely-used stuff from Windows headers
#include <windows.h>
#endif

#include <stdlib.h>
#include <string>

class UnmanagedAPIInternal;
class CustomDataObject;

namespace UnmanagedSwiftWrapper {

    class UnmanagedAPI {
    private:
        UnmanagedAPIInternal* internalData;
        void SuperSecrets(void);
    public:
        UnmanagedAPI();
        ~UnmanagedAPI();

        std::string Greet(const std::string& name);
        
        void SayHello(const std::string& name);
        
        void PerformMagic(void);

        CustomDataObject *ProcessDataObject(CustomDataObject *object);
    };

    class CustomDataObject {
    public:
        CustomDataObject();
        ~CustomDataObject();

        std::string MyCoolProperty(void);
    };
}


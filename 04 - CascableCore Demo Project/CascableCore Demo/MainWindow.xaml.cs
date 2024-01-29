using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Controls.Primitives;
using Microsoft.UI.Xaml.Data;
using Microsoft.UI.Xaml.Input;
using Microsoft.UI.Xaml.Media;
using Microsoft.UI.Xaml.Navigation;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices.WindowsRuntime;
using Windows.Foundation;
using Windows.Foundation.Collections;

using ManagedCascableCoreBasicAPI;
using System.Diagnostics;

// To learn more about WinUI, the WinUI project structure,
// and more about our project templates, see: http://aka.ms/winui-project-info.

namespace CascableCore_Demo
{
    /// <summary>
    /// An empty window that can be used on its own or navigated to within a Frame.
    /// </summary>
    public sealed partial class MainWindow : Window
    {
        public MainWindow()
        {
            this.InitializeComponent();
            this.AppWindow.Resize(new Windows.Graphics.SizeInt32(800, 600));
        }

        BasicCameraDiscovery discovery = BasicCameraDiscovery.sharedInstance();
     
        private void myButton_Click(object sender, RoutedEventArgs e)
        {
            if (discovery.getDiscoveryRunning())
            {
                ICollection<BasicCamera> cameras = discovery.getVisibleCameras();
                if (cameras.Count > 0)
                {
                    BasicCamera camera = cameras.First();
                    Debug.WriteLine("Got camera: " + camera.getFriendlyDisplayName());
                    Debug.WriteLine("Got camera: " + camera.getFriendlyDisplayName());
                    Debug.WriteLine("Got camera: " + camera.getFriendlyDisplayName());
                    Debug.WriteLine("Got camera: " + camera.getFriendlyDisplayName());
                    Debug.WriteLine(camera.getDeviceInfo().getManufacturer());

                    BasicPropertyIdentifier id = BasicPropertyIdentifier.initWithRawValue(4);
                    BasicPropertyIdentifier bad = BasicPropertyIdentifier.initWithRawValue(6000);
                    Debug.WriteLine(id.getRawValue());

                    //camera.connect();

                    dynamic something = camera.getKnownPropertyIdentifiers();
                    BasicCameraProperty property = camera.property(BasicPropertyIdentifier.autoExposureMode());
                    Debug.WriteLine("Property name: " + property.getLocalizedDisplayName());
                } else
                {
                    Debug.WriteLine("No cameras");
                }
            } else
            {
                BasicSimulatedCameraConfiguration config = BasicSimulatedCameraConfiguration.defaultConfiguration();
                config.setModel("My Cool Camera");
                myButton.Content = string.Format("{0} {1}", config.getManufacturer(), config.getModel());
                config.apply();
                discovery.startDiscovery("CascableCore Demo");
                Debug.WriteLine("Starting discovery");
            }
        }
    }
}

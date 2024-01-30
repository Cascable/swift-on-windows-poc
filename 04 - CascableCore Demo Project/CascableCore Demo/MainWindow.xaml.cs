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

        private async void myButton_Click(object sender, RoutedEventArgs e)
        {
            BasicSimulatedCameraConfiguration config = BasicSimulatedCameraConfiguration.defaultConfiguration();
            config.setModel("My Cool Camera");
            myButton.Content = string.Format("{0} {1}", config.getManufacturer(), config.getModel());
            config.apply();
            discovery.startDiscovery("CascableCore Demo");
            Debug.WriteLine("Starting discovery");

            BasicCamera camera = await PollingUpdater<BasicCameraDiscovery, BasicCamera>.AwaitForNonNil(discovery, TimeSpan.FromSeconds(0.1), TimeSpan.FromSeconds(4.0), delegate (BasicCameraDiscovery d)
            {
                ICollection<BasicCamera> cameras = d.getVisibleCameras();
                return (cameras.Count == 0 ? null : cameras.First());
            });

            Debug.WriteLine("Got camera: " + camera.getFriendlyDisplayName());
            discovery.stopDiscovery();

            dynamic something = camera.getKnownPropertyIdentifiers();
            BasicCameraProperty property = camera.property(BasicPropertyIdentifier.autoExposureMode());
            Debug.WriteLine("Property name: " + property.getLocalizedDisplayName());

            camera.connect();
            await PollingUpdater<BasicCamera, bool>.AwaitForTrue(camera, TimeSpan.FromSeconds(0.05), TimeSpan.FromSeconds(4.0), delegate (BasicCamera c)
            {
                return c.getConnected();
            });

            Debug.WriteLine("Camera is connected: " + camera.getFriendlyDisplayName());
            BasicCameraProperty batteryLevel = camera.property(BasicPropertyIdentifier.batteryLevel());
            Debug.WriteLine("Battery level: " + batteryLevel.getCurrentValue().getLocalizedDisplayValue());

            BasicCameraProperty exposureMode = camera.property(BasicPropertyIdentifier.autoExposureMode());
            Debug.WriteLine("Exposure mode: " + exposureMode.getCurrentValue().getLocalizedDisplayValue());

            BasicPropertyValue value = exposureMode.getValidSettableValues().First(v => v.getLocalizedDisplayValue() == "M");
            if (value != null)
            {
                exposureMode.setValue(value);
            }

            await PollingUpdater<BasicCameraProperty, bool>.AwaitForTrue(exposureMode, TimeSpan.FromSeconds(0.05), TimeSpan.FromSeconds(4.0), delegate (BasicCameraProperty p)
            {
                return p.getCurrentValue()?.getLocalizedDisplayValue() == "M";
            });

            Debug.WriteLine("Exposure mode: " + exposureMode.getCurrentValue().getLocalizedDisplayValue());

            BasicCameraProperty shutterSpeed = camera.property(BasicPropertyIdentifier.shutterSpeed());
            Debug.WriteLine("Shutter speed: " + shutterSpeed.getCurrentValue().getLocalizedDisplayValue());

        }
    }
}

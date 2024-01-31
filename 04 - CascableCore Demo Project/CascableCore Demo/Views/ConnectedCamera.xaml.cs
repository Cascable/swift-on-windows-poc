using CommunityToolkit.Mvvm.ComponentModel;
using ManagedCascableCoreBasicAPI;
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

// To learn more about WinUI, the WinUI project structure,
// and more about our project templates, see: http://aka.ms/winui-project-info.

namespace CascableCoreDemo.Views
{
    /// <summary>
    /// An empty page that can be used on its own or navigated to within a Frame.
    /// </summary>
    public sealed partial class ConnectedCamera : Page
    {
        public ConnectedCamera(BasicCamera camera)
        {
            this.InitializeComponent();
            this.camera = camera;
            string manufacturer = camera.getDeviceInfo()?.getManufacturer();
            string model = camera.getDeviceInfo()?.getModel();
            if (manufacturer != null && model != null)
            {
                viewModel.FullCameraName = manufacturer + " " + model;
            } else
            {
                viewModel.FullCameraName = camera.getFriendlyDisplayName() ?? "Unknown Camera";
            }

            BasicPropertyIdentifier[] properties = [
                BasicPropertyIdentifier.autoExposureMode(),
                BasicPropertyIdentifier.aperture(),
                BasicPropertyIdentifier.shutterSpeed(),
                BasicPropertyIdentifier.isoSpeed(),
                BasicPropertyIdentifier.exposureCompensation()
            ];

            foreach(BasicPropertyIdentifier property in properties) {
               propertyPanel.Children.Add(new PropertyView(camera.property(property)));
            }
        }

        partial class ConnectedCameraViewModel : ObservableObject
        {
            [ObservableProperty]
            private string fullCameraName = "";

            [ObservableProperty]
            private bool disconnectButtonEnabled = true;
        }

        BasicCamera camera;
        ConnectedCameraViewModel viewModel = new ConnectedCameraViewModel();

        public event EventHandler<BasicCamera> DisconnectedFromCamera;

        private async void disconnectButton_Click(object sender, RoutedEventArgs e)
        {
            viewModel.DisconnectButtonEnabled = false;
            camera.disconnect();

            try
            {
                await PollingAwaiter<BasicCamera, bool>.AwaitForTrue(camera, TimeSpan.FromSeconds(0.1), TimeSpan.FromSeconds(4.0), delegate (BasicCamera c)
                {
                    return !c.getConnected();
                });
            }
            catch
            {
                // If we fail to disconnect, that's weird but not the end of the world.
            }

            EventHandler<BasicCamera> disconnectedEvent = DisconnectedFromCamera;
            if (disconnectedEvent != null) { disconnectedEvent(this, camera); }
        }
    }
}

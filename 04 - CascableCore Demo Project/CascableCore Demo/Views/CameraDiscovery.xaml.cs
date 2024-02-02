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
using System.Diagnostics;
using Windows.UI.Popups;

namespace CascableCoreDemo.Views
{
    public sealed partial class CameraDiscovery : Page
    {
        public CameraDiscovery()
        {
            this.InitializeComponent();
        }

        partial class CameraConnectionViewModel : ObservableObject
        {
            [ObservableProperty]
            private bool buttonEnabled = true;

            [ObservableProperty]
            private Visibility spinnerVisibility = Visibility.Collapsed;

            [ObservableProperty]
            private string buttonTitle = "Search for Camera...";
        }

        BasicCameraDiscovery discovery = BasicCameraDiscovery.sharedInstance();
        CameraConnectionViewModel viewModel = new CameraConnectionViewModel();

        public event EventHandler<BasicCamera> ConnectedToCamera;

        private void resetState()
        {
            discovery.stopDiscovery();
            viewModel.ButtonEnabled = true;
            viewModel.ButtonTitle = "Search for Camera...";
            viewModel.SpinnerVisibility = Visibility.Collapsed;
        }

        #region Button Handlers

        private async void searchButton_Click(object sender, RoutedEventArgs e)
        {
            if (discovery.getDiscoveryRunning())
            {
                resetState();
                return;
            }

            // Let's simulate a real camera model name.
            BasicSimulatedCameraConfiguration config = BasicSimulatedCameraConfiguration.defaultConfiguration();
            config.setManufacturer("Canon");
            config.setModel("EOS R5");
            config.apply();
            discovery.startDiscovery("CascableCore Demo");

            viewModel.ButtonTitle = "Stop Searching";
            viewModel.SpinnerVisibility = Visibility.Visible;

            BasicCamera camera = null;
            try
            {
                camera = await PollingAwaiter<BasicCameraDiscovery, BasicCamera>.AwaitForNonNil(discovery, TimeSpan.FromSeconds(1.0), TimeSpan.FromSeconds(4.0), delegate (BasicCameraDiscovery d)
                {
                    ICollection<BasicCamera> cameras = d.getVisibleCameras();
                    return (cameras.Count == 0 ? null : cameras.First());
                });
            }
            catch
            {
                resetState();
                if (!discovery.getDiscoveryRunning()) { return; } // Maybe the user cancelled.

                ContentDialog dialog = new ContentDialog
                {
                    Title = "No Cameras Found",
                    Content = "No cameras were discovered. This is particularly weird since we're using a simulated camera.",
                    CloseButtonText = "OK"
                };
                dialog.XamlRoot = Content.XamlRoot;
                await dialog.ShowAsync();
                return;
            }

            string cameraName = camera.getFriendlyDisplayName() ?? "Unknown Camera";

            discovery.stopDiscovery();
            viewModel.ButtonEnabled = false;
            viewModel.ButtonTitle = "Connecting to " + cameraName + "...";

            camera.connect();
            try
            {
                await PollingAwaiter<BasicCamera, bool>.AwaitForTrue(camera, TimeSpan.FromSeconds(1.0), TimeSpan.FromSeconds(4.0), delegate (BasicCamera c)
                {
                    return c.getConnected();
                });
            }
            catch
            {
                resetState();
                ContentDialog dialog = new ContentDialog
                {
                    Title = "Failed to Connect To " + cameraName,
                    Content = "This is particularly weird since we're using a simulated camera.",
                    CloseButtonText = "OK"
                };
                dialog.XamlRoot = Content.XamlRoot;
                await dialog.ShowAsync();
                return;
            }

            // We have a connected camera now. We should hand this off to some new UI, then reset our state for next time.
            EventHandler<BasicCamera> connectedEvent = ConnectedToCamera;
            if (connectedEvent != null) { connectedEvent(this, camera); }
            resetState();
        }

        #endregion
    }
}

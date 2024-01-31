using CommunityToolkit.Mvvm.ComponentModel;
using ManagedCascableCoreBasicAPI;
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Controls.Primitives;
using Microsoft.UI.Xaml.Data;
using Microsoft.UI.Xaml.Input;
using Microsoft.UI.Xaml.Media;
using Microsoft.UI.Xaml.Media.Imaging;
using Microsoft.UI.Xaml.Navigation;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Runtime.InteropServices.WindowsRuntime;
using System.Threading.Channels;
using Windows.Foundation;
using Windows.Foundation.Collections;
using Microsoft.UI.Dispatching;

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
            mainQueue = DispatcherQueue.GetForCurrentThread();
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

            frameObserver = new PollingObserver<BasicCamera, BasicLiveViewFrame, double>(camera, TimeSpan.FromSeconds(0.1),
                delegate (BasicCamera c) { return c.getLastLiveViewFrame(); }, 
                delegate (BasicLiveViewFrame f) { return f?.getDateProduced(); });
            frameObserver.ValueChanged += FrameObserver_ValueChanged;
            camera.beginLiveViewStream();
            frameObserver.Start();
        }

        private void FrameObserver_ValueChanged(object sender, BasicLiveViewFrame e)
        {
            if (e == null) { return; }
            Debug.WriteLine("Got live view frame of size: " + e.getRawPixelSize().getWidth() + "x" + e.getRawPixelSize().getHeight());
            mainQueue.TryEnqueue(() => { handleLiveViewFrame(e); });
           
        }

        private void handleLiveViewFrame(BasicLiveViewFrame e)
        {
            byte[] data = extractFrame(e);
            BitmapImage image = new BitmapImage();
            image.SetSource(data.AsBuffer().AsStream().AsRandomAccessStream());
            ImageView.Source = image;
        }

        private unsafe byte[] extractFrame(BasicLiveViewFrame frame)
        {
            int byteCount = frame.getRawPixelDataLength();
            byte[] destination = new byte[byteCount];
            IntPtr buffer = Marshal.AllocHGlobal(byteCount);
            frame.copyPixelData((byte *)buffer.ToPointer());
            Marshal.Copy(buffer, destination, 0, byteCount);
            Marshal.FreeHGlobal(buffer);
            return destination;
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
        PollingObserver<BasicCamera, BasicLiveViewFrame, double> frameObserver;
        private DispatcherQueue mainQueue;

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

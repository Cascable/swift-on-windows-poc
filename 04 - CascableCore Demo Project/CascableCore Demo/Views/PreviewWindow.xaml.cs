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
using Microsoft.UI.Xaml.Media.Imaging;
using System.Runtime.InteropServices;

// To learn more about WinUI, the WinUI project structure,
// and more about our project templates, see: http://aka.ms/winui-project-info.

namespace CascableCoreDemo.Views
{
    /// <summary>
    /// An empty window that can be used on its own or navigated to within a Frame.
    /// </summary>
    public sealed partial class PreviewWindow : Window
    {
        public PreviewWindow(BasicCameraInitiatedTransferResult result)
        {
            this.InitializeComponent();
            Title = "Photo Preview";
            preview = result;
            byte[] data = extractImage(result);
            BitmapImage image = new BitmapImage();
            image.SetSource(data.AsBuffer().AsStream().AsRandomAccessStream());
            ImageView.Source = image;
        }

        private BasicCameraInitiatedTransferResult preview;

        private unsafe byte[] extractImage(BasicCameraInitiatedTransferResult result)
        {
            int byteCount = result.getRawImageDataLength();
            byte[] destination = new byte[byteCount];
            IntPtr buffer = Marshal.AllocHGlobal(byteCount);
            result.copyPixelData((byte*)buffer.ToPointer());
            Marshal.Copy(buffer, destination, 0, byteCount);
            Marshal.FreeHGlobal(buffer);
            return destination;
        }
    }
}

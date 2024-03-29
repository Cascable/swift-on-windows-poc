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
using CascableCoreDemo.Views;
using ManagedCascableCoreBasicAPI;
using System.Diagnostics;
using Windows.ApplicationModel;

namespace CascableCoreDemo
{
    public sealed partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
            Title = "CascableCore Demo";
            Content = discoveryView;
            discoveryView.Loaded += uiLoaded;
            discoveryView.ConnectedToCamera += connectedToCamera;
            string icon = Path.Combine(
                Path.GetDirectoryName(new Uri(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).LocalPath),
                "Assets", "CoreIcon.ico"
            );
            this.AppWindow.SetIcon(icon);
        }

        // We'll just use the one of these throughout the lifecycle.
        CameraDiscovery discoveryView = new CameraDiscovery();
        private bool hasResizedWindow = false;

        private void uiLoaded(Object o, RoutedEventArgs e)
        {
            if (hasResizedWindow) { return; }
            // Scale isn't available until we're loaded and about to be onscreen.
            double scale = Content.XamlRoot.RasterizationScale;
            // This takes actual pixels rather than scaled pixels, hence the need for scale.
            AppWindow.Resize(new Windows.Graphics.SizeInt32((Int32)(800.0 * scale), (Int32)(700.0 * scale)));
            hasResizedWindow = true;
        }

        private void connectedToCamera(Object e, BasicCamera camera)
        {
            ConnectedCamera view = new ConnectedCamera(camera);
            view.DisconnectedFromCamera += disconnectedFromCamera;
            Content = view;
        }

        private void disconnectedFromCamera(Object e, BasicCamera camera)
        {
            Content = discoveryView;
        }
    }
}

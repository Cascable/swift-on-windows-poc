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
using CommunityToolkit.Mvvm.ComponentModel;
using Microsoft.UI;
using Microsoft.UI.Dispatching;

namespace CascableCoreDemo.Views
{
    public sealed partial class PropertyView : StackPanel
    {
        partial class PropertyViewModel : ObservableObject
        {
            [ObservableProperty]
            private string propertyName = "";

            [ObservableProperty]
            private string propertyValue = "";

            [ObservableProperty]
            private SolidColorBrush propertyValueColor = new SolidColorBrush(Colors.Black);

            [ObservableProperty]
            private bool showValueMenu = false;
        }

        public PropertyView(BasicCameraProperty property)
        {
            this.InitializeComponent();
            this.property = property;
            this.Tapped += PropertyView_Tapped;

            mainQueue = DispatcherQueue.GetForCurrentThread();
            viewModel.PropertyName = property.getLocalizedDisplayName() ?? "Unknown";

            valueObserver = PollingObserver<BasicCameraProperty, BasicCameraProperty, string>
                .observing<BasicCameraProperty, string>(property, TimeSpan.FromSeconds(0.25), delegate (BasicCameraProperty p)
            {
                return p.getCurrentValue()?.getLocalizedDisplayValue();
            });

            settableValuesObserver = PollingObserver<BasicCameraProperty, BasicCameraProperty, int>
                .observing<BasicCameraProperty, int>(property, TimeSpan.FromSeconds(0.25), delegate (BasicCameraProperty p)
            {
                return p.getValidSettableValues()?.Count ?? 0;
            });

            valueObserver.ValueChanged += CurrentValueChanged;
            settableValuesObserver.ValueChanged += SettableValuesChanged;

            valueObserver.Start();
            settableValuesObserver.Start();

            updateCurrentValue();
        }

        private void CurrentValueChanged(object sender, BasicCameraProperty e)
        {
            mainQueue.TryEnqueue(() => { updateCurrentValue(); });
        }

        private void SettableValuesChanged(object sender, BasicCameraProperty e)
        {
            mainQueue.TryEnqueue(() => { updatePropertyMenu(); });
        }

        private void PropertyView_Tapped(object sender, TappedRoutedEventArgs e)
        {
            MenuContainer.ContextFlyout.ShowAt(this);
        }

        private BasicCameraProperty property;
        PropertyViewModel viewModel = new PropertyViewModel();
        private PollingObserver<BasicCameraProperty, BasicCameraProperty, string> valueObserver;
        private PollingObserver<BasicCameraProperty, BasicCameraProperty, int> settableValuesObserver;
        private DispatcherQueue mainQueue;

        private void updateCurrentValue()
        {
            viewModel.PropertyValue = property.getCurrentValue()?.getLocalizedDisplayValue() ?? "—";
            viewModel.PropertyValueColor = (property.getCurrentValue() == null ? new SolidColorBrush(Colors.LightGray) : new SolidColorBrush(Colors.Black));
            updatePropertyMenu();
        }

        private void updatePropertyMenu()
        {
            viewModel.ShowValueMenu = (property.getValidSettableValues().Count > 0);
            List<BasicPropertyValue> propertyValues = property.getValidSettableValues();
            string currentValue = viewModel.PropertyValue;

            ValueMenu.Items.Clear();
            if (viewModel.ShowValueMenu)
            {
                foreach (BasicPropertyValue value in propertyValues)
                {
                    ToggleMenuFlyoutItem item = new ToggleMenuFlyoutItem();
                    item.Text = value.getLocalizedDisplayValue() ?? value.getStringValue();
                    item.Tag = value;
                    item.IsChecked = (value.getLocalizedDisplayValue() == currentValue);
                    item.Click += SettableMenuItem_Click;
                    ValueMenu.Items.Add(item);
                }
            }
            else
            {
                MenuFlyoutItem item = new MenuFlyoutItem();
                item.Text = "No values.";
                item.IsEnabled = false;
                ValueMenu.Items.Add(item);
            }
        }

        private void SettableMenuItem_Click(object sender, RoutedEventArgs e)
        {
            ToggleMenuFlyoutItem item = (ToggleMenuFlyoutItem)sender;
            BasicPropertyValue value = (BasicPropertyValue)item.Tag;
            property.setValue(value);
            updatePropertyMenu();
        }
    }
}

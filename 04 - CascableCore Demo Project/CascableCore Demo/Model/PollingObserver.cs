using CommunityToolkit.Mvvm.Messaging.Messages;
using ManagedCascableCoreBasicAPI;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Timers;

namespace CascableCoreDemo
{
    internal class PollingObserver<T, Result>
    {
        private Func<T, IEquatable<Result>> func;
        private T inValue;
        private Timer timer;
        private IEquatable<Result> previousValue;

        public PollingObserver(T inValue, TimeSpan pollInterval, Func<T, IEquatable<Result>> func)
        {
            this.func = func;
            this.inValue = inValue;
            previousValue = func(inValue);
            timer = new Timer(pollInterval.TotalMilliseconds);
            timer.AutoReset = true;
            timer.Elapsed += OnTimerEvent;
        }

        internal event EventHandler<T> ValueChanged;

        internal void Start()
        {
            timer.Start();
        }

        internal void Stop()
        {
            timer.Stop();
        }

        private void OnTimerEvent(Object timer, ElapsedEventArgs e)
        {
            IEquatable<Result> result = func(inValue);
            if (previousValue == null && result == null) { return; }
            if (previousValue == null || result == null || !result.Equals(previousValue))
            {
                previousValue = result;
                EventHandler<T> valueChanged = ValueChanged;
                if (valueChanged != null) { valueChanged(this, inValue); }
            }
        }
    }
}

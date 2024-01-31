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
    internal class PollingObserver<InT, OutT, ComparatorT> where ComparatorT: IComparable<ComparatorT>
    {
        private Func<OutT, IEquatable<ComparatorT>> func;
        private Func<InT, OutT> adapter;
        private InT inValue;
        private Timer timer;
        private IEquatable<ComparatorT> previousValue;

        internal static PollingObserver<In, In, ComparatorT> observing<In, Comparator>(In inValue, TimeSpan pollInterval, Func<In, IEquatable<ComparatorT>> func)
        {
            return new PollingObserver<In, In, ComparatorT>(inValue, pollInterval, delegate (In i) { return i; }, func);
        }

        public PollingObserver(InT inValue, TimeSpan pollInterval, Func<InT, OutT> adapter, Func<OutT, IEquatable<ComparatorT>> func)
        {
            this.func = func;
            this.adapter = adapter;
            this.inValue = inValue;
            previousValue = func(adapter(inValue));
            timer = new Timer(pollInterval.TotalMilliseconds);
            timer.AutoReset = true;
            timer.Elapsed += OnTimerEvent;
        }

        internal event EventHandler<OutT> ValueChanged;

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
            OutT newValue = adapter(inValue);
            IEquatable<ComparatorT> result = func(newValue);
            if (previousValue == null && result == null) { return; }
            if (previousValue == null || result == null || !result.Equals(previousValue))
            {
                previousValue = result;
                EventHandler<OutT> valueChanged = ValueChanged;
                if (valueChanged != null) { valueChanged(this, newValue); }
            }
        }
    }
}

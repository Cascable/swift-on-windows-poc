using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;
using System.Timers;

namespace CascableCoreDemo
{
    internal class PollingAwaiter<T, Result>
    {
        internal static async Task<Result> AwaitForNonNil(T inValue, TimeSpan pollInterval, TimeSpan timeout, Func<T, Result> func)
        {
            Func<Result, bool> comparator = delegate (Result r) { return r != null; };
            PollingAwaiter<T, Result> poller = new PollingAwaiter<T, Result>(func, comparator, inValue, pollInterval);
            return await poller.source.Task.WaitAsync(timeout);
        }

        internal static async Task<bool> AwaitForTrue(T inValue, TimeSpan pollInterval, TimeSpan timeout, Func<T, bool> func)
        {
            Func<bool, bool> comparator = delegate (bool r) { return r != false; };
            PollingAwaiter<T, bool> poller = new PollingAwaiter<T, bool>(func, comparator, inValue, pollInterval);
            return await poller.source.Task.WaitAsync(timeout);
        }

        private Func<T, Result> func;
        private Func<Result, bool> comparator;
        private T inValue;
        private Timer timer;
        private TaskCompletionSource<Result> source;

        public PollingAwaiter(Func<T, Result> func, Func<Result, bool> comparator, T inValue, TimeSpan pollInterval)
        {
            this.func = func;
            this.inValue = inValue;
            this.comparator = comparator;
            source = new TaskCompletionSource<Result>();
            timer = new Timer(pollInterval.TotalMilliseconds);
            timer.AutoReset = true;
            timer.Elapsed += OnTimerEvent;
            timer.Start();
        }

        private void OnTimerEvent(Object timer, ElapsedEventArgs e)
        {
            Result result = func(inValue);
            if (comparator(result)) {
                source.TrySetResult(result);
                this.timer.Stop();
            }
        }
    }
}

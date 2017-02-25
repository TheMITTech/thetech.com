LOG_FILE = '/tmp/migrate_log'
SRC_BUCKET = 'thetech-staging-assets'
DST_BUCKET = 'thetech-staging-assets'

import boto3
from multiprocessing.pool import ThreadPool

import threading

# From: https://gist.github.com/benhoyt/8c8a8d62debe8e5aa5340373f9c509c7
class AtomicCounter:
    """An atomic, thread-safe incrementing counter.
    >>> counter = AtomicCounter()
    >>> counter.increment()
    1
    >>> counter.increment(4)
    5
    >>> counter = AtomicCounter(42.5)
    >>> counter.value
    42.5
    >>> counter.increment(0.5)
    43.0
    >>> counter = AtomicCounter()
    >>> def incrementor():
    ...     for i in range(100000):
    ...         counter.increment()
    >>> threads = []
    >>> for i in range(4):
    ...     thread = threading.Thread(target=incrementor)
    ...     thread.start()
    ...     threads.append(thread)
    >>> for thread in threads:
    ...     thread.join()
    >>> counter.value
    400000
    """
    def __init__(self, initial=0):
        """Initialize a new atomic counter to given initial value (default 0)."""
        self.value = initial
        self._lock = threading.Lock()

    def increment(self, num=1):
        """Atomically increment the counter by num (default 1) and return the
        new value.
        """
        with self._lock:
            self.value += num
            return self.value

with open(LOG_FILE) as f:
    lines = filter(lambda l: 'MOVE FILE' in l, f.readlines())
    s3 = boto3.client('s3', 'us-east-1')
    count = len(lines)
    done = AtomicCounter()

    def copy(i):
        src, dst = lines[i].split(']')[-1].split('=>')
        src = src.strip()
        dst = dst.strip()

        s3.copy({'Bucket': SRC_BUCKET, 'Key': src[1:]}, DST_BUCKET, dst[1:], ExtraArgs = {'ACL': 'public-read'})
        print("[%5d / %5d --- %3.2f\%] %s => %s" % (done.increment(), count, 100.0 * done.value / count, src, dst))

    pool = ThreadPool(processes = 30)
    pool.map(copy, range(count))

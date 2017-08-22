# Clean up tools!

using GPUBenchmarks
db = GPUBenchmarks.get_database()
using GPUBenchmarks: name, timestamp

timestamp = last(sort(unique(timestamp.(db))))
single_ts = GPUBenchmarks.timestamp.(db, timestamp)
GPUBenchmarks.update_database!(single_ts)

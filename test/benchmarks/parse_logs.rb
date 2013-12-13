
def find_t_stat(a, b)
  diff = (b[:average] - a[:average]).to_f
  stddev = (0.5*(a[:std]**(2.0) + b[:std]**(2.0)))**(0.5)
  df_factor = (1.0 / a[:count] + 1.0 / b[:count])**(0.5)

  diff / (stddev * df_factor)
end

def find_diff(a, b)
  (b[:average] - a[:average]).to_f / b[:average]
end

eager_db = {:type=>"Benchmark::TwitterBenchmark::GetFollows", :count=>297, :average=>0.00022492522222222226, :std=>0.0005926075680845397}
eager_db = {:type=>"Benchmark::TwitterBenchmark::GetUserTweets", :count=>398, :average=>0.00019377852010050238, :std=>2.141223183202914e-05}
{:type=>"Benchmark::TwitterBenchmark::GetFollowers", :count=>284, :average=>0.00019008956338028166, :std=>2.2077970227914102e-05}

benchmark = {:type=>"Benchmark::TwitterBenchmark::GetFollows", :count=>315, :average=>0.0013215904253968255, :std=>0.01207555768404296}
benchmark = {:type=>"Benchmark::TwitterBenchmark::GetUserTweets", :count=>401, :average=>0.00032037877306733174, :std=>0.0016694958270239242}
{:type=>"Benchmark::TwitterBenchmark::GetFollowers", :count=>284, :average=>0.0008991519718309854, :std=>0.009033907453759293}


p find_diff(eager_db, benchmark)
p find_t_stat(eager_db, benchmark)

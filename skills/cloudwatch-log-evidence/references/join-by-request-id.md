# Join By request_id: Worked Example

Read this when one claim spans two log groups or two kinds of line, e.g. "every
slip-api 502 `bank verifier unavailable` has a slip-system cause". Workspace facts
as of 2026-10; re-read the source at the deployed commit before reusing a format.

## Read both sides in full

```bash
# Every page of each side. Widen the joined side by the request timeout at both ends
# so a request that crosses a window edge is not reported as unmatched.
cwf.sh /ecs/slip-api-production    2026-10-30T00:00:00Z 2026-10-31T00:00:00Z '"bank verifier unavailable"' "$SP/api.jsonl"
cwf.sh /ecs/slip-system-production 2026-10-29T23:58:00Z 2026-10-31T00:02:00Z '"unavailable"' "$SP/sys.jsonl"
```

The slip-system filter is chosen from its source: both KBank cause lines
(`kbank verify unavailable`, `kbank destination bank unavailable`) contain the
lowercase word `unavailable`. Re-grep at the deployed commit before reusing it.

`$SP` is the session scratchpad. Prefer one bulk read of each side over one
`filter-log-events` call per id: N calls are slow, and a per-id window is a
timestamp match in disguise.

## Line shapes

- slip-api, slog JSON inside the event's `message` string:
  `{"level":"WARN","msg":"http request completed","status":502,"duration_ms":31,"request_id":"r-1","path":"/v1/...","error_message":"bank verifier unavailable"}`
- slip-system, Go `log.Printf` text:
  `2026/10/30 22:05:01 kbank verify unavailable: cause=timeout request_id="r-1"`

## Join and summarize (Ruby 2.6: no `tally`, no `filter_map`)

```ruby
# ruby join.rb API_JSONL SYS_JSONL ; exits 1 when any 502 is unmatched
require "json"
rows = File.foreach(ARGV[0]).map { |l| JSON.parse(l) }
msgs = rows.map { |e| m = (JSON.parse(e["m"]) rescue nil); m.is_a?(Hash) ? m : nil } # second parse
puts "api lines=#{rows.size} unparsed=#{msgs.count(&:nil?)}"
acc = msgs.compact.select { |m| m["msg"] == "http request completed" }
status = Hash.new(0)
acc.each { |m| status[m["status"]] += 1 }
d = acc.map { |m| m["duration_ms"].to_f }.sort
pct = lambda { |q| d.empty? ? nil : d[[(d.size * q).ceil - 1, 0].max] }
puts "n=#{acc.size} status=#{Hash[status.sort_by { |k, _| k.to_s }]} " \
     "5xx=#{acc.count { |m| m["status"].to_i >= 500 }} p50=#{pct.call(0.5)} " \
     "p95=#{pct.call(0.95)} max=#{d.last} ERROR=#{msgs.compact.count { |m| m["level"] == "ERROR" }}"

kv = lambda { |line| Hash[line.scan(/(\w+)=("(?:[^"\\]|\\.)*"|\S+)/).map { |k, v| [k, v.sub(/\A"(.*)"\z/, '\1')] }] }
sys = {}
File.foreach(ARGV[1]) { |l| f = kv.call(JSON.parse(l)["m"]); sys[f["request_id"]] = f if f["request_id"] }

want = acc.select { |m| m["status"].to_i == 502 }
no_id = want.count { |m| m["request_id"].to_s.empty? }
ids = want.map { |m| m["request_id"] }.compact.reject(&:empty?).uniq
unmatched = ids.reject { |id| sys.key?(id) }
puts "join key=request_id 502_ids=#{ids.size} matched=#{ids.size - unmatched.size} " \
     "unmatched=#{unmatched.size} without_request_id=#{no_id}"
unmatched.each { |id| puts "  unmatched #{id}" }
exit(unmatched.empty? && no_id.zero? ? 0 : 1)
```

## Reading the result

- Report matched, unmatched, and every unmatched id. In one real run 10,502 of
  10,503 matched; the single remainder was the finding (a path that failed silently),
  not rounding error.
- Lines without a `request_id` cannot join; count them separately and say why.
- If the only link is time (no shared id), the result is a timestamp correlation.
  Label it weaker than a join and give the window used.
- Inside a TASK, run the whole check as one script through
  `ai-dev-office/scripts/record-evidence.sh <TASK-ID> --type command -- bash <script>`
  and cite the returned `ev-NNN`.

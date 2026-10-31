#!/usr/bin/env bash
# cwf.sh - read EVERY page of CloudWatch Logs filter-log-events into a JSONL file.
#
# Usage: cwf.sh LOG_GROUP START_ISO END_ISO FILTER OUTFILE
#   START_ISO, END_ISO  fixed UTC instants, YYYY-MM-DDTHH:MM:SSZ; both bounds inclusive.
#   FILTER              CloudWatch filter pattern: case-sensitive, exact phrase when
#                       quoted, e.g. '"daily digest"'. Pass '' to read every event.
#   OUTFILE             truncated, then one line per event:
#                       {"t":"<UTC, ms>","s":"<log stream>","m":"<raw message>"}
#                       "m" is a string; JSON log lines need a second parse.
# Prints the query, then "pages=N events=M": the completeness evidence.
#
# Credentials come only from the AWS CLI's own chain. Set the profile and region in
# the environment, e.g. AWS_PROFILE=vestearth AWS_REGION=ap-southeast-1 in this
# workspace. Nothing secret is read, stored, or printed here.
# Needs: bash 3.2+, aws CLI v2, ruby (macOS system Ruby 2.6 is enough).
# Exit: 0 every page read; 2 usage error; 3 CWF_MAX_PAGES (default 5000) reached
# with nextToken still set, so the read is incomplete; other = aws or ruby failure.
set -euo pipefail

if [ "$#" -ne 5 ]; then
  echo "usage: cwf.sh LOG_GROUP START_ISO END_ISO FILTER OUTFILE" >&2
  exit 2
fi
group=$1 start_iso=$2 end_iso=$3 filter=$4 out=$5
max_pages=${CWF_MAX_PAGES:-5000}

iso_re='^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$'
to_ms() {
  local secs
  if ! [[ $1 =~ $iso_re ]]; then
    echo "cwf: '$1' is not YYYY-MM-DDTHH:MM:SSZ (UTC)" >&2
    exit 2
  fi
  if date --version >/dev/null 2>&1; then # GNU date
    secs=$(date -u -d "$1" +%s) || exit 2
  else                                    # BSD/macOS date; it rolls 02-30 into March
    secs=$(date -j -u -f '%Y-%m-%dT%H:%M:%SZ' "$1" +%s) || exit 2
    if [ "$(date -j -u -r "$secs" +%Y-%m-%dT%H:%M:%SZ)" != "$1" ]; then
      echo "cwf: '$1' is not a real UTC date and time" >&2
      exit 2
    fi
  fi
  echo $((secs * 1000))
}
start_ms=$(to_ms "$start_iso")
end_ms=$(to_ms "$end_iso")
if [ "$start_ms" -ge "$end_ms" ]; then
  echo "cwf: START_ISO must be before END_ISO" >&2
  exit 2
fi

echo "cwf group=$group window=$start_iso..$end_iso (ms $start_ms..$end_ms) filter=${filter:-<none>}" \
  "profile=${AWS_PROFILE:-<default chain>} region=${AWS_REGION:-${AWS_DEFAULT_REGION:-<unset>}}"

# Appends one page's events to OUTFILE and prints that page's nextToken ("" on the last page).
page_rb='
d = JSON.parse(STDIN.read.force_encoding(Encoding::UTF_8))
File.open(ARGV[0], "a") do |f|
  (d["events"] || []).each do |e|
    ts = e["timestamp"]
    t = Time.at(ts / 1000, (ts % 1000) * 1000).utc.strftime("%FT%T.%LZ")
    f.puts({ "t" => t, "s" => e["logStreamName"], "m" => e["message"] }.to_json)
  end
end
print d["nextToken"].to_s'

: > "$out"
token="" pages=0
while :; do
  args=(--log-group-name "$group" --start-time "$start_ms" --end-time "$end_ms" --no-paginate --output json)
  if [ -n "$filter" ]; then args+=(--filter-pattern "$filter"); fi
  if [ -n "$token" ]; then args+=(--next-token "$token"); fi
  resp=$(aws logs filter-log-events "${args[@]}")
  pages=$((pages + 1))
  # A page may hold zero events and still carry a nextToken: keep going.
  token=$(printf '%s' "$resp" | ruby -rjson -e "$page_rb" "$out")
  if [ -z "$token" ]; then break; fi
  if [ "$pages" -ge "$max_pages" ]; then
    echo "pages=$pages events=$(wc -l < "$out" | tr -d ' ') INCOMPLETE: nextToken still set at CWF_MAX_PAGES=$max_pages" >&2
    exit 3
  fi
done
echo "pages=$pages events=$(wc -l < "$out" | tr -d ' ')"

# Manage WAF Prefetch Condition Script (manageWafPrefetch.sh)
The `manageWafPrefetch.sh` script can be used to create, read, update, or delete the Fastly WAF Prefetch Condition
via a POST, GET, PUT, or DELETE Fastly API Condition call, respectively.
More information on these API calls can be found [here](https://developer.fastly.com/reference/api/vcl-services/condition/).

Note:
- For all operations, a Fastly API Key, Service ID, and Service Version are required.
- The Fastly API Key must have at least Engineer permissions.
- Before making a call to the Fastly API, a warning message is displayed: `Hit RETURN to continue or Ctrl-C to exit`
- Usage of [jq](https://stedolan.github.io/jq/) to format output is not required, but highly recommended.

## Requirements
- Curl is required

## Installation
- Copy the following script file from this repository folder:
  - `manageWafPrefetch.sh`
- Make the bash script files executable, i.e. `chmod +x *.sh`

## Usage

### Example 1 - Script Usage
```
$ ./manageWafPrefetch.sh
ERROR: Three positional arguments expected, 0 found

USAGE: manageWafPrefetch.sh FASTLY_KEY SERVICE_ID SERVICE_VERSION [OPTIONAL_ARGUMENTS]

OPTIONAL ARGUMENTS:
  -m | --method : Method (GET|POST|PUT|DELETE)
  -s | --statement : VCL Conditional Statement
  -t | --test : Test API call using httpbin.org w/o Fastly Key
$
```
### Example 2 - Create Fastly WAF Prefetch Condition (POST)
Note:
- When creating or updating a Fastly WAF Prefetch Condition, the conditional VCL expression used to determine if the condition is met must be specified.
- To preserve the literal value of all characters within the VCL Conditional Statement,
single quotes are used instead of double quotes during its assignment.
```
$ FASTLY_KEY="YOUR_FASTLY_KEY"
$ SERVICE_ID="YOUR_SERVICE_ID"
$ SERVICE_VERSION="A_DRAFT_VERSION_NUMBER_FOR_YOUR_SERVICE"
$ STATEMENT='!req.backend.is_shield'
$ ./manageWafPrefetch.sh "$FASTLY_KEY" "$SERVICE_ID" "$SERVICE_VERSION" -m POST -s "$STATEMENT" | jq
Hit RETURN to continue or Ctrl-C to exit
{
  "statement": "!req.backend.is_shield",
  "name": "WAF_Prefetch",
  "type": "prefetch",
  "service_id": "XXXXXXXXXXXXXXXXXXXXXX",
  "version": "16",
  "updated_at": "2022-01-20T23:21:28Z",
  "comment": "",
  "created_at": "2022-01-20T23:21:28Z",
  "priority": 0,
  "deleted_at": null
}
$
```
### Example 3 - Read Fastly WAF Prefetch Condition (GET)
```
$ FASTLY_KEY="YOUR_FASTLY_KEY"
$ SERVICE_ID="YOUR_SERVICE_ID"
$ SERVICE_VERSION="ANY_VERSION_NUMBER_FOR_YOUR_SERVICE"
$ ./manageWafPrefetch.sh "$FASTLY_KEY" "$SERVICE_ID" "$SERVICE_VERSION" | jq
Hit RETURN to continue or Ctrl-C to exit
{
  "created_at": "2022-01-20T23:21:28Z",
  "statement": "!req.backend.is_shield",
  "deleted_at": null,
  "type": "PREFETCH",
  "service_id": "XXXXXXXXXXXXXXXXXXXXXX",
  "comment": "",
  "updated_at": "2022-01-20T23:21:28Z",
  "priority": "0",
  "version": "16",
  "name": "WAF_Prefetch"
}
$
```
### Example 4 - Update Fastly WAF Prefetch Condition (PUT)
Note:
- When creating or updating a Fastly WAF Prefetch Condition, the conditional VCL expression used to determine if the condition is met must be specified.
- To preserve the literal value of all characters within the VCL Conditional Statement,
single quotes are used instead of double quotes during its assignment.
```
$ FASTLY_KEY="YOUR_FASTLY_KEY"
$ SERVICE_ID="YOUR_SERVICE_ID"
$ SERVICE_VERSION="A_DRAFT_VERSION_NUMBER_FOR_YOUR_SERVICE"
$ STATEMENT='!req.backend.is_shield && !req.http.X-Do-Not-Inspect'
$ ./manageWafPrefetch.sh "$FASTLY_KEY" "$SERVICE_ID" "$SERVICE_VERSION" -m PUT -s "$STATEMENT" | jq
Hit RETURN to continue or Ctrl-C to exit
{
  "updated_at": "2022-01-20T23:21:28Z",
  "comment": "",
  "name": "WAF_Prefetch",
  "statement": "!req.backend.is_shield && !req.http.X-Do-Not-Inspect",
  "created_at": "2022-01-20T23:21:28Z",
  "version": "16",
  "type": "PREFETCH",
  "priority": "0",
  "service_id": "XXXXXXXXXXXXXXXXXXXXXX",
  "deleted_at": null
}
$
```
### Example 5 - Delete Fastly WAF Prefetch Condition (DELETE)
```
$ FASTLY_KEY="YOUR_FASTLY_KEY"
$ SERVICE_ID="YOUR_SERVICE_ID"
$ SERVICE_VERSION="A_DRAFT_VERSION_NUMBER_FOR_YOUR_SERVICE"
$ ./manageWafPrefetch.sh "$FASTLY_KEY" "$SERVICE_ID" "$SERVICE_VERSION" -m DELETE | jq
Hit RETURN to continue or Ctrl-C to exit
{
  "status": "ok"
}
$
```

## To Do's
You tell me.
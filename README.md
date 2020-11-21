# pocket-weekly-archive

This repository uses a GitHub Action to make a weekly API call to Pocket, request complete data for all unread items added in the last week, and stores the output in 2 JSON files (raw data + formatted JSON for import as a Roam page). The data is scraped and formatted using an R script.

### Step 1 : Get Pocket Secrets

 - [ ] Head over to the Pocket website to [create a new application](https://getpocket.com/developer/apps/new). Make sure to check the "Retrieve" permission, and to get a consumer key for "Desktop (Other)". In the repository settings, add that key as a secret called `POCKET_CONSUMER_KEY`. 
 - [ ] Generate an account-specific access token using [fxneumann's OneClickPocket](http://reader.fxneumann.de/plugins/oneclickpocket/auth.php). This only has to be done once, and the token can be used for all subsequent API calls. In the repository settings, add that token as a secret called `POCKET_TOKEN`.
 
**Important** : by default, the Pocket API response exposes the Consumer Key and the Access Token used to make the API request. That means they are normally plainly visible in the raw data output obtained from Pocket. I've taken steps to avoid exposing and storing those values, but use at your own risk. Thanks to [jossef's Set JSON Field action](https://github.com/marketplace/actions/set-json-field), the current implementation of the workflow edits out both values (CK & AT) from the JSON before committing the new file to the repository. For additional measures, it is possible to adjust the workflow so that it no longer saves the raw API output and only stores the processed output.

### Step 2 : Add the GitHub action for the weekly archive

 - [x] The cron job can be set to any desired frequency. By default, it's set to run every Sunday at 08:11 UTC ; a good tool to easily generate CRON settings is [crontab.guru](https://crontab.guru#11_8_*_*_SUN). If the frequency is changed to something other than weekly, make sure to change the calculation of the "since" parameter for the API call : by default, the workflow requests items added in the last 7 days.
 - [x] API requests are made using [Satak's Web Request Action](https://github.com/marketplace/actions/web-request-action).
 - [x] The workflow makes use of a few request parameters, but doesn't explicitly set all of them. A complete list is available [on the Pocket API 'Retrieve' documentation page](https://getpocket.com/developer/docs/v3/retrieve).

### Step 3 : Parameterize the R script to scrape JSON data as desired

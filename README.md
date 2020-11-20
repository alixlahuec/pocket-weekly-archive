# pocket-weekly-archive

This repository uses a GitHub Action to make a weekly API call to Pocket, request complete data for all unread items added in the last week, and stores the output in 2 JSON files (raw data + formatted JSON for import as a Roam page). The data is scraped and formatted using an R script.

### Step 1 : Get Pocket Secrets

 - [ ] Head over to the Pocket website to [create a new application](https://getpocket.com/developer/apps/new). Make sure to check the "Retrieve" permission, and to get a consumer key for "Desktop (Other)". In the repository settings, add that key as a secret called `POCKET_CONSUMER_KEY`. 
 - [ ] Generate an account-specific access token using [fxneumann's OneClickPocket](http://reader.fxneumann.de/plugins/oneclickpocket/auth.php). This only has to be done once, and the token can be used for all subsequent API calls. In the repository settings, add that token as a secret called `POCKET_TOKEN`.
 
**Important** : the Pocket API response exposes the Consumer Key and the Access Token used to make the API request. They'll be plainly visible in the raw data output obtained from Pocket. If the repository is private, that might not be a problem ; if the repository is public, anyone will be able to access these values. For security reasons, it's recommended to make the repository private and modify the workflow YAML to either 1) delete the values of the Consumer Key and Access Token from the raw JSON before it's saved into a file and committed to the repository ; or 2) no longer save the raw output and only store the processed output.

### Step 2 : Add the GitHub action for the weekly archive

 - [x] The cron job can be set to any desired frequency. By default, it's set to run every Sunday at 08:11 UTC. If the frequency is changed to something other than weekly, make sure to change the calculation of the "since" parameter for the API call : by default, the workflow requests items added in the last 7 days.
 - [x] API requests are made using [Satak's Web Request Action](https://github.com/marketplace/actions/web-request-action).
 - [x] The workflow makes use of a few request parameters, but doesn't explicitly set all of them. A complete list is available [on the Pocket API 'Retrieve' documentation page](https://getpocket.com/developer/docs/v3/retrieve).

### Step 3 : Parameterize the R script to scrape JSON data as desired

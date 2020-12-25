# pocket-weekly-archive

The main function of this repository is a GitHub Workflow (**weeklyarchive.yml**) which makes a weekly API call to Pocket, requests complete data for all unread items added in the last week, and stores the output in 2 JSON files (raw data + formatted JSON for import to a Roam page). The data is scraped and formatted using an R script. 
Another workflow is available (**alltimebackup.yml**) - it sets up a one-time API call to request all unread items, stores the raw data, and saves the formatted output into files that contain a specified maximum number of items (default is 100 ; Roam has an - unknown - limit for JSON import of blocks, and experimentally I've figured out that importing ~100 Pocket items with 5 blocks each is under the limit, but for example trying to import ~800 items doesn't work). 

Information below is geared towards describing what **weeklyarchive.yml** does, but both scripts rely on the same building blocks.

### Step 1 : Get Pocket Secrets

 - [ ] Head over to the Pocket website to [create a new application](https://getpocket.com/developer/apps/new). Make sure to check the "Retrieve" permission, and to get a consumer key for "Desktop (Other)". In the repository settings, add that key as a secret called `POCKET_CONSUMER_KEY`. 
 - [ ] Generate an account-specific access token using [fxneumann's OneClickPocket](http://reader.fxneumann.de/plugins/oneclickpocket/auth.php). This only has to be done once, and the token can be used for all subsequent API calls. In the repository settings, add that token as a secret called `POCKET_TOKEN`.
 
**Important** : by default, the Pocket API response exposes the Consumer Key and the Access Token used to make the API request. That means they are normally plainly visible in the raw data output obtained from Pocket. I've taken steps to avoid exposing and storing those values, but use at your own risk. Thanks to [jossef's Set JSON Field action](https://github.com/marketplace/actions/set-json-field), the current implementation of the workflow edits out both values (CK & AT) from the JSON before committing the new file to the repository. For additional measures, it is possible to adjust the workflow so that it no longer saves the raw API output and only stores the processed output.

### Step 2 : Setup the GitHub action for the weekly archive

 - [x] The cron job can be set to any desired frequency. By default, it's set to run every Sunday at 08:11 UTC ; a good tool to easily generate CRON settings is [crontab.guru](https://crontab.guru#11_8_*_*_SUN). If the frequency is changed to something other than weekly, make sure to change the calculation of the "since" parameter for the API call : by default, the workflow requests items added in the last 7 days.
 - [x] API requests are made using [Satak's Web Request Action](https://github.com/marketplace/actions/web-request-action).
 - [x] The workflow makes use of a few request parameters, but doesn't explicitly set all of them. A complete list is available [on the Pocket API 'Retrieve' documentation page](https://getpocket.com/developer/docs/v3/retrieve).

### Step 3 : Customize R functions to scrape JSON data as desired

 - [x] The scrapping job consists of the few lines of R script found in the workflow YAML, which in turn rely on `functions.R`. That file contains a set of utility functions, which serve to build up various components of a JSON file suitable for import into Roam (Markdown-style links, wiki-style links, block structure, nested blocks..). The last function, `format_pocket_item()`, is called on each Pocket item obtained through the API ; it specifies how the item data should be formatted. **This is where output customization happens** : I've set up my own metadata structure as default, but it can easily be adapted to other forms of data representations. The default output is as follows : 

       [Item Resolved Title](Item Resolved URL) {[[⭐]] - if favorite} {#tag1 #tag2 ... - if any} 
           Written by:: Author1 {& Author2 & ... - if any} {, for [[Website Domain]] - if available} 
           Pocket URL : https://app.getpocket.com/read/Item Resolved ID
           Date Added:: [[Month 00st/nd/rd/th, YEAR]]
           Excerpt:: Short item excerpt harvested by Pocket 

 - [x] Currently, there are 11 utility functions provided to scrape and format data for import to Roam.
    - For manipulating dates 

    | Function name | What it does |
    | ------------- | ------------ |
    | `unix_to_date(x)` | Converts Unix timestamp into a Date, with default format `YYYY-MM-DD`. **The default timezone is explicitly set to Eastern Standard Time (EST) ; any timezone can be substituted by editing the code, on line 12 of functions.R.** |
    | `date_to_roam(x)` | Converts a Date into the format used by Roam, `Month DD(ordinal suffix), YYYY` |
    | `unix_to_roam(x)` | Converts Unix timestamp into a Roam date, by calling `unix_to_date` and `date_to_roam` in succession | 

    - For making Roam syntax elements 

    | Function name | What it does |
    | ------------- | ------------ |
    | `md_link(title, url)` | Creates a Markdown-style link, from a `title` and a `URL` |
    | `roam_tags(tags)` | Transform a string (or vector) into a string of Roam tags, separated by a space and with format `#[[tag]]` to accomodate multi-word tags. |
    | `wikify(x)` | Transforms a string into a wiki-style link, `[[x]]` | 

    - For making Roam blocks 

    | Function name | What it does |
    | ------------- | ------------ |
    | `make_block(str, children)` | Creates a Roam block (list object), from a string of text (`str`) and (optional) a list object of `children`. Calling the function without specifying arguments creates an empty block with no children. |
    | `make_block_meta(attr, value, children)` | Calls `make_block`, with `str = attr:: value` and (optional) `children`. Attribute name must be specified ; the other arguments are optional. | 

    - For assembling Roam blocks 

    | Function name | What it does |
    | ------------- | ------------ |
    | `add_child(parent, child)` | Adds a `child` block to a `parent` block's children, in last place. If `child` isn't specified, an empty block is added by calling `make_block()` with defaults |
    | `add_children(parent, ...)` | Adds an unspecified number of children (`...`) to a `parent` block, in the order provided. Each child can be a childless block or a parent block - they are added as they are. | 

    - For scraping Pocket API data structure 

    | Function name | What it does |
    | ------------- | ------------ |
    | `pocket_scrape_nested_(item, prop, nested_prop` | Scrapes the value of a nested property in a list. Standard use is the retrieval of a `nested_prop` stored under the `prop` of a Pocket `item`, though it is written more generally & could be put to other uses. | 

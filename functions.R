
require(dplyr)
require(lubridate)
require(scales)


# Custom functions -----------------------------------------------------------------------------------
### 1. Manipulating dates ----------------------------------------------------
unix_to_date <- function(x){
  date <- x
  if(is.character(date)){date <- as.numeric(date)}
  # SET USER TIMEZONE HERE
  as.Date(as.POSIXct(date, origin = '1970-01-01', tz = "EST))
}
date_to_roam <- function(x){
  month <- lubridate::month(x, label = TRUE, abbr = FALSE, locale = "en_US.utf8")
  day <- scales::ordinal(lubridate::mday(x))
  year <- lubridate::year(x)
  paste0("[[", month, " ", day, ", ", year, "]]")
}
unix_to_roam <- function(x){
  date_to_roam(unix_to_date(x))
}

### 2. Making Roam syntax elements -------------------------------------------
#------------- Make Markdown-style link from title & url ----
md_link <- function(title, url){
  paste0("[", title, "](", url, ")")
}
#------------- Make Roam tag, with format #[[tag]] to accomodate multi-word tags ----
roam_tags <- function(tags){
  paste0("#[[", tags, "]]", collapse = " ")
}

#------------- Make Roam page ref ----
wikify <- function(x){
  paste0("[[", x, "]]")
}
### 3. Making Roam blocks & special types of blocks --------------------------
#------------- Make Roam block ----
#-------------------- TODO : add checks for str (character string, length 1), add checks for children (non-empty list)
make_block <- function(str = "", children = NULL){
  if(is.null(children)){
    return(list(string = str))
  } else {
    return(list(string = str, children = children))
  }
}
#------------- Create a metadata block ----
make_block_meta <- function(attr, value = NA_character_, children = NULL){
  make_block(paste0(attr, "::", if_else(!is.na(value), paste0(" ", value), "")), 
             children)
  
}

### 4. Assembling Roam blocks ------------------------------------------------
#------------- Add a child block to parent block ----
add_child <- function(parent, child = make_block()){
  p_block <- parent
  p_block[["children"]][[length(p_block[["children"]]) + 1]] <- child
  return(p_block)
}
#------------- Add multiple child blocks to parent block ----
add_children <- function(parent, ...){
  children <- list(...)
  p_block <- parent
  for(child in children){
    p_block <- add_child(p_block, child)
  }
  
  return(p_block)
}
### 5. Scraping Pocket API results -------------------------------------------
#------------- Scrape nested info (authors, tags, images...) ----
pocket_scrape_nested <- function(item, prop, nested_prop){
  return(as.character(unlist(sapply(item[[prop]], '[', nested_prop))))
}
### 6. Formatting objects for export to Roam ---------------------------------
#------------- Format a Pocket item into a Roam block ----
format_pocket_item <- function(lst){
  
  block_string <- paste0(md_link(title = lst[["resolved_title"]], url = lst[["resolved_url"]]),
                         if_else(lst[["favorite"]] == 1, " [[\u2b50]]", ""),
                         if_else("tags" %in% names(lst), paste0(" ", roam_tags(names(lst[["tags"]]))), ""))
  
  item_block <- make_block(block_string, list())
  # Get info on authors & website, if available
  written_by <- ""
  if("authors" %in% names(lst)){
    written_by <- paste0(pocket_scrape_nested(lst, "authors", "name"), collapse = " & ")
    if("domain_metadata" %in% names(lst)){
      written_by <- paste0(written_by, 
                           if_else("domain_metadata" %in% names(lst), paste0(", for ", wikify(lst[["domain_metadata"]][["name"]])), "")) 
    }
  }
  # Add blocks
  item_block <- add_children(item_block,
                             make_block_meta("Written by", value = written_by),
                             make_block(paste0("Pocket URL : https://app.getpocket.com/read/", lst[["resolved_id"]])),
                             make_block_meta("Date Added", value = unix_to_roam(lst[["time_added"]])),
                             make_block_meta("Excerpt", value = lst[["excerpt"]]))
  
  return(item_block)
  
}

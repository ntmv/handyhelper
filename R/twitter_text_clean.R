#'  Twitter Text Clean: Pre-processing functions for a twitter text corpus
#'
#' @description A wrapper function for {\code{\link[textmineR]{CreateDtm}}} of the \code{textmineR} library to pre-process twitter data. Further text mining methods can then be conveniently applied.
#'
#' @details Twitter data extracted from the web using the Twitter API contains the \code{"at"} symbol due to the formatting of a twitter handle. Additionally, it contains \code{RT} for re-tweets. A \code{https} link to the tweet is also typically present.
#'
#' \code{twitter_text_clean} conveniently detects and removes twitter handles, links and retweet mentions from text corpuses.
#' The function outputs a processed character vector. Typical text pre-processing such as removing punctuation, white space, numeric digits and upper case letters is done by default as well.
#' Alternatively, the function can also output a Document Term matrix. Similar text pre-processing is also additionally done by default here through the excellent {\code{\link[textmineR]{CreateDtm}}} function
#'
#' @param x *A character vector* containing the twitter text intended to be processed. NA values and empty entries are automatically removed.
#'
#' @param dtm A logical argument to specify if the output should be converted to a Document Term Matrix. The {\code{\link[textmineR]{CreateDtm}}} function from the \code{textmineR} library is called here. This is \code{TRUE} by default
#'
#' @param ... Other arguments to be passed to {\code{\link[textmineR]{CreateDtm}}}
#'
#' @return Processed character vector *or* Document Term Matrix (a format commonly used by many text processing libraries)
#'
#' @examples
#' data(avengertweets)
#'
#' # Outputting a character vector
#' # Specify dtm = FALSE if the intended output is a character vector
#' head(twitter_text_clean(avengertweets$tweet, dtm = FALSE))
#'
#' # Converting into a document-term matrix
#'# Can pass on additional arguments to CreateDtm
#' twitter_text_clean(avengertweets$tweet, dtm = TRUE, doc_names = avengertweets$id, cpus = 2)
#'
#'
#'
#'
#' @export


twitter_text_clean <- function(x, dtm = TRUE,...) {
  clean <- x
  # Removing NAs with a warning
  if(sum(is.na(clean)) != 0) {
    clean <- clean[!is.na(clean)]
    warning("NA values were found and removed") }
  # Testing if the input is class character
  if(!is.character(clean)) {
    stop("Text must be of class character") }
  # Testing if there are any empty string elements in character vector
  # Removing with a warning
  if(sum((stringi::stri_isempty(clean))) != 0) {
    clean <- clean[clean != ""]
    warning("Empty strings detected and removed.")
  }
 # Testing if there are unupported non-ASCII characters in input
  if(sum(stringi::stri_enc_mark(clean) != "ASCII") != 0) {
   stop("Non ASCII characters detected. Please check your input")
  }
  # Replacing twitter handles: patterns that start with @ and any alphanumeric entries that are attached
  # \w stands for words, digits and underscores
  clean <- gsub("@\\w+", "", clean)
  # Replacing retweet mention with exact pattern match
  clean <-  stringr::str_replace_all(clean, "RT", "")
  # Rplacing all URLS: patterns that start with http
    clean <-  gsub("http.*", "", clean)
    # Converting to a document-term matrix. Uses pre-processing functions of CreateDtm
  if(isTRUE(dtm)) {
    doc <- textmineR::CreateDtm(clean, lower = TRUE,
                                  remove_punctuation = TRUE,
                                  remove_numbers = TRUE,...)
    return(doc)
  }
  else {
    # Pre-processing manually if the output is a character vector
    # lowercase
    clean <- tolower(clean)
    # removing digits
    clean <- gsub('[[:digit:]]+', ' ', clean)
    # removing punctuation
    clean <- gsub('[[:punct:]]+', ' ', clean)
    #removing whitespace
    clean <- stringr::str_squish(clean)
    return(clean)
  }
}


<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- badges: start -->

[![R-CMD-check](https://github.com/ntmv/handyhelper/workflows/R-CMD-check/badge.svg)](https://github.com/ntmv/handyhelper/actions)
<!-- badges: end -->

# handyhelper

The goal of handyhelper is to enable convenient pre-processing of
Twitter text data.

Pre-processing Twitter text data requires unique steps. This is because
tweets scraped from Twitter through an API contain twitter handles, URLs
and mentions of re-tweets.

These attributes of a tweet are redundant and hamper the performance of
text-mining algorithms. `handyhelper` provides a wrapper functionality
for the `CreateDtm` function from the `textmineR` library. This
additional functionality easily removes redundant attributes specific to
twitter from text.

The package offers the option to choose between two outputs 1) A
Document Term Matrix, and 2) a character vector. A Document Term Matrix
is the default as it is a commonly used input in many **R** text-mining
packages. In addition to twitter-specific pre-processing, common text
pre-processing is applied by default to both outputs: lower case
conversion, removal of alphanumeric characters, punctuation, and
whitespace reduction.

handyhelper relies on excellently written text-manipulation functions
from the `textmineR` `stringr`, and `stringi`packages.

-   `twitter_text_clean` is a wrapper function for the `CreateDtm`
    function from the `textmineR` library. It removes all twitter
    handles, retweet mentions (RT) and any tweet links from the input
    text. It additionally performs common text pre-processing steps:
    case conversion, removal of punctuation, removal of numeric digits
    and whitespace reduction (leading and trailing). The function
    outputs a Document Term Matrix by default, but can also output a
    character vector. NA values and blank entries are automatically
    removed.

## Installation

This package is not available on CRAN as of this date. You can install
the development version of handyhelper from GitHub by running the
following line of code:

``` r
devtools::install_github("ntmv/handyhelper")
```

## Examples

The `avengertweets` dataset available with the package is used for the
following examples.

We start by outputting a character vector to see the processing. This
can be done by specifying `dtm = FALSE`

``` r
# Example with the avengertweets dataset
data(avengertweets)

# First 6 rows before pre-processing 
head(avengertweets$tweet)
#> [1] "RT @mrvelstan: literally nobody:\nme:\n\n#AvengersEndgame https://t.co/LR9kFwfD5c"                                                          
#> [2] "RT @agntecarter: im emotional, sorry!!\n\n2014 x 2019\n#blackwidow\n#captainamerica https://t.co/xcwkCMw18w"                                
#> [3] "saving these bingo cards for tomorrow \n\n #AvengersEndgame https://t.co/d6For0jwRb"                                                        
#> [4] "RT @HelloBoon: Man these #AvengersEndgame ads are everywhere https://t.co/Q0lNf5eJsX"                                                       
#> [5] "RT @Marvel: We salute you, @ChrisEvans! #CaptainAmerica #AvengersEndgame https://t.co/VlPEpnXYgm"                                           
#> [6] "RT @MCU_Direct: The first NON-SPOILER #AvengersEndgame critic reactions are here and nearly all are exceptionally positive, with many prais"
ex1 <- twitter_text_clean(avengertweets$tweet, dtm = FALSE)

# Processed tweets
head(ex1)
#> [1] "literally nobody me avengersendgame"                                                                                      
#> [2] "im emotional sorry x blackwidow captainamerica"                                                                           
#> [3] "saving these bingo cards for tomorrow avengersendgame"                                                                    
#> [4] "man these avengersendgame ads are everywhere"                                                                             
#> [5] "we salute you captainamerica avengersendgame"                                                                             
#> [6] "the first non spoiler avengersendgame critic reactions are here and nearly all are exceptionally positive with many prais"
```

We can now choose to output to a Document Term Matrix. The `dtm` logical
argument controls this output. `dtm = TRUE` by default. The function
allows for additional arguments from `CreateDtm` to be used. The
`doc_names` argument is used here as an example.

``` r
# Convert to a document-term matrix
ex2 <- twitter_text_clean(avengertweets$tweet, dtm = TRUE, doc_names = avengertweets$id)


# Class is dgCMatrix as expected
summary(ex2)
#>    Length     Class      Mode 
#>  58065000 dgCMatrix        S4
```

Lastly, we perform a basic text-mining function: generating the 10 ten
most frequent terms. While this is not a functionality offered by
package specifically, it is a nice way to demonstrate the capabilities
of the created Document Term Matrix (and of the pre-processing done).
The `TermDocFreq` function from the `textmineR` library can be used for
this, while `dplyr`library can organize the output.

``` r
# Most frequent terms 
freq_doc <- textmineR::TermDocFreq(dtm = ex2)


# Showing the top 10 most frequent terms 
# The dplyr library is needed to run this code
`%>%` <- magrittr::`%>%`
freq_doc %>% dplyr::slice_max(term_freq, n = 10)
#> # A tibble: 10 x 4
#>    term            term_freq doc_freq   idf
#>    <chr>               <dbl>    <int> <dbl>
#>  1 avengersendgame     13391    13386 0.114
#>  2 man                  2184     2174 1.93 
#>  3 premiere             1611     1606 2.23 
#>  4 ads                  1457     1457 2.33 
#>  5 marvel               1279     1268 2.47 
#>  6 captainamerica       1019     1019 2.69 
#>  7 scarlett              975      971 2.74 
#>  8 win                   952      952 2.76 
#>  9 cried                 896      611 3.20 
#> 10 chris                 892      864 2.85
```

**This package was created as part of an assignment for my data analysis
(Stats 545) class. It is not meant to be comprehensive**

**I largely used this assignment as an opportunity to gain familiarity
with regex patterns and matching. Several informative discussions on
stackoverflow helped me put together this function:**

<https://www.codeproject.com/Questions/641934/Regular-Expression-Pattern-with-wplus-and-its-beha>

<https://stackoverflow.com/questions/25352448/remove-urls-from-string>

<https://stackoverflow.com/questions/26813667/how-to-use-grep-gsub-to-find-exact-match>

<https://stackoverflow.com/questions/31348453/how-do-i-clean-twitter-data-in-r>

# Imports

Tommy Jones (2021). textmineR: Functions for Text Mining and Topic
Modeling. R package version 3.0.5.
<https://CRAN.R-project.org/package=textmineR>

Hadley Wickham (2019). stringr: Simple, Consistent Wrappers for Common
String Operations. R package version 1.4.0.
<https://CRAN.R-project.org/package=stringr>

Gagolewski M (2021). ???stringi: Fast and portable character string
processing in R.??? Journal of Statistical Software. to appear.

Gagolewski M (2021). stringi: Fast and portable character string
processing in R\_. R package version 1.7.5, &lt;URL:
<https://stringi.gagolewski.com/>&gt;.

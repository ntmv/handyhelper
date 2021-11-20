
<!-- README.md is generated from README.Rmd. Please edit that file -->

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
conversion, removal of alphanumeric digits and whitespace reduction.

handyhelper relies on excellently written text-manipulation functions
from the `textmineR` and `stringr` package.

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
#> [6] "direct the first non spoiler avengersendgame critic reactions are here and nearly all are exceptionally positive with many prais"
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
#>  60540000 dgCMatrix        S4
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
#>                            term term_freq doc_freq       idf
#> avengersendgame avengersendgame     13473    13468 0.1077337
#> man                         man      2195     2185 1.9264344
#> premiere               premiere      1611     1606 2.2343036
#> ads                         ads      1457     1457 2.3316707
#> marvel                   marvel      1283     1272 2.4674597
#> captainamerica   captainamerica      1019     1019 2.6892284
#> scarlett               scarlett       975      971 2.7374790
#> win                         win       952      952 2.7572404
#> cried                     cried       896      611 3.2007085
#> chris                     chris       892      864 2.8542327
```

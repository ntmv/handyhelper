library(testthat)
library(handyhelper)

data("avengertweets")

# Empty string entries throw a warning
test_that("empty string throws an error", {
  expect_warning(twitter_text_clean(c("", "hello", "how are you", "GOOD"), dtm = FALSE))
  expect_warning(twitter_text_clean(c("", "hello", "how are you", "GOOD"), dtm = TRUE,
                                    doc_names = seq_along(c("hello", "how are you", "GOOD"))
                                                          , cpus = 2))
})

#   NA entries throw a warning
test_that("NA entries throw an error", {
  expect_warning(twitter_text_clean(c(NA_real_, "hello", "how are you", "GOOD"), dtm = FALSE))
  expect_warning(twitter_text_clean(c(NA_real_, "hello", "how are you", "GOOD"), dtm = TRUE,
                                    doc_names = seq_along(c("hello", "how are you", "GOOD"))
                                    , cpus = 2))
})



# Creating test character vector
text <- twitter_text_clean(c("", "tangle", "precipice", "GOOD"), dtm = FALSE)
text2 <- twitter_text_clean(c("", "tangle", "precipice", "GOOD"), dtm = TRUE,
                            doc_names = seq_along(c("tangle", "precipice", "GOOD")),
                                                  cpus = 2)

text3 <- twitter_text_clean(c(NA_real_, "tangle", "precipice", "GOOD"), dtm = FALSE)
text4 <- twitter_text_clean(c(NA_real_, "tangle", "precipice", "GOOD"), dtm = TRUE,
                            doc_names = seq_along(c("tangle", "precipice", "GOOD")),
                            cpus = 2)


# Empty string entries are removed in output
test_that("output removes empty strings", {
  expect_equal(text[1], "tangle")
  expect_true(colnames(text2)[1] %in% c("good", "precipice", "tangle"))
})

# NA entries are removed in output
test_that("output removes NAs", {
  expect_equal(text3[1], "tangle")
  expect_true(colnames(text4)[1] %in% c("good", "precipice", "tangle"))
})


# Class non-character throws an error
test_that("non-character classes are not processed", {
  expect_error(twitter_text_clean(c(1, 5, 20), dtm = FALSE))
  expect_error(twitter_text_clean(matrix(c(5, 10)), dtm = TRUE))
})

# Non-ASCII characters throw an error
test_that("non-character classes are not processed", {
  expect_error(twitter_text_clean(".भा 网络र", dtm = FALSE))
  expect_error(twitter_text_clean(".भार 网络त", dtm = TRU, cpus=2))
})

# output is of same dimension
test_that("output is of same dimension", {
  expect_length((twitter_text_clean(c("a", "b", "c"), dtm = FALSE)), 3)
  expect_length((twitter_text_clean(avengertweets$tweet, dtm = FALSE)), nrow(avengertweets))
})


# Character vector output

# Punctuation is removed
test_that("punctuation is removed", {
  expect_true(sum(grepl('[[:punct:]]+',
                        twitter_text_clean(avengertweets$tweet, dtm = FALSE))) == 0)
})

# Numeric digits are removed
test_that("digits are removed", {
  expect_true(sum(grepl('[[:digit:]]+',
                        twitter_text_clean(avengertweets$tweet, dtm = FALSE))) == 0)
})


# All letters are converted to lowercase
test_that("all letters are converted to lowercase", {
  expect_true(sum(grepl('[A-Z]',
                        twitter_text_clean(avengertweets$tweet, dtm = FALSE))) == 0)
})

# All https links and partial matches are removed
test_that("all https links and partial matches are removed", {
  expect_true(sum(grepl('https://t.co/[[:alnum:]]*',
                        twitter_text_clean(avengertweets$tweet, dtm = FALSE))) == 0)
  expect_true(sum(grepl('https',
                        twitter_text_clean(avengertweets$tweet, dtm = FALSE))) == 0)
  expect_equal("hi there",twitter_text_clean("hi there https://t.co/", dtm = FALSE))
})

# All retweet mentions (RT) are removed (RT should not be first word)
test_that("all RT are removed", {
  expect_equal(sum(stringr::word(twitter_text_clean(avengertweets$tweet,
                                                    dtm = FALSE), 1) == "rt"), 0)
})

# All twitter handles and partial matches are removed
test_that("all twitter handles and partial matches are removed", {
  expect_true(sum(grepl('@\\w+',
                        twitter_text_clean(avengertweets$tweet, dtm = FALSE))) == 0)
  expect_equal("hi there",twitter_text_clean("@ hi there", dtm = FALSE))
})

# Document Term Matrix output

# creating the document term matrix
dtm <- twitter_text_clean(avengertweets$tweet, dtm = TRUE, doc_names = avengertweets$id,
                          cpus = 2)

dtm1 <- twitter_text_clean(c("persperation", "triskaidekaphobia"), dtm = TRUE,
                           doc_names = seq_along(c("persperation", "triskaidekaphobia")),
                           cpus = 2)

# output is of same dimension
test_that("output is of same dimension", {
  expect_equal(nrow(dtm), nrow(avengertweets))
  expect_equal(ncol(dtm1), length(c("persperation", "triskaidekaphobia")))
})


# All https exact matches are removed in dtm
test_that("all https are removed in dtm", {
  expect_true(sum(grepl('https', colnames(dtm))) == 0)
})

# All twitter handles are removed in dtm
test_that("all twitter handles are removed in dtm", {
  expect_true(sum(grepl('@',
                        colnames(dtm))) == 0)
})

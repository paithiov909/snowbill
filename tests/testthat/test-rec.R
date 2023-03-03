dummy_data <-
  tibble::tibble(
    doc_id = seq_along(ldccr::NekoText),
    body = ldccr::NekoText,
    category = sample.int(9, length(ldccr::NekoText), replace = TRUE)
  ) |>
  dplyr::filter(nchar(body) > 20)

# segmntr -----
test_that("default tokenization works", {
  dtm <- default_rec(dummy_data) |>
    recipes::prep() |>
    recipes::bake(new_data = NULL)
  expect_equal(ncol(dtm), 300 + 1)
})

# gibasa -----
test_that("gibasa tokenization works", {
  dtm <- gibasa_rec(dummy_data) |>
    recipes::prep() |>
    recipes::bake(new_data = NULL)
  expect_equal(ncol(dtm), 300 + 1)
})

# sudachir -----
test_that("sudachir tokenization works", {
  dtm <- sudachir_rec(dummy_data) |>
    recipes::prep() |>
    recipes::bake(new_data = NULL)
  expect_equal(ncol(dtm), 300 + 1)
})

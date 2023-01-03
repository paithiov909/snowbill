dummy_data <-
  tibble::tibble(
    doc_id = seq_along(ldccr::NekoText),
    body = ldccr::NekoText,
    category = sample.int(9, length(ldccr::NekoText), replace = TRUE)
  )

# segmntr -----
test_that("segmntr tokenization works", {
  dtm <- segmntr_rec(dummy_data) |>
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

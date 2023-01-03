# Params for recipes -----
MIN_TIMES <- 30
MAX_TOKENS <- 300
NUM_TERMS <- 300

# Recipes -----

#' @noRd
#' @export
segmntr_rec <- \(train_data) {
  recipes::recipe(category ~ body, data = train_data) |>
    textrecipes::step_tokenize(body, custom_token = \(x) {
      segmntr::segment(x)
    }) |>
    textrecipes::step_tokenfilter(body, min_times = MIN_TIMES, max_tokens = MAX_TOKENS) |>
    textrecipes::step_texthash(body, num_terms = NUM_TERMS)
}

#' @noRd
#' @export
gibasa_rec <- \(train_data, keep_tags = c("助詞", "記号")) {
  recipes::recipe(category ~ body, data = train_data) |>
    textrecipes::step_tokenize(body, custom_token = \(x) {
      gibasa::gbs_tokenize(x) |>
        gibasa::prettify(col_select = c("POS1", "POS2", "Original")) |>
        dplyr::filter(!POS1 %in% keep_tags) |>
        dplyr::group_by(doc_id) |>
        dplyr::group_map(\(df, i) {
          paste(
            dplyr::if_else(is.na(df$Original), df$token, df$Original),
            df$POS1,
            df$POS2,
            sep = "/"
          )
        })
    }) |>
    textrecipes::step_tokenfilter(body, min_times = MIN_TIMES, max_tokens = MAX_TOKENS) |>
    textrecipes::step_texthash(body, num_terms = NUM_TERMS)
}

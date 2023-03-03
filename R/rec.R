# Params for recipes -----
MIN_TIMES <- 30
MAX_TOKENS <- 300
NUM_TERMS <- 300

# Recipes -----

#' @noRd
#' @export
default_rec <- \(train_data) {
  recipes::recipe(category ~ body, data = train_data) |>
    textrecipes::step_tokenize(body) |>
    textrecipes::step_tokenfilter(body, min_times = MIN_TIMES, max_tokens = MAX_TOKENS) |>
    textrecipes::step_texthash(body, num_terms = NUM_TERMS)
}

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
gibasa_rec <- \(train_data) {
  recipes::recipe(category ~ body, data = train_data) |>
    textrecipes::step_tokenize(body, custom_token = \(x) {
      gibasa::tokenize(x) |>
        gibasa::prettify(col_select = c("POS1", "Original")) |>
        dplyr::group_by(doc_id) |>
        dplyr::group_map(\(df, i) {
          stringi::stri_c(
            dplyr::if_else(is.na(df$Original), df$token, df$Original), df$POS1,
            sep = "/"
          )
        })
    }) |>
    textrecipes::step_tokenfilter(body, min_times = MIN_TIMES, max_tokens = MAX_TOKENS) |>
    textrecipes::step_texthash(body, num_terms = NUM_TERMS)
}

#' @noRd
#' @export
gibasa_rec2 <- \(train_data, discard_tags = c("助詞", "助動詞", "記号")) {
  recipes::recipe(category ~ body, data = train_data) |>
    textrecipes::step_tokenize(body, custom_token = \(x) {
      gibasa::tokenize(x) |>
        gibasa::prettify(col_select = c("POS1", "Original")) |>
        dplyr::filter(!POS1 %in% discard_tags) |>
        dplyr::group_by(doc_id) |>
        dplyr::group_map(\(df, i) {
          stringi::stri_c(
            dplyr::if_else(is.na(df$Original), df$token, df$Original), df$POS1,
            sep = "/"
          )
        })
    }) |>
    textrecipes::step_tokenfilter(body, min_times = MIN_TIMES, max_tokens = MAX_TOKENS) |>
    textrecipes::step_texthash(body, num_terms = NUM_TERMS)
}

#' @noRd
#' @export
sudachir_rec <- \(train_data) {
  recipes::recipe(category ~ body, data = train_data) |>
    textrecipes::step_tokenize(body, custom_token = \(x) {
      reticulate::use_virtualenv("r-sudachipy")
      tokenizer <- sudachir::rebuild_tokenizer()
      sudachir::tokenize_to_df(x,
                               into = sudachir::dict_features("en"),
                               col_select = c("pos1"),
                               instance = tokenizer) |>
        dplyr::rename(token = surface) |>
        dplyr::group_by(doc_id) |>
        dplyr::group_map(\(df, i) {
          stringi::stri_c(
            df$normalized_form, df$pos1,
            sep = "/"
          )
        })
    }) |>
    textrecipes::step_tokenfilter(body, min_times = MIN_TIMES, max_tokens = MAX_TOKENS) |>
    textrecipes::step_texthash(body, num_terms = NUM_TERMS)
}

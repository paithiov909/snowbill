#' @noRd
#' @export
read_corpus <- \(prop = .1) {
  ldccr::read_ldnws() |>
    dplyr::mutate(doc_id = as.character(dplyr::row_number())) |>
    dplyr::slice_sample(prop = prop)
}

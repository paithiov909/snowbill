#' @noRd
#' @export
get_nchar <- \(tbl) {
  dplyr::mutate(tbl, nchar = nchar(body))
}

#' @noRd
#' @export
summarize_nchar <- \(tbl, group = category) {
  tbl |>
    dplyr::group_by(!!rlang::enquo(group)) |>
    dplyr::summarise(
      nchar_mean = mean(nchar),
      nchar_median = median(nchar),
      nchar_min = min(nchar),
      nchar_max = max(nchar),
      nchar_total = sum(nchar),
      n = dplyr::n()
    ) |>
    dplyr::mutate(across(where(is.numeric), trunc))
}

#' @noRd
#' @export
plot_nchar <- \(tbl, color = "category") {
  tbl |>
    ggpubr::ggdensity(
      "nchar",
      y = "density",
      color = color,
      palette = viridisLite::turbo(9)
    )
}

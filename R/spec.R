#' @noRd
#' @export
xgb_spec <- \() {
  parsnip::boost_tree(
    trees = 300,
    learn_rate = .2,
    sample_size = tune::tune(),
    loss_reduction = tune::tune(),
    tree_depth = tune::tune(),
    stop_iter = 5
  ) |>
    parsnip::set_engine(
      "xgboost",
      nthread = max(1, parallel::detectCores(logical = FALSE) - 1, na.rm = 1)
    ) |>
    parsnip::set_mode("classification")
}

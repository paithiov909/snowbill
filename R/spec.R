#' @noRd
#' @export
xgb_spec <- \() {
  parsnip::boost_tree(
    trees = 500,
    learn_rate = .2,
    sample_size = tune::tune(),
    loss_reduction = tune::tune(),
    tree_depth = tune::tune(),
    stop_iter = 5
  ) |>
    parsnip::set_engine("xgboost") |>
    parsnip::set_mode("classification")
}

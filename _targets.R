require(targets)

options(tidyverse.quiet = TRUE)
tar_option_set(
  packages = c("tidymodels", "textrecipes")
)
# tar_make_clustermq() configuration (okay to leave alone):
options(clustermq.scheduler = "multicore")

tar_source()

# Replace the target list below with your own:
list(
  tar_target(raw_data, read_corpus(1)),
  tar_target(corp_nchar, get_nchar(raw_data)),
  tar_target(nchar_summary, summarize_nchar(corp_nchar)),
  tar_target(nchar_density, plot_nchar(corp_nchar)),
  tar_target(corp_split,
    rsample::initial_split(raw_data, strata = category)
  ),
  tar_target(tuned_models,
    workflowsets::workflow_set(
      preproc = list(
        segmntr = segmntr_rec(rsample::training(corp_split)),
        gibasa = gibasa_rec(rsample::training(corp_split))
      ),
      models = list(xgb_spec()),
      cross = FALSE
    ) |>
      workflowsets::workflow_map(
        fn = "tune_grid",
        resamples = rsample::vfold_cv(
          rsample::training(corp_split),
          v = 3,
          strata = category
        ),
        grid = dials::grid_latin_hypercube(
          dials::sample_prop(),
          dials::loss_reduction(),
          dials::tree_depth(),
          size = 5
        ),
        metrics = yardstick::metric_set(yardstick::f_meas),
        control = tune::control_grid(save_pred = TRUE)
      )
  ),
  tar_target(best_models,
    workflowsets::rank_results(
      tuned_models,
      rank_metric = "f_meas",
      select_best = TRUE
    )
  ),
  tar_target(corp_wflow,
    tune::finalize_workflow(
      workflowsets::extract_workflow(
        tuned_models,
        best_models[["wflow_id"]][1]
      ),
      workflowsets::extract_workflow_set_result(
        tuned_models,
        best_models[["wflow_id"]][1]
      ) |> tune::select_best("f_meas")
    )
  )
)

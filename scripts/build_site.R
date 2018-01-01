#!/usr/local/bin/Rscript
devtools::load_all(here::here())

cur_week <- 2
themes <- c("Explore", "Wrangle", "Program", "Model", "Communicate", "Workflow")

message("Building units ----------------------------------")
build_units()

message("Building storyboard -----------------------------")
build_storyboard()

message("Building overview graph -------------------------")
build_overview()

message("DONE ============================================")

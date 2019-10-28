gs_radar <- function(res_enrich1,
                     res_enrich2,
                     n_gs = 20,
                     p_value_column = "p.value_elim") {
  # TODO: option to have more and compare them on the same plot!

  # TODO: option to have a list

  # TODO: check that the categories contained are the same
  # -- or option to merge w NAs or so

  # res_enrich has to contain the Z-score to be displayed

  if (!("z_score" %in% colnames(res_enrich))) {
    warning("You need to add the z_score or the aggregated score")
  } # TODO: same for aggr_score


  # TODO: will remove
  set.seed(42)
  shuffled_ones <- sample(seq_len(n_gs))
  # TODO

  res_enrich1$logp10 <- -log10(res_enrich1[[p_value_column]])

  res_enrich1 <- res_enrich1[seq_len(n_gs), ]
  res_enrich2 <- res_enrich1[seq_len(n_gs), ]

  res_enrich2$logp10 <- -log10(res_enrich2[[p_value_column]])

  res_enrich2$logp10 <- res_enrich2$logp10[shuffled_ones]
  res_enrich2$z_score <- res_enrich2$z_score[shuffled_ones]

  log_smallest_p <- max(res_enrich1$logp10, res_enrich2$logp10)
  set_colors <- RColorBrewer::brewer.pal(n = 8, "Set1")

  p <- plot_ly(
    type = "scatterpolar",
    mode = "markers",
    fill = "toself"
  ) %>%
    add_trace(
      r = c(res_enrich1$logp10, res_enrich1$logp10[1]), # recycling the first element
      theta = c(res_enrich1$Term, res_enrich1$Term[1]),
      name = "scenario 1"
    ) %>%
    add_trace(
      r = c(res_enrich2$logp10, res_enrich2$logp10[1]),
      theta = c(res_enrich2$Term, res_enrich2$Term[1]),
      name = "scenario 2"
    ) %>%
    plotly::layout(
      polar = list(radialaxis = list(visible = TRUE,
                                     range = c(0,log_smallest_p))
                   )
      # ,
      # title = "Geneset Radar Chart", font = list(size = 10)
    )

  # TODO: do some kind of for loop/list approach?

  # TODO: some better tooltips
  # ideas: https://www.r-bloggers.com/radar-charts-in-r-using-plotly/

  return(p)
}


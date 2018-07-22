##%######################################################%##
#                                                          #
####                  Clinical Data DT                  ####
#                                                          #
##%######################################################%##

library(DT); library(htmlwidgets); library(plotly)
load("data/clinical_data.rda")
dt = datatable(clinical_data)
file = file.path(getwd(),"widget/clinical.html")
htmlwidgets::saveWidget(as_widget(dt), file = file)
